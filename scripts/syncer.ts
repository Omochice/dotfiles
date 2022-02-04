import * as Path from "https://deno.land/std@0.125.0/path/mod.ts";
import { equals } from "https://deno.land/std@0.125.0/bytes/mod.ts";
import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.0/mod.ts";
import * as Colors from "https://deno.land/std@0.125.0/fmt/colors.ts";
import { parse } from "https://deno.land/std@0.125.0/encoding/toml.ts";
import {
  ensureDirSync,
  exists,
  existsSync,
} from "https://deno.land/std@0.125.0/fs/mod.ts";

interface Setting {
  tools: Tool[];
}

interface Tool {
  repo: string;
  build?: string;
  destination?: string;
  symlink?: SymlinkOption;
}

interface SymlinkOption {
  source: string;
  destination?: string;
}

const Decorder = new TextDecoder();

function decodeMessage(arr: Uint8Array): string {
  return (Decorder.decode(arr));
}

async function loadToml(path: string): Promise<Setting> {
  const contents = Deno.readTextFile(path);
  return (parse(await contents) as unknown as Setting);
}

function expand(path: string): string {
  return Path.normalize(path).replace(/^~/, Deno.env.get("HOME") || "");
}

function debugLog(message: string, show: boolean): void {
  if (show) {
    console.log(Colors.blue(`[DEBUG] ${message}`));
  }
}

async function handleError(
  process: Deno.Process,
  repo: string,
): Promise<boolean> {
  if (!(await process.status()).success) {
    console.error(
      Colors.red(
        `Error on ${repo}: ${decodeMessage(await process.stderrOutput())}`,
      ),
    );
    return true;
  } else {
    return false;
  }
}

async function install(
  repo: string,
  install_to: string,
  debug = false,
): Promise<boolean> {
  debugLog(`Start install ${repo}`, debug);

  if (existsSync(install_to)) {
    debugLog(`call first rev-parse on ${repo}`, debug);
    const old_rev_process = Deno.run({
      cmd: ["git", "rev-parse", "HEAD"],
      stdout: "piped",
      stderr: "piped",
      cwd: install_to,
    });
    if (await handleError(old_rev_process, repo)) {
      return false; // dont process other if error occur
    }
    debugLog(`call pull on ${repo}`, debug);
    const pull_process = Deno.run({
      cmd: ["git", "pull"],
      stdout: "null",
      stderr: "piped",
      cwd: install_to,
    });
    if (await handleError(pull_process, repo)) {
      return false;
    }
    debugLog(`call second rev-parse on ${repo}`, debug);
    const new_rev_process = Deno.run({
      cmd: ["git", "rev-parse", "HEAD"],
      stdout: "piped",
      stderr: "piped",
      cwd: install_to,
    });
    if (await handleError(new_rev_process, repo)) {
      return false;
    }
    const [old_hash, new_hash] = await Promise.all([
      old_rev_process.output(),
      new_rev_process.output(),
    ]);
    const updated = !equals(old_hash, new_hash);
    debugLog(`is ${repo} updated? -> ${updated}`, debug);
    return updated;
  } else {
    debugLog(`Start clone ${repo}`, debug);
    const clone_process = Deno.run({
      cmd: ["git", "clone", `https://github.com/${repo}`, install_to],
      stdout: "null",
      stderr: "piped",
    });
    await handleError(clone_process, repo);
    console.log(existsSync(install_to));
    // debugLog(`Done clone ${repo}`,debug)
    return true;
  }
}

async function build(
  commands: Array<string>,
  working_directory: string,
  debug = false,
): Promise<void> {
  debugLog(`Start build on ${working_directory}`, debug);
  for (const command of commands) {
    debugLog(`run ${command} on ${working_directory}`, debug);
    const build_process = Deno.run({
      cmd: command.split(/s+/), // :FIXME:
      stdout: "null",
      stderr: "piped",
      cwd: working_directory,
    });
    await handleError(build_process, working_directory);
  }
}

async function link(
  source: string,
  destination: string,
  working_directory: string,
  debug = false,
) {
  // link
  debugLog(`Start link ${source} to ${destination}`, debug);
  const link_process = Deno.run({
    cmd: ["ln", "-snf", source, destination],
    stdout: "null",
    stderr: "piped",
    cwd: working_directory,
  });
  await handleError(link_process, working_directory);
}

async function sync(
  tool: Tool,
  base_dir: string,
  link_to: string,
  debug = false,
  quiet = false,
): Promise<void> {
  const [_owner, repo] = tool.repo.split("/");
  const destination = Path.join(expand(base_dir), tool.destination || repo);

  debugLog(`Start sync on ${tool.repo} to ${destination}`, debug);
  const updated = await install(tool.repo, destination, debug);
  if (tool.build && updated) {
    await build(
      tool.build.split("\n").filter((line) => line.length != 0),
      destination,
    );
  }
  if (tool.symlink) {
    await link(
      Path.join(destination, tool.symlink.source),
      Path.join(
        expand(tool.symlink.destination || link_to),
        Path.basename(tool.symlink.source),
      ),
      destination,
      debug,
    );
  }
  if (!quiet) {
    console.log(Colors.green(`${tool.repo} is synchronized!!`));
  }
}

@Help("Tool synchronizer for me")
@Version("0.0.0")
class Program extends Command {
  @Arg({ about: "path to config file" })
  config!: string;

  @Opt({ about: "path to root directory (default to $HOME/Tools/)" })
  basedir = "~/Tools";

  @Opt({ about: "path to put symlunk (default to $HOME/.local/bin/)" })
  link_to = "~/.local/bin";

  @Flag({ about: "enable debug mode" })
  debug = false;

  @Flag({ about: "Quiet mode", short: "q" })
  quiet = false;

  async execute() {
    const toml_data = await loadToml(this.config);
    ensureDirSync(expand(this.link_to));
    const queue = [];
    for (const tool of toml_data.tools) {
      queue.push(sync(tool, this.basedir, this.link_to, this.debug));
    }
    Promise.all(queue);
    Promise.resolve();
  }
}

await Program.run(Deno.args);

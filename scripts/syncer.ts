import * as Path from "https://deno.land/std@0.135.0/path/mod.ts";
import { equals } from "https://deno.land/std@0.135.0/bytes/mod.ts";
import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.2/mod.ts";
import * as Colors from "https://deno.land/std@0.135.0/fmt/colors.ts";
import { parse } from "https://deno.land/std@0.135.0/encoding/toml.ts";
import {
  ensureDirSync,
  exists,
  existsSync,
} from "https://deno.land/std@0.135.0/fs/mod.ts";
import os from "https://deno.land/x/dos@v0.11.0/mod.ts";
import { expandGlobSync } from "https://deno.land/std@0.140.0/fs/mod.ts";

type OSType = "mac" | "wsl" | "linux";
type OS = "wsl" | typeof Deno.build.os;

interface Setting {
  tools: Tool[];
}

interface Tool {
  repo: string;
  build?: string;
  destination?: string;
  symlink?: SymlinkOption;
  skip?: OSType[];
}

interface SymlinkOption {
  source: string | string[];
  destination?: string;
}

function getOS(): OS {
  try {
    const b = Deno.readTextFileSync("/proc/version").toString().toLowerCase();
    return b.includes("microsoft") ? "wsl" : Deno.build.os;
  } catch {
    return Deno.build.os;
  }
}

const osName = getOS();

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

function debugLog(message: string): void {
  console.log(Colors.blue(`[DEBUG] ${message}`));
}

function showError(repo: string, errorMessage: string): void {
  console.error(
    Colors.red(
      `Error on ${repo}: ${errorMessage}`,
    ),
  );
}

async function handleError(
  process: Deno.Process,
  repo: string,
  onError = showError,
): Promise<boolean> {
  if (!(await process.status()).success) {
    onError(repo, decodeMessage(await process.stderrOutput()));
    return true;
  }
  return false;
}

async function clone(
  repo: string,
  installTo: string,
  debug = false,
): Promise<void> {
  debug && debugLog(`Start clone ${repo}`);
  const clone_process = Deno.run({
    cmd: ["git", "clone", `https://github.com/${repo}`, installTo],
    stdout: "null",
    stderr: "piped",
  });
  await handleError(clone_process, repo);
}

async function getHeadCommitID(
  cwd: string,
): Promise<string> {
}

async function pull(
  repo: string,
  cwd: string,
  debug = false,
): Promise<boolean> {
  const old_rev_process = Deno.run({
    cmd: ["git", "rev-parse", "HEAD"],
    stdout: "piped",
    stderr: "piped",
    cwd: install_to,
  });
}

async function install(
  repo: string,
  install_to: string,
  debug = false,
): Promise<boolean> {
  debug && debugLog(`Start install ${repo}`);
  if (existsSync(install_to)) {
    debug && debugLog(`call first rev-parse on ${repo}`);
    const old_rev_process = Deno.run({
      cmd: ["git", "rev-parse", "HEAD"],
      stdout: "piped",
      stderr: "piped",
      cwd: install_to,
    });
    if (await handleError(old_rev_process, repo)) {
      return false; // dont process other if error occur
    }
    debug && debugLog(`call pull on ${repo}`);
    const pull_process = Deno.run({
      cmd: ["git", "pull"],
      stdout: "null",
      stderr: "piped",
      cwd: install_to,
    });
    if (await handleError(pull_process, repo)) {
      return false;
    }
    debug && debugLog(`call second rev-parse on ${repo}`);
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
    if (updated) {
      debug && debugLog(
        `${repo} is updated ${decodeMessage(old_hash).trim()} to ${
          decodeMessage(new_hash).trim()
        }`,
      );
    } else {
      debug && debugLog(`${repo} is newest already`);
    }
    return updated;
  } else {
    debug && debugLog(`Start clone ${repo}`);
    const clone_process = Deno.run({
      cmd: ["git", "clone", `https://github.com/${repo}`, install_to],
      stdout: "null",
      stderr: "piped",
    });
    await handleError(clone_process, repo);
    // debugLog(`Done clone ${repo}`,debug)
    return true;
  }
}

async function build(
  commands: Array<string>,
  working_directory: string,
  debug = false,
): Promise<void> {
  debug && debugLog(`Start build on ${working_directory}`);
  for (const command of commands) {
    debug && debugLog(`run ${command} on ${working_directory}`);
    const build_process = Deno.run({
      cmd: command.split(/\s+/),
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
  debug && debugLog(`Start link ${source} to ${destination}`);
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
  const path_to_clone = Path.join(expand(base_dir), tool.destination || repo);

  debug && debugLog(`Start sync on ${tool.repo} to ${path_to_clone}`);
  const updated = await install(tool.repo, path_to_clone, debug);
  if (tool.build && updated) {
    console.log(Colors.yellow(`Building ${repo}...`));
    await build(
      tool.build.split("\n").filter((line) => line.length != 0),
      path_to_clone,
      debug,
    );
  }
  if (tool.symlink) {
    const sources = [tool.symlink.source].flat(Infinity) as string[];
    for (const source_maybe_glob of sources) {
      for (
        const s of expandGlobSync(Path.join(path_to_clone, source_maybe_glob))
      ) {
        const source = s.path;
        const path_to_link = Path.join(
          expand(tool.symlink.destination || link_to),
          Path.basename(source),
        );
        await link(source, path_to_link, path_to_clone, debug);
      }
    }
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
    const tomlData = await loadToml(this.config);
    ensureDirSync(expand(this.link_to));
    const queue = [];
    for (const tool of tomlData.tools) {
      if (tool.skip !== undefined && tool.skip.some((e) => e == osName)) {
        continue;
      }
      queue.push(sync(tool, this.basedir, this.link_to, this.debug));
    }
    Promise.all(queue);
  }
}

await Program.run(Deno.args);

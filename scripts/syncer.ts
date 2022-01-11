import * as Path from "https://deno.land/std@0.119.0/path/mod.ts";
import { equals } from "https://deno.land/std@0.120.0/bytes/mod.ts";
import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.0/mod.ts";
import { parse } from "https://deno.land/std@0.119.0/encoding/toml.ts";
import {
  ensureDirSync,
  existsSync,
} from "https://deno.land/std@0.119.0/fs/mod.ts";

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

async function sync(
  tool: Tool,
  base_dir: string,
  link_to: string,
  debug = false,
): Promise<void> {
  const [owser, repo] = tool.repo.split("/");
  const dst = Path.join(expand(base_dir), tool.destination || repo);

  if (debug) {
    console.log(`[DEBUG] ${owser}/${repo} -> ${dst}`);
  }

  if (existsSync(dst)) {
    // update
    const rev_process = Deno.run({
      cmd: ["git", "rev-parse", "HEAD"],
      stdout: "piped",
      stderr: "piped",
      cwd: dst,
    });
    if (!(await rev_process.status()).success) {
      console.error(decodeMessage(await rev_process.stderrOutput()));
    }
    const p = Deno.run({
      cmd: ["git", "pull"],
      stdout: "piped",
      stderr: "piped",
      cwd: dst,
    });
    if (!(await p.status()).success) {
      console.error(decodeMessage(await p.stderrOutput()));
    }
    // if no-update then return early
    Promise.all([
      rev_process.output(),
      Deno.run({
        cmd: ["git", "rev-parse", "HEAD"],
        stdout: "piped",
        cwd: dst,
      }).output(),
    ]).then((values) => {
      if (equals(values[0], values[1])) {
        return Promise.resolve();
      }
    });
  } else {
    // install
    // TODO: specify rev
    const p = Deno.run({
      cmd: ["git", "clone", `https://github.com/${owser}/${repo}`, dst],
      stdout: "piped",
      stderr: "piped",
    });
    if (!(await p.status()).success) {
      console.error(decodeMessage(await p.stderrOutput()));
    }
  }

  // Build
  if (tool.build) {
    for (
      const command of tool.build.split("\n").filter((line) => line.length != 0)
    ) {
      const p = Deno.run({
        cmd: command.split(/\s+/),
        stdout: "piped",
        stderr: "piped",
        cwd: dst,
      });
      if (!(await p.status()).success) {
        console.error(decodeMessage(await p.stderrOutput()));
      }
    }
  }

  // link
  if (tool.symlink) {
    const link_source = Path.join(
      dst,
      tool.symlink.source,
    );
    const link_destination = Path.join(
      expand(tool.symlink.destination || link_to),
      Path.basename(tool.symlink.source),
    );
    const p = Deno.run({
      cmd: ["ln", "-snf", link_source, link_destination],
      cwd: dst,
      stderr: "piped",
    });
    if (!(await p.status()).success) {
      console.error(decodeMessage(await p.stderrOutput()));
    }
  }
}

@Help("Tool synchronizer for me")
@Version("0.0.0")
class Program extends Command {
  @Arg({ about: "path to config file" })
  config!: string;

  @Opt({ about: "path to root directory" })
  basedir = "~/Tools";

  @Opt({ about: "path to put symlunk" })
  link_to = "~/.local/bin";

  @Flag({ about: "enable debug mode" })
  debug = false;

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

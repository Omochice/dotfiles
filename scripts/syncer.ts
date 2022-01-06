import * as Path from "https://deno.land/std@0.119.0/path/mod.ts";
import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.0/mod.ts";
import { parse } from "https://deno.land/std@0.119.0/encoding/toml.ts";
import { existsSync } from "https://deno.land/std@0.119.0/fs/mod.ts";

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

const decorder = new TextDecoder();

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
    const p = Deno.run({
      cmd: ["git", "pull"],
      cwd: dst,
      stderr: "piped",
    });
    if (!(await p.status()).success) {
      console.error(decorder.decode(await p.stderrOutput()));
    }
  } else {
    // install
    const p = Deno.run({
      cmd: ["git", "clone", `https://github.com/${owser}/${repo}`, dst],
      stderr: "piped",
    });
    if (!(await p.status()).success) {
      console.error(decorder.decode(await p.stderrOutput()));
    }
  }

  // Build
  if (tool.build) {
    for (const command of tool.build.split("\n")) {
      const p = Deno.run({
        cmd: command.split(/\s+/),
        stderr: "piped",
        cwd: dst,
      });
      if (!(await p.status()).success) {
        console.error(decorder.decode(await p.stderrOutput()));
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
      console.error(decorder.decode(await p.stderrOutput()));
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
    for (const tool of toml_data.tools) {
      await sync(tool, this.basedir, this.link_to, this.debug);
    }
    Promise.resolve();
  }
}

await Program.run(Deno.args);

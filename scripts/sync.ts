import * as path from "https://deno.land/std@0.135.0/path/mod.ts";
import { blue, green } from "https://deno.land/std@0.125.0/fmt/colors.ts";
import ini from "https://cdn.skypack.dev/ini";
import { ensureString } from "https://deno.land/x/unknownutil@v2.0.0/mod.ts";
import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.0/mod.ts";

const globalOption = {
  executePath: path.fromFileUrl(import.meta.url),
  dotDir: path.resolve(path.join(path.fromFileUrl(import.meta.url), "../../")),
  homeDir: ensureString(Deno.env.get("HOME")),
  backupDir: Deno.makeTempDirSync(),
  quiet: false,
  debug: false,
};

type LinkOption = {
  sources: string[];
  targetDir: string;
};

function isDotfile(p: string): boolean {
  const basename = path.basename(p);

  return path.basename(p).startsWith(".") &&
    !(basename == ".git" || basename == ".gitignore");
}

async function link(option: LinkOption): Promise<void> {
  try {
    Deno.mkdirSync(globalOption.backupDir, {});
  } catch (_) {
    // backup directory exists already, use it.
  }
  const tasks = [];
  for (const source of option.sources) {
    const target = path.join(option.targetDir, path.basename(source));
    try {
      if (Deno.lstatSync(target).isSymlink) {
        Deno.removeSync(target);
      } else {
        const moveTo = path.join(
          globalOption.backupDir,
          path.basename(target),
        );
        Deno.renameSync(
          target,
          moveTo,
        );
        globalOption.quiet ||
          console.log(green(`${target} is backuped to ${moveTo}`));
      }
    } catch (_) {
      // target file is not exits. do nothing.
    }
    tasks.push(
      Deno.symlink(source, target),
    );
    globalOption.debug && console.log(blue(`${source} is linked to ${target}`));
  }
  await Promise.all(tasks);
}

async function linkToHomedir(): Promise<void> {
  const option: LinkOption = { sources: [], targetDir: globalOption.homeDir };
  for await (const f of Deno.readDir(globalOption.dotDir)) {
    if (isDotfile(f.name)) {
      option.sources.push(path.join(globalOption.dotDir, f.name));
    }
  }
  await link(option);
}

async function linkToConfig(): Promise<void> {
  const option: LinkOption = {
    sources: [],
    targetDir: path.join(globalOption.homeDir, ".config"),
  };
  const confDir = path.join(globalOption.dotDir, "config");
  for await (const f of Deno.readDir(confDir)) {
    option.sources.push(path.join(confDir, f.name));
  }
  await link(option);
}

function writeGitConfig(sharedFile: string): void {
  const target = path.join(globalOption.homeDir, ".gitconfig");
  let gitconfig;
  try {
    gitconfig = ini.parse(
      Deno.readTextFileSync(target),
    );
  } catch (_) {
    gitconfig = {};
  }

  if (!gitconfig.include || !gitconfig.init) {
    Deno.writeTextFileSync(
      target,
      ini.stringify({
        ...gitconfig,
        ...{ include: { path: sharedFile }, init: { defaultBranch: "main" } },
      }),
    );
  }
}

@Help("Installer for Dotfiles")
@Version("0.0.0")
class Program extends Command {
  @Opt({
    about: "Path of directory to backup if file is exist already" +
      ` default: ${globalOption.backupDir}`,
  })
  backupDir = undefined;

  @Flag({ about: "enable debug mode" })
  debug = false;

  @Flag({ about: "Quiet mode", short: "q" })
  quiet = false;

  async execute() {
    globalOption.backupDir = this.backupDir ?? globalOption.backupDir;
    globalOption.quiet = this.quiet;
    globalOption.debug = this.debug;
    await linkToHomedir();
    this.quiet || console.log(blue("Linking to home directory ... DONE!"));
    await linkToConfig();
    this.quiet || console.log(blue("Linking to config directory ... DONE!"));
    writeGitConfig(
      path.join(globalOption.dotDir, ".gitconfig_shared"),
    );
    this.quiet || console.log(blue("Including shared config ... DONE!"));
  }
}

await Program.run(Deno.args);

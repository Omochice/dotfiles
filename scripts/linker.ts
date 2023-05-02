import ini from "https://cdn.skypack.dev/-/ini@v4.1.0-LGvECHuzD3m8uiMCeDsZ/dist=es2019,mode=imports/optimized/ini.js";
import { dirname } from "https://deno.land/std@0.157.0/path/win32.ts";
import {
  basename,
  fromFileUrl,
  join,
  resolve,
} from "https://deno.land/std@0.185.0/path/mod.ts";
import { blue } from "https://deno.land/std@0.157.0/fmt/colors.ts";

type Task = { from: string; to: string };

const DOTDIR = dirname(
  dirname(
    resolve(
      join(
        fromFileUrl(import.meta.url),
      ),
    ),
  ),
);
const HOME = Deno.env.get("HOME") ?? "~";
const CONFIG = Deno.env.get("XDG_CONFIG_HOME") ?? join(HOME, ".config");

function isDotfile(path: string): boolean {
  const base = basename(path);
  return base.startsWith(".") && !(base == ".git" || base == ".gitignore");
}

function makeBuckupDirectory(dir = join(HOME, ".cache", "dotbackup")) {
  Deno.mkdirSync(dir, { recursive: true });
  return Deno.makeTempDirSync({ dir });
}

async function link(
  task: Task,
  backupDirectory: string,
): Promise<void> {
  try {
    if (Deno.lstatSync(task.to).isSymlink) {
      // NOTE: if symlink exists, unlink it.
      Deno.removeSync(task.to);
    } else {
      Deno.renameSync(
        task.to,
        join(backupDirectory, basename(task.to)),
      );
    }
  } catch (_) {
    // NOTE: link target does not exist.
  }

  Deno.symlink(task.from, task.to);
}

function linkToHome(): Task[] {
  const base = join(DOTDIR);
  return Array.from(Deno.readDirSync(DOTDIR))
    .filter((d: Deno.DirEntry) => isDotfile(d.name))
    .map((d: Deno.DirEntry) => ({
      from: join(base, d.name),
      to: join(HOME, d.name),
    }));
}

function linkToConfig(): Task[] {
  const base = join(DOTDIR, "config");
  return Array.from(
    Deno.readDirSync(base),
  ).map((d) => ({ from: join(base, d.name), to: join(CONFIG, d.name) }));
}

function writeGitConfig(sharedFile: string): void {
  const target = join(HOME, ".gitignore");
  const gitConfig = (() => {
    try {
      if (Deno.lstatSync(target).isSymlink) return {};
      return ini.parse(Deno.readTextFileSync(target));
    } catch (_) {
      return {};
    }
  })();

  Deno.writeTextFileSync(
    target,
    ini.stringify({
      ...gitConfig,
      ...{
        include: { path: sharedFile },
        init: { defaultBranch: "main" },
      },
    }),
  );
}

if (import.meta.main) {
  const backupDir = makeBuckupDirectory();
  console.log(blue("Linking to home directory ..."));
  linkToHome()
    .forEach((task: Task) => link(task, backupDir));

  console.log(blue("Linking to config directory ..."));
  linkToConfig()
    .forEach((task: Task) => link(task, backupDir));

  console.log(blue("Including shared config ..."));
  writeGitConfig(
    join(DOTDIR, ".gitconfig_shared"),
  );

  console.log(blue("DONE"));
}

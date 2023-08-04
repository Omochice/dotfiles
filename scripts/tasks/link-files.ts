import $, { PathRef } from "https://deno.land/x/dax@0.33.0/mod.ts";
import ini from "npm:ini@4.1.1";
import { blue } from "https://deno.land/std@0.197.0/fmt/colors.ts";

type Task = { from: PathRef; to: PathRef };

const IGNOREDOTS = new Set([
  ".git",
  ".github",
  ".gitignore",
]);

const DOTDIR = $.path(import.meta.url).join("..", "..", "..");
const HOME = $.path(Deno.env.get("HOME") ?? "~");
const CONFIG = $.path(Deno.env.get("XDG_CONFIG_HOME") ?? HOME.join(".config"));

function isDotfile(path: string): boolean {
  const base = $.path.basename(path);
  return base.startsWith(".") && !(IGNOREDOTS.has(base));
}

async function makeBuckupDirectory(
  dir = HOME.join(".cache", "dotbackup").toString(),
): Promise<string> {
  await $.path(dir).mkdir({ recursive: true });
  return Deno.makeTempDir({ dir });
}

async function link(
  task: Task,
  backupDirectory: string,
): Promise<void> {
  if (task.to.existsSync()) {
    if (task.to.isSymlink()) {
      // NOTE: if symlink exists, unlink it.
      Deno.removeSync(task.to.toFileUrl());
    } else {
      await task.to.rename(
        $.path(backupDirectory).join(task.to.basename()),
      );
    }
  }

  Deno.symlink(task.from.toFileUrl(), task.to.toFileUrl());
}

function linkToHomeTasks(): Task[] {
  return Array.from(Deno.readDirSync(DOTDIR.toFileUrl()))
    .filter((d: Deno.DirEntry) => isDotfile(d.name))
    .map((d: Deno.DirEntry) => ({
      from: DOTDIR.join(d.name),
      to: HOME.join(d.name),
    }));
}

function linkToConfigTasks(): Task[] {
  const base = DOTDIR.join("config");
  return Array.from(
    Deno.readDirSync(base.toFileUrl()),
  ).map((d) => ({ from: base.join(d.name), to: CONFIG.join(d.name) }));
}

function writeGitConfig(sharedFile: PathRef): void {
  const target = HOME.join(".gitconfig");
  const empty = {};
  const gitConfig = (() => {
    try {
      if (!target.exists()) return empty;
      return ini.parse(Deno.readTextFileSync(target.toFileUrl()));
    } catch (_) {
      return empty;
    }
  })();

  Deno.writeTextFileSync(
    target.toFileUrl(),
    ini.stringify({
      ...gitConfig,
      ...{
        include: { path: sharedFile },
        init: { defaultBranch: "main" },
      },
    }),
  );
}

async function main(): Promise<void> {
  const backupDir = await makeBuckupDirectory();
  $.log(blue("Linking to home directory ..."));
  linkToHomeTasks()
    .forEach((task: Task) => link(task, backupDir));

  $.log(blue("Linking to config directory ..."));
  linkToConfigTasks()
    .forEach((task: Task) => link(task, backupDir));

  $.log(blue("Including shared config ..."));
  writeGitConfig(
    DOTDIR.join(".gitconfig_shared"),
  );
  $.log(blue("DONE"));
}

if (import.meta.main) {
  await main();
}

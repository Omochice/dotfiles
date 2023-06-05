import $, { PathRef } from "https://deno.land/x/dax@0.31.1/mod.ts";
import { ensureInstalled } from "./install-brew.ts";

const HOME = $.path(Deno.env.get("HOME") ?? "~");
const pullTo = HOME.join("Tools", "neovim");
const installTo = HOME.join(".local", "nvim");

async function build(): Promise<void> {
  await $`make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${installTo.toString()}`
    .cwd(pullTo).quiet();
}

async function sync(): Promise<void> {
  const gitUrl = new URL("https://github.com/neovim/neovim.git");
  if (pullTo.existsSync()) {
    await $`git pull`.cwd(pullTo).quiet();
  } else {
    await $`git clone ${gitUrl.href} ${pullTo.toString()} --depth=1`.quiet();
  }
}

async function clean(): Promise<void> {
  await $`make clean`.cwd(pullTo).quiet();
}

async function deleteUnneededs(): Promise<void> {
  const runtimeDir = installTo.join("share", "nvim", "runtime");
  const pluginDir = runtimeDir.join("plugin");
  const files: PathRef[] = [
    "gzip.vim",
    "health.vim",
    "matchit.vim",
    "matchparen.vim",
    "netrwPlugin.vim",
    "shada.vim",
    "spellfile.vim",
    "tarPlugin.vim",
    "tohtml.vim",
    "tutor.vim",
    "zipPlugin.vim",
  ].map((f) => pluginDir.join(f));

  files.push($.path("/").join("etc", "xdg", "nvim", "sysinit.vim"));
  files.push($.path("/").join("usr", "share", "nvim", "archlinux"));
  const shared = $.path("/").join("usr", "share", "vim", "vimfiles", "plugin");
  if (shared.existsSync()) {
    for await (const entry of shared.walk()) {
      files.push(entry.path);
    }
  }
  await Promise.all(files.map(
    (f) => {
      if (!f.existsSync()) {
        return;
      }
      $`rm ${f.toString()}`;
    },
  ));
}

async function main(): Promise<void> {
  await $.progress("ensure `brew` command installed")
    .with(
      ensureInstalled,
    );
  await $.progress("sync with neovim/neovim")
    .with(
      sync,
    );
  await $.progress("build nvim")
    .with(
      async () => {
        await clean();
        await build();
      },
    );
  await $.progress("delete unneeded plugins")
    .with(
      deleteUnneededs,
    );
}

if (import.meta.main) {
  await main();
}

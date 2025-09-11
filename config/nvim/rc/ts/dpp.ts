import type {
  ContextBuilder,
  ExtOptions,
  Plugin,
} from "jsr:@shougo/dpp-vim@5.0.0/types";
import {
  BaseConfig,
  type ConfigReturn,
  type MultipleHook,
} from "jsr:@shougo/dpp-vim@5.0.0/config";
import type { Protocol } from "jsr:@shougo/dpp-vim@5.0.0/protocol";
import type {
  Ext as LazyExt,
  Params as LazyParams,
} from "jsr:@shougo/dpp-ext-lazy@1.5.0";
import type {
  Ext as TomlExt,
  Params as TomlParams,
  Toml as DppToml,
} from "jsr:@shougo/dpp-ext-toml@1.3.0";
import type { Denops } from "jsr:@denops/std@7.6.0";

type ConfigArgument = {
  denops: Denops;
  contextBuilder: ContextBuilder;
  basePath: string;
};

/**
 * The object to represent Toml config.
 */
type Toml = {
  /** The path to the toml file */
  path: string;
  /** Whether the toml file should be loading laziely */
  lazy: boolean;
};

/**
 * The expected dpp extension object.
 */
type Extension = {
  /** dpp-ext-toml */
  toml: [TomlExt, ExtOptions, TomlParams];
  /** dpp-ext-lazy */
  lazy: [LazyExt, ExtOptions, LazyParams];
};

/**
 * The object to represent filetype plugin.
 */
type FiletypePlugin = {
  /** target filetype */
  filetype: string;
  /** executable Vim script */
  ftplugin: string;
};

/**
 * Normalize ftplugin code into Vim script.
 *
 * @param plugin ftplugins object
 * @returns Normalized ftplugins objects
 * @example
 * ```typescript
 * import { expect } from "jsr:@std/expect@1.0.17";
 *
 * expect(normalizeFtp({ "lua_lua": "print('foo')" }))
 *   .toEqual([{ filetype: "lua", ftplugin: "lua <<EOF\nprint('foo')\nEOF\n" }])
 *
 * expect(normalizeFtp({ "lua": "echomsg 'foo'" }))
 *   .toEqual([{ filetype: "lua", ftplugin: "echomsg 'foo'" }])
 *
 * expect(normalizeFtp({
 *   "lua": "echomsg 'foo'",
 *   "lua_lua": "print('foo')"
 * }))
 *   .toEqual([
 *     { filetype: "lua", ftplugin: "echomsg 'foo'" },
 *     { filetype: "lua", ftplugin: "lua <<EOF\nprint('foo')\nEOF\n" },
 *   ])
 * ```
 */
export function normalizeFtp(plugin: DppToml["ftplugins"]): FiletypePlugin[] {
  if (plugin == null) return [];
  return Object.entries(plugin)
    .map<FiletypePlugin>(([ft, ftp]) => {
      return {
        filetype: ft.replace(/^lua_/, ""),
        ftplugin: ft.startsWith("lua_") ? `lua <<EOF\n${ftp}\nEOF\n` : ftp,
      };
    });
}

/**
 * The wrapper function to get extension by `denops.dispatcher.getExt`.
 *
 * @param denops Denops instance
 * @param name The extension name
 * @returns The extension instances
 * @throws Error if the extension is not found
 */
async function getExtension<T extends keyof Extension>(
  denops: Denops,
  name: T,
): Promise<Extension[T]> {
  const ext = await denops.dispatcher.getExt(name) as Extension[T];
  if (ext.at(0) == null) {
    throw new Error(`Extension "${name}" is not found`);
  }
  return ext as Extension[T];
}

const inlineVimrcs = [
  "~/.config/nvim/vimrc.core",
  "~/.config/nvim/rc/disable_plugin.vim",
] as const satisfies string[];

const tomlFiles = [
  { path: "~/.config/nvim/rc/dpp.toml", lazy: false },
  { path: "~/.config/nvim/rc/non-lazy.toml", lazy: false },
  { path: "~/.config/nvim/rc/colorscheme.toml", lazy: false },
  { path: "~/.config/nvim/rc/lazy.toml", lazy: true },
  { path: "~/.config/nvim/rc/denops.toml", lazy: true },
  { path: "~/.config/nvim/rc/ddc.toml", lazy: true },
  { path: "~/.config/nvim/rc/ddu.toml", lazy: true },
  { path: "~/.config/nvim/rc/tataku.toml", lazy: true },
] as const satisfies Toml[];

export class Config extends BaseConfig {
  override async config(
    { denops, contextBuilder }: ConfigArgument,
  ): Promise<ConfigReturn> {
    contextBuilder.setGlobal({
      inlineVimrcs,
      protocols: ["git"],
    });

    const [context, options] = await contextBuilder.get(denops);
    const protocols = await denops.dispatcher.getProtocols() as Record<
      string,
      Protocol
    >;

    const [tomlExt, tomlOptions, tomlParams] = await getExtension(
      denops,
      "toml",
    );
    const tomls = await Promise.all(
      tomlFiles.map(({ path, lazy }) =>
        tomlExt.actions.load.callback({
          denops,
          context,
          options,
          protocols,
          extOptions: tomlOptions,
          extParams: tomlParams,
          actionParams: {
            path,
            options: {
              lazy,
            },
          },
        })
      ),
    );

    const recordPlugins = new Map<string, Plugin>(
      tomls
        .flatMap((toml) => toml.plugins ?? [])
        .map((plugin) => [plugin.name, plugin]),
    );
    const ftpluginMap = tomls
      .flatMap((toml) => normalizeFtp(toml.ftplugins))
      .reduce((m, { filetype, ftplugin }) => {
        return m.set(
          filetype,
          [...(m.get(filetype) ?? []), ftplugin],
        );
      }, new Map<string, string[]>());

    const multipleHooks: MultipleHook[] = tomls.reduce(
      (acc, toml) => acc.concat(toml.multiple_hooks ?? []),
      [] as MultipleHook[],
    );
    const hooksFiles = tomls
      .map((toml) => toml.hooks_file)
      .filter((x) => x != null);

    const [lazyExt, lazyOptions, lazyParams] = await getExtension(
      denops,
      "lazy",
    );
    const { plugins, stateLines } = await lazyExt.actions.makeState.callback({
      denops,
      context,
      options,
      protocols,
      extOptions: lazyOptions,
      extParams: lazyParams,
      actionParams: {
        plugins: recordPlugins.values().toArray(),
      },
    });

    return {
      ftplugins: Object.fromEntries(
        ftpluginMap
          .entries()
          .map(([k, v]) => [k, v.join("\n")]),
      ),
      hooksFiles,
      multipleHooks,
      plugins,
      stateLines,
    };
  }
}

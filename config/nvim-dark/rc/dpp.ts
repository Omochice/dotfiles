import {
  type ContextBuilder,
  type ExtOptions,
  type Plugin,
} from "jsr:@shougo/dpp-vim@3.0.0/types";
import {
  BaseConfig,
  type ConfigReturn,
  type MultipleHook,
} from "jsr:@shougo/dpp-vim@3.0.0/config";
import { Protocol } from "jsr:@shougo/dpp-vim@3.0.0/protocol";

import type {
  Ext as LazyExt,
  LazyMakeStateResult,
  Params as LazyParams,
} from "jsr:@shougo/dpp-ext-lazy@1.5.0";
import type {
  Ext as LocalExt,
  Params as LocalParams,
} from "jsr:@shougo/dpp-ext-local@1.3.0";
import type {
  Ext as PackspecExt,
  Params as PackspecParams,
} from "jsr:@shougo/dpp-ext-packspec@1.3.0";
import type {
  Ext as TomlExt,
  Params as TomlParams,
} from "jsr:@shougo/dpp-ext-toml@1.3.0";
import { mergeFtplugins } from "jsr:@shougo/dpp-vim@3.0.0/utils";

import type { Denops } from "jsr:@denops/std@7.1.0";
import * as fn from "jsr:@denops/std@~7.1.0/function";

import { expandGlob } from "jsr:@std/fs@~1.0.0/expand-glob";

type ConfigArgument = {
  denops: Denops;
  contextBuilder: ContextBuilder;
  basePath: string;
};

type Toml = {
  path: string;
  lazy: boolean;
};

type Extension = {
  toml: [TomlExt, ExtOptions, TomlParams];
  lazy: [LazyExt, ExtOptions, LazyParams];
};

/**
 * The wrapper function to get extension by `denops.dispatcher.getExt`.
 *
 * @param denops Denops instance
 * @param name The extension name
 * @returns The extension instances, if not found, throw an error
 */
async function getExtension<T extends keyof Extension>(
  denops: Denops,
  name: T,
): Promise<Extension[T]> {
  const [e, ...rest] = await denops.dispatcher.getExt(name) as Extension[T];
  if (e == null) {
    throw new Error("Extension is not found");
  }
  return [e, ...rest] as Extension[T];
}

const inlineVimrcs = [
  "~/.config/vim/vimrc.core",
] as const satisfies string[];

const tomlBaseDir = "~/.config/nvim/rc";

const tomls: Toml[] = [
  { path: `${tomlBaseDir}/dein.toml`, lazy: false },
  { path: `${tomlBaseDir}/deinft.toml`, lazy: false },
  { path: `${tomlBaseDir}/dein_lazy.toml`, lazy: true },
  { path: `${tomlBaseDir}/dein_denops.toml`, lazy: true },
  { path: `${tomlBaseDir}/ddc.toml`, lazy: true },
  { path: `${tomlBaseDir}/ddu.toml`, lazy: true },
] as const;

export class Config extends BaseConfig {
  override async config(
    { denops, contextBuilder }: ConfigArgument,
  ): Promise<ConfigReturn> {
    const hasNvim = denops.meta.host === "nvim";
    contextBuilder.setGlobal({
      inlineVimrcs,
      protocols: ["git"],
    });

    const [context, options] = await contextBuilder.get(denops);
    const protocols = await denops.dispatcher.getProtocols() as Record<
      string,
      Protocol
    >;

    console.log(protocols);

    const recordPlugins: Record<string, Plugin> = {};
    const ftplugins: Record<string, string> = {};
    const hooksFiles: string[] = [];
    let multipleHooks: MultipleHook[] = [];

    const [tomlExt, tomlOptions, tomlParams] = await getExtension(
      denops,
      "toml",
    );
    const action = tomlExt.actions.load;

    const t = await Promise.all(
      tomls.map(({ path, lazy }) =>
        action.callback({
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
    // t.flatMap((x) => x.plugins ?? [])
    //   .forEach((x) => {
    //     x
    //   });

    // / Merge toml results
    for (const toml of t) {
      for (const plugin of toml.plugins ?? []) {
        recordPlugins[plugin.name] = plugin;
      }

      if (toml.ftplugins) {
        mergeFtplugins(ftplugins, toml.ftplugins);
      }

      if (toml.multiple_hooks) {
        multipleHooks = multipleHooks.concat(toml.multiple_hooks);
      }

      if (toml.hooks_file) {
        hooksFiles.push(toml.hooks_file);
      }
    }

    // console.log(JSON.stringify(recordPlugins, null, 2));
    // console.log(JSON.stringify(hooksFiles, null, 2));
    // console.log(JSON.stringify(ftplugins, null, 2));
    //     }}}
    const [lazyExt, lazyOptions, lazyParams] = await getExtension(
      denops,
      "lazy",
    );
    const aaction = lazyExt.actions.makeState;

    const lazyResult = await aaction.callback({
      denops,
      context,
      options,
      protocols,
      extOptions: lazyOptions,
      extParams: lazyParams,
      actionParams: {
        plugins: Object.values(recordPlugins),
      },
    });

    // const checkFiles = Promise.all([
    //
    // ])
    // for await (const file of expandGlob(`${Deno.env.get("BASE_DIR")}/*`)) {
    //   checkFiles.push(file.path);
    // }

    return {
      ftplugins,
      hooksFiles,
      multipleHooks,
      plugins: lazyResult?.plugins ?? [],
      stateLines: lazyResult?.stateLines ?? [],
    };
  }
}

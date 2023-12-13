import { BaseConfig } from "https://deno.land/x/ddc_vim@v4.3.1/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddc_vim@v4.3.1/base/config.ts";

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "pum",
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
      ],
      backspaceCompletion: true,
      sources: ["lsp", "around", "buffer", "rg"],
      sourceOptions: {
        _: {
          matchers: ["matcher_fuzzy"],
          sorters: ["sorter_fuzzy"],
          converters: ["converter_remove_overlap", "converter_truncate_abbr"],
          minAutoCompleteLength: 2,
          ignoreCase: true,
        },
        around: {
          mark: "[Ard]",
        },
        buffer: {
          mark: "[Buf]",
        },
        necovim: {
          mark: "[Nec]",
        },
        lsp: {
          mark: "[LSP]",
          forceCompletionPattern: "\\.\\w*|:\\w*|->\\w*",
        },
        "vim-lsp": {
          mark: "[LSP]",
          isVolatile: true,
          forceCompletionPattern: "\\..?|:|->|\\w+/",
        },
        file: {
          mark: "[Fil]",
          isVolatile: true,
          forceCompletionPattern: "\\S/\\S*",
        },
        rg: {
          mark: "[Rg]",
          minAutoCompleteLength: 4,
          maxItems: 20,
        },
        vsnip: {
          mark: "[Snp]",
        },
        line: {
          mark: "[Lin]",
        },
      },
      sourceParams: {
        lines: {
          maxSize: 1000,
        },
        lsp: {
          snippetEngine: async (body: string) => {
            await args.denops.call("vsnip#snonymous", body);
          },
          enagbleResolveItem: true,
          enableAdditionalTextEdit: true,
        },
      },
    });

    for (const ft of ["toml", "vim"]) {
      args.contextBuilder.patchFiletype(ft, {
        sources: ["necovim", "lsp", "around", "buffer", "rg"],
      });
    }
    for (const ft of ["markdown"]) {
      args.contextBuilder.patchFiletype(ft, {
        sources: ["file", "around", "buffer", "rg"],
      });
    }
    return await Promise.resolve();
  }
}

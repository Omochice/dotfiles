import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddc-vim@9.5.0/config";
import type { DdcOptions } from "jsr:@shougo/ddc-vim@9.5.0/types";

type FiletypePatch = [string[], Partial<DdcOptions>];

const filetypePatches = [
  [["vim", "toml"], {
    sources: ["necovim", "lsp", "around", "buffer", "rg"],
  }],
  [["markdown"], {
    sources: ["file", "around", "buffer", "rg"],
  }],
  [["gitcommit"], {
    sources: ["file", "around", "buffer", "rg"],
    sourceOptions: {
      _: {
        // NOTE: include `-` like `Co-authored-by`
        keywordPattern: "[a-zA-Z_-]+",
      },
    },
  }],
] as const satisfies FiletypePatch[];

export class Config extends BaseConfig {
  override async config(
    { denops, contextBuilder }: ConfigArguments,
  ): Promise<void> {
    const globalPatch = {
      specialBufferCompletion: true,
      ui: "pum",
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
      ],
      backspaceCompletion: true,
      sources: [
        "lsp",
        "around",
        "buffer",
        "rg",
        Deno.env.get("COPILOT_DISABLE") === undefined ? "copilot" : "",
      ].filter((e) => e !== ""),
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
          forceCompletionPattern: String.raw`\.\w*|:\w*|->\w*`,
        },
        "vim-lsp": {
          mark: "[LSP]",
          isVolatile: true,
          forceCompletionPattern: String.raw`\..?|:|->|\w+/`,
        },
        file: {
          mark: "[Fil]",
          isVolatile: true,
          forceCompletionPattern: String.raw`\\S/\\S*`,
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
        copilot: {
          mark: "[Cop]",
          matchers: [],
          minAutoCompleteLength: 0,
          isVolatile: false,
        },
        skkeleton: {
          mark: "[SKK]",
          matchers: [],
          sorters: [],
          converters: [],
          isVolatile: true,
          minAutoCompleteLength: 1,
        },
      },
      sourceParams: {
        lines: {
          maxSize: 1000,
        },
        lsp: {
          snippetEngine: async (body: string) => {
            await denops.call("vsnip#anonymous", body);
          },
          enagbleResolveItem: true,
          enableAdditionalTextEdit: true,
        },
        copilot: {
          copilot: "lua",
        },
      },
    } as const satisfies Partial<DdcOptions>;

    contextBuilder.patchGlobal(globalPatch);
    for (const [fts, option] of filetypePatches) {
      for (const ft of fts) {
        contextBuilder.patchFiletype(ft, option);
      }
    }
    return await Promise.resolve();
  }
}

import { BaseConfig } from "https://deno.land/x/ddu_vim@v3.7.0/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddu_vim@v3.7.0/base/config.ts";

const border = ["┌", "─", "┐", "│", "┘", "─", "└", "│"] as const;

export class Config extends BaseConfig {
  override config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "ff",
      uiParams: {
        ff: {
          ignoreEmpty: true,
          split: "floating",
          filterSplitDirection: "floating",
          filterFloatingPosition: "top",
          prompt: ">",
          previewFloating: true,
          previewSplit: "vertical",
          startFilter: false,
          floatingBorder: border,
          previewFloatingBorder: "single",
        },
        filer: {
          sort: "filename",
          sortTreesFirst: true,
          split: "no",
          toggle: true,
        },
      },
      sourceOptions: {
        _: {
          ignoreCase: true,
          matchers: ["matcher_fzf"],
        },
      },
      sourceParams: {
        file_external: {
          cmd: [
            "fd",
            "--hidden",
            "--color",
            "never",
            "--type",
            "file",
            "--exclude",
            ".git",
          ],
        },
        rg: {
          rg: {
            matchers: ["converter_display_word", "matcher_fuzzy"],
          },
          args: ["--json", "--ignore-case"],
        },
        mru: {
          mr: {
            kind: "mrw",
            current: true,
          },
        },
        anyjump_definition: {
          removeCommentsFromResults: true,
        },
        anyjump_reference: {
          removeCommentsFromResults: true,
          onlyCurrentFiletype: false,
        },
      },
      filterParams: {
        matcher_fzf: {
          highlightMathced: "Search",
        },
        matcher_substring: {
          highlightMathced: "Search",
        },
      },
      kindOptions: {
        file: {
          defaultAction: "open",
        },
        "custom-list": {
          defaultAction: "callback",
        },
        lsp: {
          defaultAction: "open",
        },
        lsp_codeAction: {
          defaultAction: "apply",
        },
      },
    });
    return Promise.resolve();
  }
}

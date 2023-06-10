import { BaseConfig } from "https://deno.land/x/ddu_vim@v3.0.2/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddu_vim@v3.0.2/base/config.ts";

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
          startFilter: true,
          floatingBorder: border,
          previewFloatingBorder: border,
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
      },
    });
    return Promise.resolve();
  }
}

import { BaseConfig } from "https://deno.land/x/ddu_vim@v3.10.0/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddu_vim@v3.10.0/base/config.ts";
import { ensure, is } from "https://deno.land/x/unknownutil@v3.14.1/mod.ts";

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
        redmine_issue: is.String(Deno.env.get("REDMINE_ENDPOINT"))
          ? {
            endpoint: ensure(Deno.env.get("REDMINE_ENDPOINT"), is.String),
            apiKey: ensure(Deno.env.get("REDMINE_APIKEY"), is.String),
            onlyAsignedTo: "me",
          }
          : {},
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
        redmine_issue: {
          defaultAction: "note",
        },
        action: {
          defaultAction: "do",
        },
      },
      kindParams: {
        redmine_issue: {
          command: "tabedit",
        },
      },
    });
    return Promise.resolve();
  }
}

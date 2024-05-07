import { BaseConfig } from "https://deno.land/x/ddu_vim@v3.10.3/types.ts";
import type { Denops } from "https://deno.land/x/ddu_vim@v3.10.3/deps.ts";
import { ConfigArguments } from "https://deno.land/x/ddu_vim@v3.10.3/base/config.ts";
import { ensure, is } from "https://deno.land/x/unknownutil@v3.18.0/mod.ts";
import { o } from "https://deno.land/x/denops_std@v6.4.1/variable/option.ts";
import { group } from "https://deno.land/x/denops_std@v6.4.1/autocmd/mod.ts";
import { register } from "https://deno.land/x/denops_std@v6.4.1/lambda/mod.ts";

const border = ["┌", "─", "┐", "│", "┘", "─", "└", "│"] as const;

type Size = {
  lines: number;
  columns: number;
};

const state: Size = {
  lines: 0,
  columns: 0,
};

type DduSize = {
  winCol: number;
  winRow: number;
  winWidth: number;
  winHeight: number;
  previewCol: number;
  previewRow: number;
  previewWidth: number;
  previewHeight: number;
};

const updateState = async (denops: Denops) => {
  state.lines = await o.get(denops, "lines");
  state.columns = await o.get(denops, "columns");
};

const calcSize = (size: Size): DduSize => {
  const col = Math.floor(size.columns * 0.1);
  const row = Math.floor(size.lines * 0.1);
  const width = Math.floor(size.columns * 0.8);
  const height = Math.floor(size.lines * 0.8);
  // NOTE: character rect is not square
  return width >= height * 2
    ? {
      winCol: col,
      winRow: row,
      winWidth: width,
      winHeight: height,
      previewRow: row,
      previewCol: Math.floor(size.columns * 0.5),
      previewWidth: Math.floor(width * 0.5),
      previewHeight: height,
    }
    : {
      winCol: col,
      winRow: row,
      winWidth: width,
      winHeight: height,
      previewRow: Math.floor(size.lines * 0.5),
      previewCol: col,
      previewWidth: Math.floor(width),
      previewHeight: Math.floor(height * 0.5),
    };
};

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    await updateState(args.denops);
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
          ...calcSize(state),
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
    await group(args.denops, "vimrc#ddu", (helper) => {
      const id = register(args.denops, async () => {
        await updateState(args.denops);
        args.contextBuilder.patchGlobal({
          uiParams: { ff: calcSize(state) },
        });
      });
      helper.define(
        "WinResized",
        "*",
        `call denops#notify("${args.denops.name}", "${id}", [])`,
      );
    });
    return Promise.resolve();
  }
}

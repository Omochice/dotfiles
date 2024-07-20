import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddu-vim@5.0.0-pre6/config";
import type { Denops } from "jsr:@shougo/ddu-vim@5.0.0-pre6";
import { ensure, is } from "jsr:@core/unknownutil@3.18.1";
import { columns, lines } from "jsr:@denops/std@7.0.0-pre2/option";
import { group } from "jsr:@denops/std@7.0.0-pre2/autocmd";
import { register } from "jsr:@denops/std@7.0.0-pre2/lambda";

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
  state.lines = await lines.get(denops);
  state.columns = await columns.get(denops);
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

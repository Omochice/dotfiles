// NOTE: this based on https://github.com/vim-denops/denops-helloworld.vim/blob/f975281571191cfd4e3f9e5ba77103932f7dd6e5/denops/denops-helloworld/main.ts
import type { Entrypoint } from "jsr:@denops/std@8.2.0";
import { assert, is } from "jsr:@core/unknownutil@4.3.0";

// This exported `main` function is automatically called by denops.vim.
//
// Note that this function is called on Vim startup, so it should execute as quickly as possible.
// Try to avoid initialization code in this function; instead, define an `init` API and call it from Vim script.
export const main: Entrypoint = (denops) => {
  // Overwrite `dispatcher` to define APIs.
  //
  // APIs are invokable from Vim script through `denops#request()` or `denops#notify()`.
  // Refer to `:help denops#request()` or `:help denops#notify()` for more details.
  denops.dispatcher = {
    async init() {
      const { name } = denops;
      await denops.cmd(
        `command! -nargs=? DenopsHello echomsg denops#request('${name}', 'hello', [<q-args>])`,
      );
    },

    hello(name) {
      assert(name, is.String);
      return `Hello, ${name || "Denops"}!`;
    },
  };
};

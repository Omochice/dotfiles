import $ from "https://deno.land/x/dax@0.31.1/mod.ts";

export const ISWSL = /microsoft/.test(await $`uname --kernel-release`.text());

export const DOTDIR = $.path.dirname(
  $.path.dirname(
    $.path(import.meta.url).dirname(),
  ),
);

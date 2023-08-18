import $ from "https://deno.land/x/dax@0.34.0/mod.ts";

export const ISWSL = Deno.build.os === "linux" && /microsoft/.test(await $`uname --kernel-release`.text());

export const DOTDIR = $.path.dirname(
  $.path.dirname(
    $.path(import.meta.url).dirname(),
  ),
);

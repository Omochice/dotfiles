import $ from "https://deno.land/x/dax@0.39.2/mod.ts";
import { dirname } from "https://deno.land/std@0.224.0/path/dirname.ts";

export const ISWSL = Deno.build.os === "linux" &&
  /microsoft/.test(await $`uname --kernel-release`.text());

export const DOTDIR = dirname(
  dirname(
    dirname(import.meta.url),
  ),
);

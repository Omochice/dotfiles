import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import { dirname } from "https://deno.land/std@0.210.0/path/dirname.ts";

export const ISWSL = Deno.build.os === "linux" &&
  /microsoft/.test(await $`uname --kernel-release`.text());

export const DOTDIR = dirname(
  dirname(
    dirname(import.meta.url),
  ),
);

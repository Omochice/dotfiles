import $ from "https://deno.land/x/dax@0.37.1/mod.ts";
import { dirname } from "https://deno.land/std@0.218.2/path/dirname.ts";

export const ISWSL = Deno.build.os === "linux" &&
  /microsoft/.test(await $`uname --kernel-release`.text());

export const DOTDIR = dirname(
  dirname(
    dirname(import.meta.url),
  ),
);

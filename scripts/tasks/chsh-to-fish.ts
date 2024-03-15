import $ from "https://deno.land/x/dax@0.37.1/mod.ts";
import { ensureInstalled, getBrewPath } from "./install-brew.ts";
import { err, ok, Result } from "npm:neverthrow@6.1.0";
import { join } from "https://deno.land/std@0.220.1/path/join.ts";
import { dirname } from "https://deno.land/std@0.220.1/path/dirname.ts";

function getFishPath(): Result<string, Error> {
  const brewResult = getBrewPath();
  if (brewResult.isErr()) {
    return err(brewResult.error);
  }
  return ok(join(dirname(brewResult.value), "fish"));
}

async function chsh(): Promise<Result<void, Error>> {
  const fishPathResult = getFishPath();
  if (fishPathResult.isErr()) {
    return err(fishPathResult.error);
  }
  await $`sudo chsh --shell ${fishPathResult.value}`;
  return ok(undefined);
}

if (import.meta.main) {
  await ensureInstalled();
  const result = await chsh();
  if (result.isErr()) {
    console.error(result.error);
    Deno.exit(2);
  }
}

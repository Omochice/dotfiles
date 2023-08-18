import $ from "https://deno.land/x/dax@0.34.0/mod.ts";
import { ensureInstalled, getBrewPath } from "./install-brew.ts";
import { err, ok, Result } from "npm:neverthrow@6.0.0";

function getFishPath(): Result<string, Error> {
  const brewResult = getBrewPath();
  if (brewResult.isErr()) {
    return err(brewResult.error);
  }
  return ok($.path.join($.path.dirname(brewResult.value), "fish"));
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

import $ from "https://deno.land/x/dax@0.37.1/mod.ts";
import { getBrewPath } from "./install-brew.ts";
import { err, ok, Result } from "npm:neverthrow@7.0.1";

function getFishPath(): Result<string, Error> {
  const result = getBrewPath();
  if (result.isErr()) {
    return err(result.error);
  }

  const fishPath = $.path(result.value).parent()?.join("fish");
  if (fishPath === undefined || !fishPath.existsSync()) {
    return err(
      new Error(`Path of fish is missing...: ${fishPath?.toString()}`),
    );
  }

  return ok(fishPath.toString());
}

if (import.meta.main) {
  const result = getFishPath();
  if (result.isErr()) {
    console.error(result.error);
    Deno.exit(2);
  }
  console.log(result.value);
}

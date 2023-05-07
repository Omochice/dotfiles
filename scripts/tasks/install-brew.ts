import $ from "https://deno.land/x/dax@0.31.1/mod.ts";
import { err, ok, Result } from "npm:neverthrow@6.0.0";

export async function installBrew(): Promise<void> {
  const url = new URL(
    "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh",
  );
  const script = await $.request(url).text();

  const tmpFile = Deno.makeTempFileSync();
  Deno.writeTextFileSync(tmpFile, script);

  await $`bash ${tmpFile}`;
}

export function getBrewPath(): Result<string, Error> {
  if (Deno.build.os === "darwin") {
    if (Deno.build.arch === "aarch64") {
      const expected = $.path(
        $.path.join("/", "opt", "homebrew", "bin", "brew"),
      );
      if (expected.isFile()) {
        return ok(expected.toString());
      }
      return err(new Error(`${expected} is missing, maybe install yet`));
    }
    return err(new Error("Currently intel mac is not supported"));
  } else if (Deno.build.os === "linux") {
    const expected = $.path(
      $.path.join("/", "home", "linuxbrew", ".linuxbrew", "bin", "brew"),
    );
    if (expected.isFile()) {
      return ok(expected.toString());
    }
    return err(new Error(`${expected} is missing, maybe install yet`));
  }
  return err(new Error(`Currently ${Deno.build.os} is not supported`));
}

export async function ensureInstalled(): Promise<string> {
  const brewPath = getBrewPath();
  if (brewPath.isOk()) {
    return brewPath.value;
  }
  await installBrew();
  return await ensureInstalled();
}

async function main(): Promise<void> {
  if ((await $.which("brew")) != null) {
    $.log("brew is installed already");
    return;
  }
  await ensureInstalled();
}

if (import.meta.main) {
  await main();
}

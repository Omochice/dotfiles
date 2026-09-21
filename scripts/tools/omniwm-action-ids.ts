/**
 * Verify that config/omniwm/action-ids.json still lists every hotkey action of
 * the packaged OmniWM.
 *
 * OmniWM refuses a settings file whose `hotkeys` array omits an action it knows
 * about: it moves the file to settings.toml.corrupt and falls back to its own
 * defaults, silently discarding the configured bindings. Because renovate bumps
 * nixpkgs unattended, that would first be noticed as keyboard shortcuts having
 * stopped working. Failing here instead keeps the breakage inside the update.
 *
 * The ids are re-derived from OmniWM's own ActionCatalog.swift at the packaged
 * tag rather than from a copy, so a newly added action is detected even when it
 * is generated inside a loop.
 */
import { Command } from "jsr:@cliffy/command@1.3.1";

const CATALOG_PATH = "Sources/OmniWM/Core/Input/ActionCatalog.swift";

// `ScratchpadIndex.range` forwards to this file, so the numeric bounds of the
// scratchpad loop are only resolvable once it is read as well.
const RANGE_PATHS = ["Sources/OmniWMIPC/ScratchpadSlots.swift"];

type Range = { readonly start: number; readonly end: number };

/** Resolve the named or literal ranges a `for` header can carry. */
function parseRange(
  expression: string,
  declarations: string,
): Range | undefined {
  const literal = expression.match(/^(\d+)\s*(\.\.\.|\.\.<)\s*(\d+)$/);
  if (literal) {
    const start = Number(literal[1]);
    const last = Number(literal[3]);
    return { start, end: literal[2] === "..." ? last : last - 1 };
  }
  if (expression === "digitCodes.enumerated()") {
    const array = declarations.match(
      /digitCodes:\s*\[UInt32\]\s*=\s*\[([^\]]*)\]/,
    );
    if (!array) return undefined;
    const count = array[1].split(",").filter((entry) => entry.trim() !== "")
      .length;
    return { start: 0, end: count - 1 };
  }
  const named = expression.replace(/^[A-Za-z]+\./, "");
  const declaration = declarations.match(
    new RegExp(`\\b${named}\\s*=\\s*(\\d+)\\s*(\\.\\.\\.|\\.\\.<)\\s*(\\d+)`),
  );
  if (declaration) {
    const last = Number(declaration[3]);
    return {
      start: Number(declaration[1]),
      end: declaration[2] === "..." ? last : last - 1,
    };
  }
  return undefined;
}

/**
 * Collect every hotkey action id the given ActionCatalog.swift declares.
 *
 * Ids generated inside a `for` loop are expanded over the loop's range; actions
 * marked `visibility: .unassignable` are dropped, because OmniWM excludes them
 * from the bindings a settings file may list.
 */
export function collectActionIds(
  source: string,
  declarations: string = source,
): string[] {
  const lines = source.split("\n");
  const loops: { variable: string; range: Range; depth: number }[] = [];
  const ids = new Set<string>();
  let depth = 0;

  for (const [index, line] of lines.entries()) {
    const header = line.match(
      /for\s+(?:\(\s*(\w+)\s*,[^)]*\)|(\w+))\s+in\s+(.+?)\s*\{/,
    );
    if (header) {
      const variable = header[1] ?? header[2];
      const range = parseRange(header[3], declarations);
      if (range) loops.push({ variable, range, depth });
    }

    const declaration = line.match(/\bid:\s*"([^"]+)"/);
    if (declaration) {
      const followUp = lines.slice(index + 1, index + 9);
      const body = followUp.slice(
        0,
        followUp.findIndex((entry) => /\bid:\s*"/.test(entry)) + 1 || undefined,
      );
      if (!body.some((entry) => entry.includes("visibility: .unassignable"))) {
        for (const id of expand(declaration[1], loops)) ids.add(id);
      }
    }

    depth += (line.match(/\{/g) ?? []).length -
      (line.match(/\}/g) ?? []).length;
    while (loops.length > 0 && loops[loops.length - 1].depth >= depth) {
      loops.pop();
    }
  }

  return [...ids].sort();
}

function expand(
  template: string,
  loops: readonly { variable: string; range: Range }[],
): string[] {
  const interpolation = template.match(/\\\((\w+)\)/);
  if (!interpolation) return [template];
  const loop = loops.find((entry) => entry.variable === interpolation[1]);
  if (!loop) {
    throw new Error(`No loop in scope for interpolated action id: ${template}`);
  }
  const values = Array.from(
    { length: loop.range.end - loop.range.start + 1 },
    (_, offset) => loop.range.start + offset,
  );
  return values.flatMap((value) =>
    expand(template.replace(/\\\(\w+\)/, String(value)), loops)
  );
}

async function fetchSource(version: string, path: string): Promise<string> {
  const url =
    `https://raw.githubusercontent.com/BarutSRB/OmniWM/v${version}/${path}`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status}`);
  }
  return await response.text();
}

async function main(version: string, listPath: string): Promise<void> {
  const expected = JSON.parse(await Deno.readTextFile(listPath)) as string[];
  const catalog = await fetchSource(version, CATALOG_PATH);
  const extra = await Promise.all(
    RANGE_PATHS.map((path) => fetchSource(version, path)),
  );
  const actual = collectActionIds(catalog, [catalog, ...extra].join("\n"));

  const missing = actual.filter((id) => !expected.includes(id));
  const retired = expected.filter((id) => !actual.includes(id));
  if (missing.length === 0 && retired.length === 0) {
    console.log(`OmniWM ${version}: ${actual.length} action ids match.`);
    return;
  }

  for (const id of missing) console.error(`missing from ${listPath}: ${id}`);
  for (const id of retired) console.error(`no longer an action: ${id}`);
  console.error(
    `Update ${listPath}, then assign or leave unassigned the new actions.`,
  );
  Deno.exit(1);
}

if (import.meta.main) {
  await new Command()
    .name("omniwm-action-ids")
    .description(
      "Check the recorded OmniWM action ids against a released version",
    )
    .option(
      "--version-tag <version:string>",
      "OmniWM version to check against",
      {
        required: true,
      },
    )
    .option("--list <path:string>", "Path to action-ids.json", {
      default: "config/omniwm/action-ids.json",
    })
    .action(({ versionTag, list }) => main(versionTag, list))
    .parse(Deno.args);
}

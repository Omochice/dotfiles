/**
 * Gather every tiled OmniWM window into one workspace, ordered by PRIORITY
 * and then by app name.
 *
 * Usage: omniwm-gather [WORKSPACE]  (defaults to the active workspace)
 */

const OMNIWMCTL = Deno.env.get("OMNIWMCTL") ?? "omniwmctl";

const PRIORITY = [
  "com.github.wez.wezterm",
  "com.vivaldi.Vivaldi",
  "com.microsoft.teams2",
  "com.tinyspeck.slackmacgap",
];

type Response<T> = {
  ok: boolean;
  message?: string;
  result?: { payload: T };
};

type Window = {
  id: string;
  mode: "tiling" | "floating";
  isScratchpad: boolean;
  isFocused: boolean;
  workspace: { number: number };
};

type WorkspaceBar = {
  monitors: {
    workspaces: {
      number: number;
      windows: {
        appName: string;
        bundleId: string;
        allWindows: { id: string }[];
      }[];
    }[];
  }[];
};

type Column = { id: string; appName: string; rank: number };

async function ctl<T>(...args: string[]): Promise<Response<T>> {
  const { stdout } = await new Deno.Command(OMNIWMCTL, {
    args: [...args, "--json"],
  }).output();
  return JSON.parse(new TextDecoder().decode(stdout));
}

async function query<T>(kind: string): Promise<T> {
  const response = await ctl<T>("query", kind);
  if (!response.ok || !response.result) {
    throw new Error(`omniwmctl query ${kind}: ${response.message}`);
  }
  return response.result.payload;
}

/** Return the indices of one longest strictly increasing subsequence. */
export function longestIncreasingSubsequence(values: number[]): number[] {
  const best = values.map(() => 1);
  const prev: (number | undefined)[] = values.map(() => undefined);
  for (const [i, value] of values.entries()) {
    for (let j = 0; j < i; j++) {
      if (values[j] < value && best[j] + 1 > best[i]) {
        best[i] = best[j] + 1;
        prev[i] = j;
      }
    }
  }
  const chain: number[] = [];
  let index: number | undefined = best.indexOf(Math.max(...best));
  while (index !== undefined && index >= 0) {
    chain.push(index);
    index = prev[index];
  }
  return chain;
}

/**
 * Plan the fewest `move-column-to-index` moves that turn `current` into
 * `order`: columns on a longest increasing subsequence stay, the rest are
 * inserted after their predecessor. Indices are 1-based final positions.
 */
export function planMoves(
  current: string[],
  order: string[],
): { id: string; index: number }[] {
  const ranks = current.map((id) => order.indexOf(id));
  const fixed = new Set(
    longestIncreasingSubsequence(ranks).map((i) => current[i]),
  );
  const sequence = [...current];
  const moves = [];
  for (const [k, id] of order.entries()) {
    if (fixed.has(id)) continue;
    const after = k === 0 ? -1 : sequence.indexOf(order[k - 1]);
    const origin = sequence.indexOf(id);
    const destination = origin > after ? after + 1 : after;
    sequence.splice(origin, 1);
    sequence.splice(destination, 0, id);
    moves.push({ id, index: destination + 1 });
  }
  return moves;
}

function rank(bundleId: string): number {
  const index = PRIORITY.indexOf(bundleId);
  return index === -1 ? PRIORITY.length : index;
}

/**
 * Tiled columns of the target workspace in their current order,
 * read from the workspace bar because window frames are stale right after a move.
 * The bar folds same-app windows into one entry, so they are assumed adjacent.
 */
async function barColumns(
  target: number,
  tiling: Set<string>,
): Promise<Column[]> {
  const bar = await query<WorkspaceBar>("workspace-bar");
  return bar.monitors
    .flatMap((monitor) => monitor.workspaces)
    .filter((workspace) => workspace.number === target)
    .flatMap((workspace) => workspace.windows)
    .flatMap((entry) =>
      entry.allWindows
        .filter((window) => tiling.has(window.id))
        .map((window) => ({
          id: window.id,
          appName: entry.appName,
          rank: rank(entry.bundleId),
        }))
    );
}

async function main() {
  const target = Deno.args.length > 0
    ? Number(Deno.args[0])
    : (await query<{ workspace: { number: number } }>("active-workspace"))
      .workspace.number;

  const windows = (await query<{ windows: Window[] }>("windows")).windows
    .filter((window) => window.mode === "tiling" && !window.isScratchpad);
  if (windows.length === 0) return;
  const focused = windows.find((window) => window.isFocused)?.id;
  for (const window of windows) {
    if (window.workspace.number !== target) {
      await ctl("window", "move-to-workspace", window.id, String(target));
    }
  }

  const columns = await barColumns(
    target,
    new Set(windows.map((window) => window.id)),
  );
  const order = columns
    .toSorted((a, b) => a.rank - b.rank || a.appName.localeCompare(b.appName))
    .map((column) => column.id);
  for (const move of planMoves(columns.map((c) => c.id), order)) {
    await ctl("window", "focus", move.id);
    await ctl("command", "move-column-to-index", String(move.index));
  }

  if (focused) await ctl("window", "focus", focused);
}

if (import.meta.main) await main();

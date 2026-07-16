import { Command } from "jsr:@cliffy/command@1.2.1";
import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import {
  message,
  messageJson,
} from "../../config/karabiner/queries/yabai-client.ts";

/**
 * Target apps in space order. The 1-based position in this array is the space
 * index the app's windows are moved onto. Apps not listed fall through to
 * {@link OTHERS_SPACE}. Values MUST match yabai's `app` field exactly.
 */
const SPACE_APPS = [
  "WezTerm",
  "Vivaldi",
  "Slack",
  "Microsoft Teams",
  "Claude",
] as const satisfies string[];

const OTHERS_SPACE = SPACE_APPS.length + 1;

const isWindow = is.ObjectOf({
  id: is.Number,
  app: is.String,
  space: is.Number,
  "is-hidden": is.Boolean,
  "is-minimized": is.Boolean,
  "is-sticky": is.Boolean,
  "is-native-fullscreen": is.Boolean,
  "can-move": is.Boolean,
});

const isSpace = is.ObjectOf({
  index: is.Number,
});

/** Space index (1-based) that a window belonging to `app` should live on. */
function targetSpace(app: string): number {
  const index = SPACE_APPS.indexOf(app as (typeof SPACE_APPS)[number]);
  return index === -1 ? OTHERS_SPACE : index + 1;
}

async function main(dryRun: boolean): Promise<void> {
  const run = async (args: readonly string[]): Promise<void> => {
    if (dryRun) {
      console.debug(`$ yabai -m ${args.join(" ")}`);
      return;
    }
    await message(args);
  };

  const displays = ensure(await messageJson(["query", "--displays"]), is.Array);
  if (displays.length >= 2) {
    return;
  }

  const allWindows = ensure(
    await messageJson(["query", "--windows"]),
    is.ArrayOf(isWindow),
  );

  const fullscreenSpaces = new Set(
    allWindows.filter((w) => w["is-native-fullscreen"]).map((w) => w.space),
  );

  const windows = allWindows.filter((w) =>
    !w["is-hidden"] && !w["is-minimized"] && !w["is-sticky"] &&
    !w["is-native-fullscreen"] && w["can-move"]
  );

  // Only spaces up to the last occupied slot are needed.
  // A missing app before that slot leaves its space empty (a gap),
  // while empty slots after it are trailing and get destroyed below.
  const required = windows.length === 0
    ? 1
    : Math.max(...windows.map((w) => targetSpace(w.app)));

  const spaces = ensure(
    await messageJson(["query", "--spaces"]),
    is.ArrayOf(isSpace),
  );

  for (let count = spaces.length; count < required; count++) {
    await run(["space", "--create"]);
  }

  for (const window of windows) {
    const target = targetSpace(window.app);
    if (window.space !== target) {
      await run(["window", String(window.id), "--space", String(target)]);
    }
  }

  const trailing = spaces
    .map((space) => space.index)
    .filter((index) => index > required && !fullscreenSpaces.has(index))
    .sort((a, b) => b - a);
  for (const index of trailing) {
    await run(["space", String(index), "--destroy"]);
  }
}

if (import.meta.main) {
  const { options } = await new Command()
    .name(import.meta.url)
    .description("Arrange windows into a fixed per-app space layout")
    .option("--dry-run", "Dry run mode.", { default: false })
    .parse(Deno.args);

  await main(options.dryRun);
}

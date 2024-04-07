import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.4/command/mod.ts";
import $ from "https://deno.land/x/dax@0.37.1/mod.ts";
import {
  $array,
  $boolean,
  $number,
  $object,
  $string,
  type Infer,
} from "npm:lizod@0.2.7";

const isSpace = $object({
  id: $number,
  uuid: $string,
  index: $number,
  label: $string,
  type: $string,
  display: $number,
  windows: $array($number),
  "first-window": $number,
  "last-window": $number,
  "has-focus": $boolean,
  "is-visible": $boolean,
  "is-native-fullscreen": $boolean,
});

type Space = Infer<typeof isSpace>;

async function listEmptyTailSpaces(): Promise<Space[]> {
  const emptySpaces: Space[] = [];

  const spaces = await $`yabai --message query --spaces`.json();
  const ctx = { errors: [] };
  if (!$array(isSpace)(spaces, ctx)) {
    console.error("err", ctx);
    return emptySpaces;
  }

  for (
    const space of spaces
      .sort(compareSpace)
      .reverse()
  ) {
    if (space.windows.length > 0) {
      break;
    }
    emptySpaces.push(space);
  }
  return emptySpaces;
}

function compareSpace(a: Space, b: Space): number {
  return a.index - b.index;
}

if (import.meta.main) {
  const { options } = await new Command()
    .name(import.meta.url)
    .description("Clean tail empty spaces")
    .option("--dry-run", "Dry run mode.", { default: false })
    .parse(Deno.args);

  const emptySpaces = (await listEmptyTailSpaces())
    .toSorted(compareSpace)
    .reverse();

  for (const space of emptySpaces) {
    if (options.dryRun) {
      console.debug(`$ yabai --message space ${space.index} --destroy`);
    } else {
      await $`yabai --message space ${space.index} --destroy`.quiet();
    }
  }
}

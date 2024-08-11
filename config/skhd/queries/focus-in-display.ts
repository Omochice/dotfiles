import { $ } from "jsr:@david/dax@0.41.0";
import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@7.0.0";
import { is } from "jsr:@core/unknownutil@4.0.3";

const hasDisplays = is.ObjectOf({
  spaces: is.ArrayOf(is.Number),
});

const hasIndex = is.ObjectOf({
  index: is.Number,
});

const isWay = is.LiteralOneOf(["next", "prev"] as const);

if (import.meta.main) {
  const way = Deno.args[0];
  await ResultAsync.fromSafePromise(
    $`yabai -m query --displays --window`.json(),
  )
    .andThen((r) => {
      if (!isWay(way)) {
        return errAsync(new Error("Invalid way", { cause: way }));
      }
      if (!hasDisplays(r)) {
        return errAsync(new Error("Invalid yabai response"));
      }
      return ResultAsync.fromPromise(
        (async () => {
          const displays = await $`yabai --message query --spaces --window`
            .json();
          if (!is.ArrayOf(hasIndex)(displays)) {
            throw new Error("Invalid yabai response");
          }
          const s = new Set(displays.map((d) => d.index));
          if (s.size !== 1) {
            throw new Error("Expected one display");
          }
          return s.values().next().value;
        })(),
        (cause) => new Error("uexpected error", { cause }),
      )
        .andThen((spaceIndex) => {
          return okAsync(
            r.spaces.map((space) => ({
              space,
              isFocused: space === spaceIndex,
            })),
          );
        });
    })
    .andThen((spaces) => {
      if (spaces.every((s) => !s.isFocused)) {
        return errAsync(new Error("No focused space"));
      }
      if (spaces.length === 1) {
        return errAsync(new Error("Only one space"));
      }
      const focusedSpaceIndex = spaces.findIndex((s) => s.isFocused);
      const shouldFocues = focusedSpaceIndex + (way === "next" ? 1 : -1);
      if (shouldFocues < 0 || shouldFocues >= spaces.length) {
        return errAsync(new Error("No space to focus"));
      }
      return ResultAsync.fromPromise(
        $`yabai -m space --focus ${spaces[shouldFocues].space}`.quiet(),
        (cause) => new Error("uexpected error", { cause }),
      );
    });
}

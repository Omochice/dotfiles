import { $ } from "jsr:@david/dax@0.41.0";
import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@8.0.0";
import { ensure, is } from "jsr:@core/unknownutil@4.3.0";

const isSpaces = is.ArrayOf(is.ObjectOf({
  "has-focus": is.Boolean,
}));

const isWay = is.LiteralOneOf(["next", "prev"] as const);

if (import.meta.main) {
  const way = ensure(Deno.args[0], isWay);
  await ResultAsync.fromPromise(
    $`yabai -m query --spaces --display`.json(),
    (cause) =>
      new Error("Failed to exec 'yabai -m query --spaces --display'", {
        cause,
      }),
  )
    .andThen((r) => {
      return ResultAsync.fromPromise(
        Promise.resolve(ensure(r, isSpaces)),
        (cause) => new Error("Failed to ensure is space", { cause }),
      );
    })
    .andThen((spaces) => {
      const idx = way === "next" ? -1 : 0;
      const space = spaces.at(idx);
      if (space == null) {
        return errAsync(new Error("no space found"));
      }
      return okAsync(!space["has-focus"]);
    })
    .andThen((canFocus) => {
      if (!canFocus) {
        return okAsync(undefined);
      }
      return ResultAsync.fromPromise(
        $`yabai -m space --focus ${way}`.quiet(),
        (cause) =>
          new Error(`Failed to exec 'yabai -m space --focus ${way}'`, {
            cause,
          }),
      );
    })
    .match(
      () => {},
      (e) => {
        console.error(e);
      },
    );
}

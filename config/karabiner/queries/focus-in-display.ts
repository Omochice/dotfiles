import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@8.2.0";
import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { message, messageJson } from "./yabai-client.ts";

const isSpaces = is.ArrayOf(is.ObjectOf({
  "has-focus": is.Boolean,
}));

const isWay = is.LiteralOneOf(["next", "prev"] as const);

if (import.meta.main) {
  const way = ensure(Deno.args[0], isWay);
  await ResultAsync.fromPromise(
    messageJson(["query", "--spaces", "--display"]),
    (cause) =>
      new Error("Failed to run 'yabai query --spaces --display'", {
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
        message(["space", "--focus", way]),
        (cause) =>
          new Error(`Failed to run 'yabai space --focus ${way}'`, {
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

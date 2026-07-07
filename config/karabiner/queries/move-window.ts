import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { ResultAsync } from "npm:neverthrow@8.2.0";
import { message, messageJson } from "./yabai-client.ts";

const hasId = is.ObjectOf({
  id: is.Number,
});

if (import.meta.main) {
  const way = ensure(
    Deno.args[0],
    is.UnionOf([
      is.LiteralOf("west"),
      is.LiteralOf("east"),
      is.LiteralOf("north"),
      is.LiteralOf("south"),
    ]),
  );

  await ResultAsync.fromPromise(
    messageJson(["query", "--windows", "--window"]),
    (cause) =>
      new Error("Failed to run 'yabai query --windows --window'", { cause }),
  )
    .andThen((window) => {
      return ResultAsync.fromPromise(
        Promise.resolve(ensure(window, hasId)),
        (cause) => new Error("Failed to ensure hasId", { cause }),
      );
    })
    .andThen(({ id }) => {
      return ResultAsync.fromPromise(
        message(["window", "--swap", way]),
        (cause) =>
          new Error(`Failed to run 'yabai window --swap ${way}'`, { cause }),
      )
        .orElse(() =>
          ResultAsync.fromPromise(
            message(["window", "--display", way]),
            (cause) =>
              new Error(`Failed to run 'yabai window --display ${way}'`, {
                cause,
              }),
          )
            .andThen(() =>
              ResultAsync.fromPromise(
                message(["window", String(id), "--focus"]),
                (cause) =>
                  new Error(`Failed to run 'yabai window ${id} --focus'`, {
                    cause,
                  }),
              )
            )
        );
    })
    .match(
      () => {},
      (e) => console.error(e),
    );
}

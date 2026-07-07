import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { okAsync, ResultAsync } from "npm:neverthrow@8.2.0";
import { message, messageJson } from "./yabai-client.ts";

if (import.meta.main) {
  await ResultAsync.fromPromise(
    messageJson(["query", "--displays", "--display"]),
    (cause) =>
      new Error("Failed to run 'yabai query --displays --display'", { cause }),
  )
    .andThen((display) => {
      return ResultAsync.fromPromise(
        Promise.resolve(
          ensure(
            display,
            is.ObjectOf({
              index: is.Number,
              spaces: is.ArrayOf(is.Number),
            }),
          ),
        ),
        (cause) => new Error("Failed to ensure is array", { cause }),
      );
    })
    .andThen((display) => {
      const lastSpace = display.spaces.at(-1)!;
      return ResultAsync.fromPromise(
        messageJson(["query", "--spaces", "--space", String(lastSpace)]),
        (cause) =>
          new Error(
            `Failed to run 'yabai query --spaces --space ${lastSpace}'`,
            { cause },
          ),
      ).andThen((spaces) => {
        return ResultAsync.fromPromise(
          Promise.resolve(
            ensure(
              spaces,
              is.ObjectOf({ index: is.Number, windows: is.ArrayOf(is.Number) }),
            ),
          ),
          (cause) => new Error("Failed to ensure is array", { cause }),
        )
          .andThen((space) => {
            if (space.windows.length === 0) {
              return okAsync(space.index);
            } else {
              return ResultAsync.fromPromise(
                message(["space", "--create"]),
                (cause) =>
                  new Error("Failed to run 'yabai space --create'", { cause }),
              )
                .andThen(() => okAsync(space.index + 1));
            }
          })
          .andThen((index) => {
            return ResultAsync.fromPromise(
              message(["window", "--space", String(index)]),
              (cause) =>
                new Error(`Failed to run 'yabai window --space ${index}'`, {
                  cause,
                }),
            );
          });
      });
    })
    .match(
      () => {},
      (e) => {
        console.error(e);
      },
    );
}

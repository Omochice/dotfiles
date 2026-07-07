import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@8.2.0";
import { is } from "jsr:@core/unknownutil@4.3.0";
import { message, messageJson } from "./yabai-client.ts";

const isSpace = is.ObjectOf({
  windows: is.ArrayOf(is.Number),
});

if (import.meta.main) {
  await ResultAsync.fromPromise(
    message(["window", "--close"]),
    (cause) => new Error("Failed to run 'yabai window --close'", { cause }),
  )
    .andThen(() => {
      return ResultAsync.fromPromise(
        messageJson(["query", "--spaces", "--space"]),
        (cause) =>
          new Error("Failed to run 'yabai query --spaces --space'", {
            cause,
          }),
      );
    })
    .andThen((space) => {
      if (isSpace(space) && space.windows.at(0) != null) {
        return okAsync(space.windows.at(0)!);
      }
      return errAsync(new Error("Current space has not any window"));
    })
    .andThen((windowId) => {
      return ResultAsync.fromPromise(
        message(["window", "--focus", String(windowId)]),
        (cause) =>
          new Error(`Failed to run 'yabai window --focus ${windowId}'`, {
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

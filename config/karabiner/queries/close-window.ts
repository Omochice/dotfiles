import { $ } from "jsr:@david/dax@0.41.0";
import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@7.0.1";
import { is } from "jsr:@core/unknownutil@4.3.0";

const isSpace = is.ObjectOf({
  windows: is.ArrayOf(is.Number),
});

if (import.meta.main) {
  await ResultAsync.fromPromise(
    $`yabai -m window --close`.quiet(),
    (cause) => new Error("Failed to exec 'yabai -m window --close'", { cause }),
  )
    .andThen(() => {
      return ResultAsync.fromPromise(
        $`yabai -m query --spaces --space`.json(),
        (cause) =>
          new Error("Failed to exec 'yabai -m query --spaces --space'", {
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
        $`yabai -m window --focus ${windowId}`,
        (cause) =>
          new Error(`Failed to exec 'yabai -m window --focus ${windowId}'`, {
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

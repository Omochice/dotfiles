import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { $ } from "jsr:@david/dax@0.44.0";
import { okAsync, ResultAsync } from "npm:neverthrow@8.2.0";

if (import.meta.main) {
  await ResultAsync.fromPromise(
    $`yabai -m query --displays --display`.json(),
    (cause) => new Error("yabai -m query --displays --display", { cause }),
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
      return ResultAsync.fromPromise(
        $`yabai -m query --spaces --space ${display.spaces.at(-1)!}`.json(),
        (cause) =>
          new Error(
            `yabai -m query --spaces --space ${display.spaces.at(-1)!}`,
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
                $`yabai -m space --create`.text(),
                (cause) =>
                  new Error(
                    `yabai -m space --create`,
                    { cause },
                  ),
              )
                .andThen(() => okAsync(space.index + 1));
            }
          })
          .andThen((index) => {
            return ResultAsync.fromPromise(
              $`yabai -m window --space ${index}`,
              (cause) =>
                new Error(`yabai -m window --space ${index}`, { cause }),
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

import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { $ } from "jsr:@david/dax@0.41.0";
import { ResultAsync } from "npm:neverthrow@8.0.0";

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
    $`yabai --message query --windows --window`.json(),
    (cause) =>
      new Error("Failed to exec 'yabai --message query --windows --window'", {
        cause,
      }),
  )
    .andThen((window) => {
      return ResultAsync.fromPromise(
        Promise.resolve(ensure(window, hasId)),
        (cause) => new Error("Failed to ensure hasId", { cause }),
      );
    })
    .andThen(({ id }) => {
      return ResultAsync.fromPromise(
        $`yabai --message window --swap ${way}`.quiet(),
        (cause) =>
          new Error(`Failed to exec 'yabai --message window --swap ${way}'`, {
            cause,
          }),
      )
        .orElse(() =>
          ResultAsync.fromPromise(
            $`yabai --message window --display ${way}`.quiet(),
            (cause) =>
              new Error(
                `Failed to exec 'yabai --message window --display ${way}'`,
                { cause },
              ),
          )
            .andThen(() =>
              ResultAsync.fromPromise(
                $`yabai --message window ${id} --focus`.quiet(),
                (cause) =>
                  new Error(
                    `Failed to exec 'yabai --message window ${id} --focus'`,
                    { cause },
                  ),
              )
            )
        );
    })
    .match(
      () => {},
      (e) => console.error(e),
    );
}

import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { $ } from "jsr:@david/dax@0.41.0";
import { ResultAsync } from "npm:neverthrow@7.0.1";

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
    (cause) => new Error("unexpected error", { cause }),
  )
    .andThen((window) => {
      return ResultAsync.fromPromise(
        Promise.resolve(ensure(window, hasId)),
        (cause) => new Error("unexpected error", { cause }),
      );
    })
    .andThen(({ id }) => {
      return ResultAsync.fromPromise(
        $`yabai --message window --swap ${way}`.quiet(),
        (cause) => new Error("unexpected error", { cause }),
      )
        .orElse(() =>
          ResultAsync.fromPromise(
            $`yabai --message window --display ${way}`.quiet(),
            (cause) => new Error("unexpected error", { cause }),
          )
            .andThen(() =>
              ResultAsync.fromPromise(
                $`yabai --message window ${id} --focus`.quiet(),
                (cause) => new Error("unexpected error", { cause }),
              )
            )
        );
    })
    .match(
      () => {},
      (e) => console.error(e),
    );
}

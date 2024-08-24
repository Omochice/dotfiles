import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@7.0.1";
import { createSpaces } from "./create-spaces.ts";
import { $ } from "jsr:@david/dax@0.41.0";

const isWindow = is.ObjectOf({
  id: is.Number,
  space: is.Number,
  "is-hidden": is.Boolean,
  "is-minimized": is.Boolean,
  "is-sticky": is.Boolean,
});

if (import.meta.main) {
  const spaceId = ensure(Number(Deno.args[0]), is.Number);
  const r = await ResultAsync.fromPromise(
    $`yabai -m space --focus ${spaceId}`,
    (cause) => new Error("yabai failed", { cause }),
  );

  const a = r.isOk()
    ? ResultAsync.fromPromise(
      $`yabai -m query --windows`.json(),
      (cause) => new Error("yabai failed", { cause }),
    )
      .andThen((windows) => {
        return ResultAsync.fromPromise(
          Promise.resolve(ensure(windows, is.ArrayOf(isWindow))),
          (cause) => new Error("Ensure is failed", { cause }),
        );
      })
      .andThen((windows) => {
        const firstWindow = windows
          .filter((w) => w.space === spaceId)
          .filter((w) =>
            !w["is-hidden"] && !w["is-minimized"] && !w["is-sticky"]
          )
          .at(0);
        return firstWindow == null
          ? errAsync(new Error(`${spaceId} has no focusable window`))
          : okAsync(firstWindow.id);
      })
      .andThen((id) => {
        return ResultAsync.fromPromise(
          $`yabai -m window --focus ${id}`,
          (cause) => new Error("yabai failed", { cause }),
        );
      })
    : ResultAsync.fromPromise(
      $`yabai -m query --spaces`.json(),
      (cause) => new Error("yabai failed", { cause }),
    )
      .andThen((spaces) => {
        return is.Array(spaces)
          ? okAsync(spaces.length)
          : errAsync("yabai -m query --spaces returns non array");
      })
      .andThen((numSpaces) => {
        return ResultAsync.fromPromise(
          createSpaces(spaceId - numSpaces),
          (cause) => new Error("unexpected error", { cause }),
        );
      })
      .andThen(() => {
        return ResultAsync.fromPromise(
          $`yabai -m space --focus ${spaceId}`,
          (cause) => new Error("yabai failed", { cause }),
        );
      });
  a.match(
    () => {},
    (e) => {
      console.error(e);
    },
  );
}

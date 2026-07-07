import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@8.2.0";
import { createSpaces } from "./create-spaces.ts";
import { message, messageJson } from "./yabai-client.ts";

const isWindow = is.ObjectOf({
  id: is.Number,
  space: is.Number,
  "is-hidden": is.Boolean,
  "is-minimized": is.Boolean,
  "is-sticky": is.Boolean,
});

if (import.meta.main) {
  const spaceId = ensure(Number(Deno.args[0]), is.Number);
  await ResultAsync.fromPromise(
    message(["space", "--focus", String(spaceId)]),
    (cause) =>
      new Error(`Failed to run 'yabai space --focus ${spaceId}'`, {
        cause,
      }),
  )
    .then((r) => {
      const a = r.isOk()
        ? ResultAsync.fromPromise(
          messageJson(["query", "--windows"]),
          (cause) =>
            new Error("Failed to run 'yabai query --windows'", { cause }),
        )
          .andThen((windows) => {
            return ResultAsync.fromPromise(
              Promise.resolve(ensure(windows, is.ArrayOf(isWindow))),
              (cause) => new Error("Failed to ensure is window", { cause }),
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
              message(["window", "--focus", String(id)]),
              (cause) =>
                new Error(`Failed to run 'yabai window --focus ${id}'`, {
                  cause,
                }),
            );
          })
        : ResultAsync.fromPromise(
          messageJson(["query", "--spaces"]),
          (cause) =>
            new Error("Failed to run 'yabai query --spaces'", { cause }),
        )
          .andThen((spaces) => {
            return is.Array(spaces)
              ? okAsync(spaces.length)
              : errAsync("'yabai query --spaces' returns non array");
          })
          .andThen((numSpaces) => {
            return ResultAsync.fromPromise(
              createSpaces(spaceId - numSpaces),
              (cause) => new Error("Failed to create new spaces", { cause }),
            );
          })
          .andThen(() => {
            return ResultAsync.fromPromise(
              message(["space", "--focus", String(spaceId)]),
              (cause) =>
                new Error(
                  `Failed to run 'yabai space --focus ${spaceId}'`,
                  { cause },
                ),
            );
          });
      a.match(
        () => {},
        (e) => {
          console.error(e);
        },
      );
    });
}

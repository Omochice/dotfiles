import { focus as focusSpace } from "https://deno.land/x/deno_yabai@v0.1.3/space.ts";
import { focus as focusWindow } from "https://deno.land/x/deno_yabai@v0.1.3/window.ts";
import {
  getSpaces,
  getWindows,
} from "https://deno.land/x/deno_yabai@v0.1.3/query.ts";
import { ensure, is } from "https://deno.land/x/unknownutil@v3.18.1/mod.ts";
import { errAsync, okAsync, ResultAsync } from "npm:neverthrow@6.2.1";
import { createSpaces } from "./create-spaces.ts";

if (import.meta.main) {
  const spaceId = ensure(Number(Deno.args[0]), is.Number);
  await focusSpace({ target: spaceId })
    .andThen(() => getWindows())
    .andThen((windows) => {
      const firstWindow = windows
        .filter((w) => w.space === spaceId)
        .filter((w) => !w["is-hidden"] && !w["is-minimized"] && !w["is-sticky"])
        .at(0);
      return firstWindow == null
        ? errAsync(new Error(`${spaceId} has no focusable window`))
        : okAsync(firstWindow.id);
    })
    .andThen((target) => focusWindow({ target }))
    .orElse(() => {
      return getSpaces()
        .andThen((spaces) => okAsync(spaceId - spaces.length))
        .andThen((times) => ResultAsync.fromSafePromise(createSpaces(times)))
        .andThen(() => focusSpace({ target: spaceId }))
        .andThen(() => okAsync(undefined));
    });
}

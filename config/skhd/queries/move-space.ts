import { focus as focusSpace } from "https://deno.land/x/deno_yabai@v0.1.3/space.ts";
import { relocate } from "https://deno.land/x/deno_yabai@v0.1.3/window.ts";
import { getSpaces } from "https://deno.land/x/deno_yabai@v0.1.3/query.ts";
import { ensure, is } from "https://deno.land/x/unknownutil@v3.17.3/mod.ts";
import { okAsync, ResultAsync } from "npm:neverthrow@6.1.0";
import { createSpaces } from "./create-spaces.ts";

if (import.meta.main) {
  const spaceId = ensure(Number(Deno.args), is.Number);

  await getSpaces()
    .andThen((e) => okAsync(e.length))
    .andThen((foo) => {
      const numberOfNeedToCreate = spaceId - foo;
      return numberOfNeedToCreate > 0
        ? ResultAsync.fromSafePromise(createSpaces(numberOfNeedToCreate))
        : okAsync(undefined);
    })
    .andThen(() => relocate({ type: "space", query: spaceId }))
    .andThen(() => focusSpace({ target: spaceId }));
}

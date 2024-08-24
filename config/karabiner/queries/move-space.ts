import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { $ } from "jsr:@david/dax@0.41.0";
import { okAsync, ResultAsync } from "npm:neverthrow@7.0.1";
import { createSpaces } from "./create-spaces.ts";

if (import.meta.main) {
  const spaceId = ensure(Number(Deno.args), is.Number);

  await ResultAsync.fromPromise(
    $`yabai -m query --spaces`.json(),
    (cause) => new Error("Failed to exec 'yabai -m query --spaces'", { cause }),
  )
    .andThen((spaces) => {
      return ResultAsync.fromPromise(
        Promise.resolve(ensure(spaces, is.Array)),
        (cause) => new Error("Failed to ensure is array", { cause }),
      );
    })
    .andThen((spaces) => {
      return okAsync(spaces.length);
    })
    .andThen((numSpaces) => {
      const numberOfNeedToCreate = spaceId - numSpaces;
      return numberOfNeedToCreate > 0
        ? ResultAsync.fromPromise(
          createSpaces(numberOfNeedToCreate),
          (cause) => new Error("Failed to create space", { cause }),
        )
        // NOTE: not need to create new spaces
        : okAsync(undefined);
    })
    .andThen(() => {
      return ResultAsync.fromPromise(
        $`yabai -m window --space ${spaceId}`,
        (cause) =>
          new Error(`Failed to exec 'yabai -m window --space ${spaceId}'`, {
            cause,
          }),
      );
    })
    .andThen(() => {
      return ResultAsync.fromPromise(
        $`yabai -m space --space ${spaceId}`,
        (cause) =>
          new Error(`Failed to exec 'yabai -m space --space ${spaceId}'`, {
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

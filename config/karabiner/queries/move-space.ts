import { ensure, is } from "jsr:@core/unknownutil@4.3.0";
import { okAsync, ResultAsync } from "npm:neverthrow@8.2.0";
import { createSpaces } from "./create-spaces.ts";
import { message, messageJson } from "./yabai-client.ts";

if (import.meta.main) {
  const spaceId = ensure(Number(Deno.args), is.Number);

  await ResultAsync.fromPromise(
    messageJson(["query", "--spaces"]),
    (cause) => new Error("Failed to run 'yabai query --spaces'", { cause }),
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
        message(["window", "--space", String(spaceId)]),
        (cause) =>
          new Error(`Failed to run 'yabai window --space ${spaceId}'`, {
            cause,
          }),
      );
    })
    .andThen(() => {
      return ResultAsync.fromPromise(
        message(["space", "--space", String(spaceId)]),
        (cause) =>
          new Error(`Failed to run 'yabai space --space ${spaceId}'`, {
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

import { close, focus } from "https://deno.land/x/deno_yabai@v0.1.3/window.ts";
import { getSpaces } from "https://deno.land/x/deno_yabai@v0.1.3/query.ts";
import { errAsync, okAsync } from "npm:neverthrow@6.2.0";

if (import.meta.main) {
  await close()
    .andThen(() => getSpaces())
    .andThen(
      (spaces) => {
        const currentSpace = spaces
          .map((space) => space["first-window"])
          .at(0);
        return currentSpace == null
          ? errAsync(new Error("currentSpace is nully"))
          : okAsync(currentSpace);
      },
    )
    .andThen((target) => focus({ target }));
}

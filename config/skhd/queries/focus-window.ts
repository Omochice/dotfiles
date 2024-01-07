import { focus as focusWindow } from "https://deno.land/x/deno_yabai@v0.1.2/window.ts";
import { focus as focusDisplay } from "https://deno.land/x/deno_yabai@v0.1.2/display.ts";
import { ensure, is } from "https://deno.land/x/unknownutil@v3.13.0/mod.ts";

if (import.meta.main) {
  const way = ensure(
    Deno.args[0],
    is.OneOf([
      is.LiteralOf("west"),
      is.LiteralOf("east"),
      is.LiteralOf("north"),
      is.LiteralOf("south"),
    ]),
  );

  await focusWindow({ target: way })
    .orElse(() => focusDisplay({ target: way }));
}

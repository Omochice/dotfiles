import {
  relocate,
  swap,
  warp,
} from "https://deno.land/x/deno_yabai@v0.1.3/window.ts";
import { ensure, is } from "https://deno.land/x/unknownutil@v3.17.0/mod.ts";

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

  await swap({ target: way })
    .orElse(() =>
      relocate({ type: "display", query: way })
        .andThen(() => warp({ target: way }))
    );
}

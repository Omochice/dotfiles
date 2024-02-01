import { create } from "https://deno.land/x/deno_yabai@v0.1.3/space.ts";

export async function createSpaces(times: number) {
  for (let i = 0; i < times; i++) {
    await create();
  }
}

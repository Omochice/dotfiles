import { assertEquals } from "https://deno.land/std@0.207.0/assert/mod.ts";

Deno.test("url test", async (t) => {
  await t.step("sample step", () => {
    const url = new URL("./foo.js", "https://deno.land/");
    assertEquals(url.href, "https://deno.land/foo.js");
  });
});

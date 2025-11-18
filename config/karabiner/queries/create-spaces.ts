import { $ } from "jsr:@david/dax@0.44.0";

export async function createSpaces(times: number): Promise<void> {
  for (let i = 0; i < times; i++) {
    await $`yabai -m space --create`;
  }
}

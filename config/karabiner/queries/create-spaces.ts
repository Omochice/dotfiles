import { message } from "./yabai-client.ts";

export async function createSpaces(times: number): Promise<void> {
  for (let i = 0; i < times; i++) {
    await message(["space", "--create"]);
  }
}

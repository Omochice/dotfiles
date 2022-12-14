import { Denops, execute } from "./deps.ts";

export async function main(denops: Denops): Promise<void> {
  denops.dispatcher = {
    async Sample(args: unknown): Promise<void> {
    },
  };
  await execute(
    denops,
    `
  command! Sample call denops#notify(${denops.name}, 'Sanple', [])
  `,
  );
}

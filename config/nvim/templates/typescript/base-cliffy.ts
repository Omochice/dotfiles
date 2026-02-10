import { Command } from "jsr:@cliffy/command@1.0.0";

const command = new Command()
  .name("sample")
  .option("--in <in:string>", "input filepath", {
    conflicts: ["--stdin"],
    required: true,
  })
  .option("--stdin", "use stdin", {
    conflicts: ["in"],
    default: false,
    required: true,
  })
  .option("--out <out:string>", "output filename");

if (import.meta.main) {
  const { options } = await command.parse(Deno.args);
  console.debug(options);
}

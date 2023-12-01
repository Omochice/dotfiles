import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";

if (import.meta.main) {
  const { options } = await new Command()
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
    .option("--out <out:string>", "output filename")
    .parse(Deno.args);
  console.debug(options);
}

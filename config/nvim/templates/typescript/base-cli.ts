import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.2/mod.ts";

@Help("Sample CLI tool")
@Version("0.0.0")
class Program extends Command {
  @Arg({ about: "sample argument" })
  arg!: string;

  @Opt({ about: "sample option", short: true })
  option = "opt";

  @Flag({ about: "sample flag" })
  debug = false;

  async execute() {
    console.log(this.arg, this.option, this.debug);
    Promise.resolve();
  }
}

await Program.run(Deno.args);

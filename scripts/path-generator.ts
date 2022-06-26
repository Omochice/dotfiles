import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.2/mod.ts";
import { parse } from "https://deno.land/std@0.140.0/encoding/toml.ts";

type Shell = "bash" | "zsh" | "fish";

interface Setting {
  paths: ExecutablePath[];
  environments: Environment[];
  aliases: Alias[];
}

interface ExecutablePath {
  path: string;
  if_executable?: string;
}

interface Environment {
  from: string;
  to: string;
  if_executable?: string;
  if_exists?: string;
}

interface Alias {
  from: string;
  to: string;
  if_executable?: string;
  if_exists?: string;
}

async function loadToml(path: string): Promise<Setting> {
  const contents = Deno.readTextFile(path);
  return (parse(await contents) as unknown as Setting);
}

function tildeToHome(path: string): string {
  return path.replace(/^~/, "$HOME");
}

function generatePath(config: ExecutablePath, shell: Shell): string {
  if (shell == "fish") {
    return [
      `if test -d ${config.path}`,
      `\tset -x PATH ${tildeToHome(config.path)} \$PATH`,
      `end`,
    ].join("\n");
  } else {
    return [
      `if [[ -d ${config.path} ]]; then`,
      `\texport PATH=${tildeToHome(config.path)}:\$PATH`,
      `fi`,
    ].join("\n");
  }
}

function generateAlias(alias: Alias, shell: Shell): string {
  const head = [];
  if (shell == "fish") {
    if (alias.if_executable) {
      head.push(`command -v ${alias.if_executable} >/dev/null 2>&1`);
    }
    if (alias.if_exists) {
      head.push(`test -e ${tildeToHome(alias.if_exists)}`);
    }
    const body = `alias ${alias.to} "${alias.from}"`;
    return head.length > 0
      ? [`if ${head.join(" && ")}`, `\t${body}`, `end`].join("\n")
      : body;
  } else {
    if (alias.if_executable) {
      head.push(`command -v ${alias.if_executable} >/dev/null 2>&1`);
    }
    if (alias.if_exists) {
      head.push(`[[ -e ${tildeToHome(alias.if_exists)} ]]`);
    }
    const body = `alias ${alias.to}=${alias.from}`;
    return head.length > 0
      ? [`if ${head.join(" && ")}; then`, `\t${body}`, `fi`].join("\n")
      : body;
  }
}

function generateEnviroment(environment: Environment, shell: Shell): string {
  const head = [];
  if (shell == "fish") {
    if (environment.if_executable) {
      head.push(`command -v ${environment.if_executable} >/dev/null 2>&1`);
    }
    if (environment.if_exists) {
      head.push(`test -e ${tildeToHome(environment.if_exists)}`);
    }
    const body = `set ${environment.to} ${environment.from}`;
    return head.length > 0
      ? [`if ${head.join(" && ")}`, `\t${body}`, `end`].join("\n")
      : body;
  } else {
    if (environment.if_executable) {
      head.push(`command -v ${environment.if_executable} >/dev/null 2>&1`);
    }
    if (environment.if_exists) {
      head.push(`[[ -e ${tildeToHome(environment.if_exists)} ]]`);
    }
    const body = `export ${environment.to}=${environment.from}`;
    return head.length > 0
      ? [`if ${head.join(" && ")}; then`, `\t${body}`, `fi`].join("\n")
      : body;
  }
}

@Help("Path file generator for me")
@Version("0.0.0")
class Program extends Command {
  @Arg({ about: "path to config file" })
  config!: string;

  @Opt({ about: `Format shell type ${Deno.env.get("shell")}` })
  shell: Shell = Deno.env.get("shell") as Shell;

  @Flag({ about: "enable debug mode" })
  debug = false;

  async execute() {
    const tomlData = await loadToml(this.config);
    const paths: string[] = [];
    for (const p of tomlData.paths) {
      if (this.debug) {
        console.error(p);
        console.error(generatePath(p, this.shell));
      }
      paths.push(generatePath(p, this.shell));
    }

    const aliases: string[] = [];
    for (const al of tomlData.aliases) {
      if (this.debug) {
        console.error(al);
        console.error(generateAlias(al, this.shell));
      }
      aliases.push(generateAlias(al, this.shell));
    }

    const envs: string[] = [];
    for (const env of tomlData.environments) {
      if (this.debug) {
        console.error(env);
        console.error(generateEnviroment(env, this.shell));
      }
      envs.push(generateEnviroment(env, this.shell));
    }

    console.log([
      paths.join("\n"),
      aliases.join("\n"),
      envs.join("\n"),
    ].join("\n\n"));
  }
}

await Program.run(Deno.args);

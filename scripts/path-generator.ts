import {
  Arg,
  Command,
  Flag,
  Help,
  Opt,
  Version,
} from "https://raw.githubusercontent.com/stsysd/classopt/v0.1.2/mod.ts";
import { parse } from "https://deno.land/std@0.140.0/encoding/toml.ts";
import { expandHome } from "https://deno.land/x/expandhome@v0.0.5/mod.ts";
import { basename } from "https://deno.land/std@0.146.0/path/mod.ts";

type Shell = "bash" | "zsh" | "fish";

function getShell(): Shell {
  return basename(Deno.env.get("SHELL") ?? "bash") as Shell;
}

interface Option {
  os?: typeof Deno.build.os | typeof Deno.build.os[];
  arch?: typeof Deno.build.arch;
  only?: Shell | Shell[];
  if_executable?: string;
  if_exists?: string;
}

interface Setting extends Option {
  paths: ExecutablePath[];
  environments: Environment[];
  aliases: Alias[];
  sources: Source[];
}

interface ExecutablePath extends Option {
  path: string;
}

interface Environment extends Option {
  from: string;
  to: string;
}

interface Alias extends Option {
  from: string;
  to: string;
}

interface Source extends Option {
  path: string;
}

async function loadToml(path: string): Promise<Setting> {
  const contents = Deno.readTextFile(path);
  return (parse(await contents) as unknown as Setting);
}

function filterByShell<
  T extends ExecutablePath | Environment | Alias | Source = ExecutablePath,
>(
  arr: T[],
  shell: Shell,
): T[] {
  return arr.filter((e) =>
    e.only == undefined || e.only == shell || e.only.includes(shell)
  );
}

function generatePath(config: ExecutablePath, shell: Shell): string {
  if (shell == "fish") {
    return [
      `test -d ${expandHome(config.path)}`,
      `set -x PATH ${expandHome(config.path)}`,
    ]
      .join(" && ");
  } else {
    return [
      `[[ -d ${expandHome(config.path)} ]]`,
      `export PATH=${expandHome(config.path)}:\$PATH`,
    ].join(" && ");
  }
}

function generateAlias(alias: Alias, shell: Shell): string {
  const head = [];
  if (shell == "fish") {
    if (alias.if_executable) {
      head.push(`command -v ${alias.if_executable} >/dev/null 2>&1`);
    }
    if (alias.if_exists) {
      head.push(`test -e ${expandHome(alias.if_exists)}`);
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
      head.push(`[[ -e ${expandHome(alias.if_exists)} ]]`);
    }
    const body = `alias ${alias.to}=${alias.from}`;
    return head.length > 0
      ? [`if ${head.join(" && ")}; then`, `\t${body}`, `fi`].join("\n")
      : body;
  }
}

function generateEnviroment(environment: Environment, shell: Shell): string {
  const head = [];
  const from = expandHome(environment.from);
  const to = expandHome(environment.to);
  if (shell == "fish") {
    if (environment.if_executable) {
      head.push(`command -v ${environment.if_executable} >/dev/null 2>&1`);
    }
    if (environment.if_exists) {
      head.push(`test -e ${expandHome(environment.if_exists)}`);
    }
    const body = `set ${to} ${from}`;
    return head.length > 0
      ? [`if ${head.join(" && ")}`, `\t${body}`, `end`].join("\n")
      : body;
  } else {
    if (environment.if_executable) {
      head.push(`command -v ${environment.if_executable} >/dev/null 2>&1`);
    }
    if (environment.if_exists) {
      head.push(`[[ -e ${expandHome(environment.if_exists)} ]]`);
    }
    head.push(`export ${to}=${from}`);
    return head.join(" && ");
  }
}

function generateSource(source: Source, _shell: Shell): string {
  const body = [];
  if (source.if_executable) {
    body.push(`command -v ${source.if_executable} >/dev/null 2>&1`);
  }
  if (source.if_exists) {
    body.push(`[[ -e ${expandHome(source.if_exists)} ]]`);
  }
  body.push(
    `[[ -f ${expandHome(source.path)} ]]`,
    `source ${expandHome(source.path)}`,
  );
  return body.join(" && ");
}

@Help("Path file generator for me")
@Version("0.0.0")
class Program extends Command {
  @Arg({ about: "path to config file" })
  config!: string;

  @Opt({ about: `Format shell type. default: ${getShell()}` })
  shell: Shell = getShell();

  @Flag({ about: "enable debug mode" })
  debug = false;

  async execute() {
    console.log(this.shell);
    const tomlData = await loadToml(this.config);
    const paths: string[] = [];
    for (const p of filterByShell(tomlData.paths ?? [], this.shell)) {
      if (this.debug) {
        console.error(p);
        console.error(generatePath(p, this.shell));
      }
      paths.push(generatePath(p, this.shell));
    }

    const aliases: string[] = [];
    for (const al of filterByShell(tomlData.aliases ?? [], this.shell)) {
      if (this.debug) {
        console.error(al);
        console.error(generateAlias(al, this.shell));
      }
      aliases.push(generateAlias(al, this.shell));
    }

    const envs: string[] = [];
    for (const env of filterByShell(tomlData.environments ?? [], this.shell)) {
      if (this.debug) {
        console.error(env);
        console.error(generateEnviroment(env, this.shell));
      }
      envs.push(generateEnviroment(env, this.shell));
    }

    const sources: string[] = [];
    for (const source of filterByShell(tomlData.sources ?? [], this.shell)) {
      if (this.debug) {
        console.error(source);
        console.error(generateSource(source, this.shell));
      }
      sources.push(generateSource(source, this.shell));
    }

    console.log(
      [
        paths.join("\n"),
        aliases.join("\n"),
        envs.join("\n"),
        sources.join("\n"),
      ].filter((e) => e.length > 0).join("\n\n"),
    );
  }
}

await Program.run(Deno.args);

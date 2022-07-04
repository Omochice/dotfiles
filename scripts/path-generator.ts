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
  executes: Execute[];
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

interface Execute extends Option {
  command: string;
}

async function loadToml(path: string): Promise<Setting> {
  const contents = Deno.readTextFile(path);
  return (parse(await contents) as unknown as Setting);
}

function filterByShell<
  T extends ExecutablePath | Environment | Alias | Source | Execute =
    ExecutablePath,
>(
  arr: T[],
  shell: Shell,
): T[] {
  const acceptOnly = (e: Option): boolean => {
    return e.only === undefined || e.only === shell || e.only.includes(shell);
  };
  const acceptOs = (e: Option): boolean => {
    return e.os === undefined || e.os === Deno.build.os ||
      e.os.includes(Deno.build.os);
  };
  const acceptArch = (e: Option): boolean => {
    return e.arch === undefined || e.arch === Deno.build.arch ||
      e.arch.includes(Deno.build.arch);
  };
  return arr.filter((e) => acceptOnly(e) && acceptOs(e) && acceptArch(e));
}

function executable(command: string): string {
  return `command -v ${command} >/dev/null 2>&1`;
}

function generateFactory(kind: Option, shell: Shell) {
  return (...commands: string[]): string => {
    const conditions = [];
    const exists = (path: string): string => {
      return shell === "fish"
        ? `test -e ${expandHome(path)}`
        : `[[ -e ${expandHome(path)} ]]`;
    };
    if (kind.if_executable !== undefined) {
      conditions.push(executable(kind.if_executable));
    }
    if (kind.if_exists !== undefined) {
      conditions.push(exists(expandHome(kind.if_exists)));
    }

    return [...conditions, ...commands].join(" && ");
  };
}

function generatePath(config: ExecutablePath, shell: Shell): string {
  const generate = generateFactory(config, shell);
  const path = expandHome(config.path);
  if (shell === "fish") {
    return generate(
      `test -d ${path}`,
      `set --path PATH \$PATH ${path}`,
    );
  } else {
    return generate(
      `[[ -d ${path} ]]`,
      `export PATH=${path}:\$PATH`,
    );
  }
}

function generateAlias(alias: Alias, shell: Shell): string {
  const from = expandHome(alias.from);
  const generate = generateFactory(alias, shell);
  if (shell === "fish") {
    return generate(`alias ${alias.to} "${from}"`);
  } else {
    return generate(`alias ${alias.to}="${from}"`);
  }
}

function generateEnviroment(environment: Environment, shell: Shell): string {
  const from = expandHome(environment.from);
  const to = environment.to;
  const generate = generateFactory(environment, shell);
  if (shell === "fish") {
    return generate(`set --unpath ${to} ${from}`);
  } else {
    return generate(`export ${to} ${from}`);
  }
}

function generateSource(source: Source, shell: Shell): string {
  const path = expandHome(source.path);
  const generate = generateFactory(source, shell);
  if (shell === "fish") {
    return generate(`test -f ${path}`, `source ${path}`);
  } else {
    return generate(`[[ -f ${path} ]]`, `source ${path}`);
  }
}

function generateExecute(execute: Execute, shell: Shell): string {
  const generate = generateFactory(execute, shell);
  return generate(execute.command);
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

    const execs: string[] = [];
    for (const exec of filterByShell(tomlData.executes ?? [], this.shell)) {
      if (this.debug) {
        console.error(exec);
        console.error(generateExecute(exec, this.shell));
      }
      execs.push(generateExecute(exec, this.shell));
    }

    console.log(
      [
        paths.join("\n"),
        sources.join("\n"),
        aliases.join("\n"),
        envs.join("\n"),
        execs.join("\n"),
      ].filter((e) => e.length > 0).join("\n\n"),
    );
  }
}

await Program.run(Deno.args);

import { parse as parseToml } from "https://deno.land/std@0.185.0/toml/parse.ts";
import { deepMerge } from "https://deno.land/std@0.185.0/collections/deep_merge.ts";
import { basename } from "https://deno.land/std@0.185.0/path/mod.ts";
import { parse as parseArguments } from "https://deno.land/std@0.185.0/flags/mod.ts";
import {
  ensureArray,
  ensureString,
  isArray,
  isObject,
  isString,
} from "https://deno.land/x/unknownutil@v2.1.0/mod.ts";

const supportedShell = ["bash", "zsh", "fish"] as const;
type Shell = typeof supportedShell[number];
function isShell(x: unknown): x is Shell {
  // NOTE: if use includes then show error by lsp
  return supportedShell.some((e) => e === x);
}

type OS = "wsl" | typeof Deno.build.os;

type Option = {
  os?: OS | OS[];
  arch?: typeof Deno.build.arch;
  only?: Shell | Shell[];
  if_executable?: string;
  if_exists?: string;
  tag?: string;
  depends?: string[];
};

type Setting = {
  paths: ExecutablePath[];
  environments: Environment[];
  aliases: Alias[];
  sources: Source[];
  executes: Execute[];
};

type ExecutablePath = Option & {
  path: string;
};

type Environment = Option & {
  from: string;
  to: string;
};

type Alias = Option & {
  from: string;
  to: string;
};

type Source = Option & {
  path: string;
};

type Execute = Option & {
  command: string;
};

/**
 * judge x is `Setting`
 *
 * @param x target
 * @return whether x is `Setting`
 */
function isSetting(x: unknown): x is Setting {
  if (!isObject(x)) {
    return false;
  }
  return (
    isArray(x.paths) &&
    isArray(x.environments) &&
    isArray(x.aliases) &&
    isArray(x.sources) &&
    isArray(x.executes)
  );
}

/**
 * ensure Record<> is Setting
 *
 * @param setting raw Record<>
 * @return ensured one
 */
function ensureSetting(setting: Record<string, unknown>): Setting {
  if (setting.paths === undefined) {
    setting.paths = [];
  }
  if (setting.environments === undefined) {
    setting.environments = [];
  }
  if (setting.aliases === undefined) {
    setting.aliases = [];
  }
  if (setting.sources === undefined) {
    setting.sources = [];
  }
  if (setting.executes === undefined) {
    setting.executes = [];
  }

  if (!isSetting(setting)) {
    // unreach here
    throw Error("unexpected error");
  }
  return setting;
}

/**
 * load toml file
 *
 * @param path path to toml file
 * @return loaded one
 */
function loadToml(path: string) {
  const contents = Deno.readTextFileSync(path);
  return ensureSetting(parseToml(contents));
}

/**
 * load setting files as merged setting
 *
 * @param paths array of path to setting file
 * @return merged one
 */
function loadSetting(paths: string[]): Setting {
  return paths.map((e) => loadToml(e)).reduce(
    (prev, curr) => deepMerge(prev, curr),
  );
}

class shellStringGenerator {
  #shell: Shell;
  #home = ensureString(Deno.env.get("HOME"));

  constructor(shell: Shell) {
    this.#shell = shell;
  }

  /**
   * generate shell setting string
   *
   * @param setting setting
   * @return setting for shell
   */
  shellString(setting: Setting): string {
    const contents = [
      setting.paths.map((e) => this.generatePath(e)),
      setting.environments.map((e) => this.generateEnviroment(e)),
      setting.sources.map((e) => this.generateSource(e)),
      setting.executes.map((e) => this.generateExecute(e)),
      setting.aliases.map((e) => this.generateAlias(e)),
    ];
    return contents
      .flat()
      .filter((e) => e.length > 0)
      .join("\n");
  }

  /**
   * generate path string according to each shell
   *
   * @param config path config
   * @return generated one
   */
  generatePath(config: ExecutablePath): string {
    const generate = this.#generateFactory(config);
    const path = this.#expandHome(config.path);
    config.if_exists = path;
    if (this.#shell === "fish") {
      return generate(`set --path PATH \$PATH ${path}`);
    } else {
      return generate(`export PATH=${path}:\$PATH`);
    }
  }

  /**
   * generate alias string according to each shell
   *
   * @param alias alias config
   * @return generated one
   */
  generateAlias(alias: Alias): string {
    const from = this.#expandHome(alias.from);
    const generate = this.#generateFactory(alias);
    if (this.#shell === "fish") {
      return generate(`alias ${alias.to} "${from}"`);
    } else {
      return generate(`alias ${alias.to}="${from}"`);
    }
  }

  /**
   * generate environment string according to each shell
   *
   * @param environment environment config
   * @return generated one
   */
  generateEnviroment(environment: Environment): string {
    const from = this.#expandHome(environment.from);
    const to = environment.to;
    const generate = this.#generateFactory(environment);
    if (this.#shell === "fish") {
      return generate(`set --export --unpath ${to} ${from}`);
    } else {
      return generate(`export ${to}=${from}`);
    }
  }

  /**
   * generate source string according to each shell
   *
   * @param source source config
   * @return generated one
   */
  generateSource(source: Source): string {
    const path = this.#expandHome(source.path);
    const generate = this.#generateFactory(source);
    if (this.#shell === "fish") {
      return generate(`test -f ${path}`, `source ${path}`);
    } else {
      return generate(`[[ -f ${path} ]]`, `source ${path}`);
    }
  }

  /**
   * generate execute string
   *
   * @param execute execute config
   * @return generated one
   */
  generateExecute(execute: Execute): string {
    const generate = this.#generateFactory(execute);
    return generate(execute.command);
  }

  #generateFactory(kind: Option): (...commands: string[]) => string {
    return (...commands: string[]): string => {
      const conditions = [];
      if (kind.if_executable !== undefined) {
        conditions.push(this.#executable(kind.if_executable));
      }
      if (
        kind.if_exists !== undefined &&
        !this.#isExists(this.#expandHome(kind.if_exists))
      ) {
        return "";
      }

      return [...conditions, ...commands].join(" && ");
    };
  }

  #executable(command: string): string {
    return `command -v ${command} >/dev/null 2>&1`;
  }

  #isExists(path: string): boolean {
    try {
      Deno.lstatSync(path);
    } catch (_) {
      return false;
    }
    return true;
  }

  #expandHome(path: string): string {
    return path.replace(/^~/, this.#home);
  }
}

class CandidateGenerator {
  #shell: Shell;
  #os: OS;
  constructor(shell: Shell) {
    this.#shell = shell;
    this.#os = this.#getOS();
  }

  *getCandidates(setting: Setting) {
    const candidates: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(setting)) {
      const target = this.#filter(value as unknown as Option[]);
      candidates[key] = target;
    }
    let remain = ensureSetting(candidates);

    let tags = new Set<string>();
    while (
      Object
        .values(remain)
        .some((v: unknown[]) => v.length > 0)
    ) {
      const target: Record<string, unknown[]> = {};
      const notTarget: Record<string, unknown[]> = {};
      const tempTags = new Set<string>();
      for (const [key, value] of Object.entries(remain)) {
        for (const e of value) {
          if (
            e.depends === undefined ||
            e.depends.every((d) => tags.has(d))
          ) {
            if (Array.isArray(target[key])) {
              target[key].push(e);
            } else {
              target[key] = [e];
            }
            if (e.tag !== undefined) {
              tempTags.add(e.tag);
            }
          } else {
            if (Array.isArray(notTarget[key])) {
              notTarget[key].push(e);
            } else {
              notTarget[key] = [e];
            }
          }
        }
      }
      if (Object.values(target).every((v) => v.length === 0)) {
        // NOTE: If number of new candidates are 0 then all of remains are dead link
        break;
      }
      remain = ensureSetting(notTarget);
      tags = new Set([...tags, ...tempTags]);
      yield ensureSetting(target);
    }
  }

  #filter<T extends Option>(
    targets: T[],
  ): T[] {
    const acceptOnly = (e: Option): boolean => {
      return e.only === undefined ||
        e.only === this.#shell ||
        (Array.isArray(e.only) &&
          e.only.some((e) => e === this.#shell));
    };
    const acceptOs = (e: Option): boolean => {
      return e.os === undefined ||
        e.os === this.#os ||
        e.os.includes(this.#os);
    };
    const acceptArch = (e: Option): boolean => {
      return (
        e.arch === undefined ||
        e.arch === Deno.build.arch ||
        e.arch.includes(Deno.build.arch)
      );
    };
    return targets
      .filter(
        (e) =>
          acceptOnly(e) &&
          acceptOs(e) &&
          acceptArch(e),
      );
  }

  #getOS(): OS {
    try {
      const b = Deno.readTextFileSync("/proc/version").toString().toLowerCase();
      return b.includes("microsoft") ? "wsl" : Deno.build.os;
    } catch {
      return Deno.build.os;
    }
  }
}
type Argument = {
  configs: string[];
  debug: boolean;
  shell: Shell;
  help: boolean;
};

function parseArgs(args: string[]): [Argument, null] | [null, Error] {
  const defaultShell = basename(Deno.env.get("SHELL") ?? "bash");
  const description = "Path file generator for me";
  const thisFile = basename(import.meta.url);
  const helpmsg = `
${thisFile} - ${description}

[USASE]
\t${thisFile} [OPTIONS] <configs...>

[ARGUMENTS]
\tconfig: setting toml file.

[OPTIONS]
\t--help -h: Show this message.
\t--debug: Run debug mode.
\t--shell: Output file format: default is ${defaultShell}
`;
  const parsed = parseArguments(args, {
    default: {
      debug: false,
      shell: defaultShell,
      help: false,
    },
    boolean: ["debug", "help"],
    alias: { h: "help" },
  });
  if (parsed.help) {
    return [null, new Error(helpmsg)];
  } else if (!isShell(parsed.shell)) {
    return [
      null,
      new Error(
        `${parsed.shell} is not supported. supporteds is ${supportedShell}.`,
      ),
    ];
  } else if (parsed._.length === 0) {
    return [null, new Error("Any config passed.")];
  }
  return [
    {
      configs: ensureArray(parsed._, isString),
      debug: parsed.debug,
      shell: parsed.shell,
      help: parsed.help,
    },
    null,
  ];
}

function main() {
  const [args, err] = parseArgs(Deno.args);
  if (err !== null) {
    console.error(err.message);
    Deno.exit();
  }
  const setting = loadSetting(args.configs);

  const generator = new CandidateGenerator(args.shell);
  const shellstring = new shellStringGenerator(args.shell);

  for (const candidates of generator.getCandidates(setting)) {
    console.log(shellstring.shellString(candidates));
  }
}

if (import.meta.main) {
  main();
}

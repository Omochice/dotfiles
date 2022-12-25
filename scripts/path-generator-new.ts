import { parse as parseToml } from "https://deno.land/std@0.157.0/encoding/toml.ts";
import { deepMerge } from "https://deno.land/std@0.166.0/collections/deep_merge.ts";
import { basename } from "https://deno.land/std@0.157.0/path/mod.ts";
import { parse as parseArguments } from "https://deno.land/std@0.157.0/flags/mod.ts";
import {
  ensureArray,
  ensureString,
  isArray,
  isObject,
  isString,
} from "https://deno.land/x/unknownutil@v2.0.0/mod.ts";

const supportedShell = ["bash", "zsh", "fish"] as const;
type Shell = typeof supportedShell[keyof typeof supportedShell];
function isShell(x: unknown): x is Shell {
  return supportedShell.some((e) => e === x); // NOTE: if use includes then show error by lsp
}

type OS = "wsl" | typeof Deno.build.os;
function getOS(): OS {
  try {
    const b = Deno.readTextFileSync("/proc/version").toString().toLowerCase();
    return b.includes("microsoft") ? "wsl" : Deno.build.os;
  } catch {
    return Deno.build.os;
  }
}

const home = ensureString(Deno.env.get("HOME"));
function expandHome(p: string): string {
  return p.replace(/^~/, home);
}

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

function executable(command: string): string {
  return `command -v ${command} >/dev/null 2>&1`;
}

function isExists(path: string): boolean {
  try {
    Deno.lstatSync(path);
  } catch (_) {
    return false;
  }
  return true;
}

function generateFactory(kind: Option): (...commands: string[]) => string {
  return (...commands: string[]): string => {
    const conditions = [];
    if (kind.if_executable !== undefined) {
      conditions.push(executable(kind.if_executable));
    }
    if (kind.if_exists !== undefined && !isExists(expandHome(kind.if_exists))) {
      return "";
    }

    return [...conditions, ...commands].join(" && ");
  };
}

class CandidateGenerator {
  #candidates: Setting;
  #shell: Shell;
  #os: OS;
  constructor(setting: Setting, shell: Shell) {
    this.#shell = shell;
    this.#os = getOS();
    const candidates: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(setting)) {
      const target = this.#filter(value as unknown as Option[]);
      candidates[key] = target;
    }
    this.#candidates = ensureSetting(candidates);
  }

  *getCandidates() {
    let remain = { ...this.#candidates };
    let tags = new Set<string>();
    while (
      Object
        .entries(remain)
        .some(([_, v]) => v.length > 0)
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
      remain = { ...notTarget };
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
}

function generatePath(config: ExecutablePath, shell: Shell): string {
  const generate = generateFactory(config);
  const path = expandHome(config.path);
  config.if_exists = path;
  if (shell === "fish") {
    return generate(`set --path PATH \$PATH ${path}`);
  } else {
    return generate(`export PATH=${path}:\$PATH`);
  }
}

function generateAlias(alias: Alias, shell: Shell): string {
  const from = expandHome(alias.from);
  const generate = generateFactory(alias);
  if (shell === "fish") {
    return generate(`alias ${alias.to} "${from}"`);
  } else {
    return generate(`alias ${alias.to}="${from}"`);
  }
}

function generateEnviroment(environment: Environment, shell: Shell): string {
  const from = expandHome(environment.from);
  const to = environment.to;
  const generate = generateFactory(environment);
  if (shell === "fish") {
    return generate(`set --export --unpath ${to} ${from}`);
  } else {
    return generate(`export ${to}=${from}`);
  }
}

function generateSource(source: Source, shell: Shell): string {
  const path = expandHome(source.path);
  const generate = generateFactory(source);
  if (shell === "fish") {
    return generate(`test -f ${path}`, `source ${path}`);
  } else {
    return generate(`[[ -f ${path} ]]`, `source ${path}`);
  }
}

function generateExecute(execute: Execute, _shell: Shell): string {
  const generate = generateFactory(execute);
  return generate(execute.command);
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
  ${thisFile} [OPTIONS] <configs...>

[ARGUMENTS]
  config: setting toml file.

[OPTIONS]
  --help -h: Show this message.
  --debug: Run debug mode.
  --shell: Output file format: default is ${defaultShell}
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

if (import.meta.main) {
  const [args, err] = parseArgs(Deno.args);
  if (err !== null) {
    console.error(err.message);
    Deno.exit();
  }
  const setting = loadSetting(args.configs);
  const keyFuncMap = [
    { key: "paths", func: generatePath },
    { key: "environments", func: generateEnviroment },
    { key: "sources", func: generateSource },
    { key: "executes", func: generateExecute },
    { key: "aliases", func: generateAlias },
  ];

  const generator = new CandidateGenerator(setting, args.shell);

  for (const candidates of generator.getCandidates()) {
    const contents = [];
    for (const { key, func } of keyFuncMap) {
      const buf: string[] = [];
      (candidates[key] ?? []).forEach(
        (e) => buf.push(func(e, args.shell)),
      );
      contents.push([...buf]);
    }
    console.log(
      contents
        .flat()
        .filter((e) => e.length > 0)
        .join("\n"),
    );
  }
}

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import type { WalkEntry } from "https://deno.land/std@0.205.0/fs/mod.ts";

type FontType = "otf" | "ttf";
type Destination = { [K in FontType]: string };

const DESTINATION: Destination = Deno.build.os === "darwin"
  ? {
    otf: $.path.join("/", "Library", "Fonts"),
    ttf: $.path.join("/", "Library", "Fonts"),
  }
  : {
    otf: $.path.join(
      Deno.env.get("HOME") ?? "~",
      ".local",
      "share",
      "fonts",
      "otf",
    ),
    ttf: $.path.join(
      Deno.env.get("HOME") ?? "~",
      ".local",
      "share",
      "fonts",
      "ttf",
    ),
  };

async function moveFontFiles(baseDir: string): Promise<void> {
  const exts: readonly FontType[] = ["ttf", "otf"] as const;
  for (const ext of exts) {
    const dir = DESTINATION[ext];
    Deno.mkdirSync(
      dir,
      { recursive: true },
    );

    await Promise.all(
      Array
        .from($.fs.expandGlobSync(`${baseDir}/**/*.${ext}`))
        .map((fontFile: WalkEntry) =>
          $.fs.move(
            fontFile.path,
            $.path.join(dir, fontFile.name),
            { overwrite: true },
          )
        ),
    );
  }
}

async function downloadFont(): Promise<void> {
  const url = new URL(
    "https://github.com/yuru7/Firge/releases/download/v0.2.0/FirgeNerd_v0.2.0.zip",
  );

  const zipName = $.path.basename(url.pathname);

  const tmp = Deno.makeTempDirSync({
    dir: $.path.join(Deno.env.get("HOME") ?? "~", ".cache"),
  });

  await $.request(url)
    .showProgress()
    .pipeToPath(tmp);

  const unzipTo = $.path.join(tmp, `${zipName}.d`);

  await $`unzip ${$.path.join(tmp, zipName)} -d ${unzipTo}`.stdout("null");

  $.progress("Moveing font files...")
    .with(async () => await moveFontFiles(unzipTo));
}

async function main(): Promise<void> {
  await downloadFont()
    .then(() => {
      $.progress("fc-cache")
        .with(async () => {
          await $`fc-cache --force --verbose`.stdout("null");
        });
    });
}

if (import.meta.main) {
  await main();
}

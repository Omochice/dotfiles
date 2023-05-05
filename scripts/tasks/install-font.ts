import $ from "https://deno.land/x/dax@0.31.1/mod.ts";
import { WalkEntry } from "https://deno.land/std@0.182.0/fs/_util.ts";

async function moveFontFiles(baseDir: string): Promise<void> {
  for (const ext of ["ttf", "otf"]) {
    const fontDir = $.path.join(
      Deno.env.get("HOME") ?? "~",
      ".local",
      "share",
      "fonts",
      ext,
    );
    Deno.mkdirSync(
      fontDir,
      { recursive: true },
    );

    await Promise.all(
      Array
        .from($.fs.expandGlobSync(`${baseDir}/**/*.${ext}`))
        .map((fontFile: WalkEntry) =>
          $.fs.move(
            fontFile.path,
            $.path.join(fontDir, fontFile.name),
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

  const tmp = Deno.makeTempDirSync();

  await $.request(url)
    .showProgress()
    .pipeToPath(tmp);

  const unzipTo = $.path.join(tmp, `${zipName}.d`);

  await $`unzip ${$.path.join(tmp, zipName)} -d ${unzipTo}`.stdout("null");

  $.progress("Moveing font files...")
    .with(async () => await moveFontFiles(unzipTo));
}

await downloadFont()
  .then(() => {
    $.progress("fc-cache")
      .with(async () => {
        await $`fc-cache --force --verbose`.stdout("null");
      });
  });

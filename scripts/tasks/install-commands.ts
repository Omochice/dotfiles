import $ from "https://deno.land/x/dax@0.37.1/mod.ts";
import { ensureInstalled } from "./install-brew.ts";
import { DOTDIR, ISWSL } from "./mod.ts";
import { join } from "https://deno.land/std@0.216.0/path/join.ts";

async function installCommands() {
  const supported = new Set(["darwin", "linux"]);
  if (!supported.has(Deno.build.os)) {
    $.log(`${Deno.build.os} is not supported`);
    return;
  }

  if (ISWSL || Deno.build.os === "darwin") {
    return;
  }

  if ((await $.which("apt")) != undefined) {
    const tmpFile = Deno.makeTempFileSync();
    await Promise.all([
      $`/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2023.02.18_all.deb ${tmpFile} SHA256:a511ac5f10cd811f8a4ca44d665f2fa1add7a9f09bef238cdfad8461f5239cc4`
        .then(() => $`sudo apt install ${tmpFile}`),
      $`wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg`
        .then(() =>
          $`echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list`
        ),
    ]);

    await $`sudo apt update`;

    const args = ["rofi", "polybar", "picom", "i3", "vivaldi-stable"];

    await $`sudo apt install ${args}`;
    return;
  }

  if ((await $.which("pacman")) != undefined) {
    const args = ["rofi", "polybar", "picom", "i3-wm", "vivaldi"];
    await $`sudo pacman -Syu ${args}`;
    return;
  }
}

async function installViaBrew(): Promise<void> {
  const brewPath = await ensureInstalled();
  await $`${brewPath} bundle --file=${join(DOTDIR, "Brewfile")}`;
}

async function main(): Promise<void> {
  await installCommands();
  await installViaBrew();
}

if (import.meta.main) {
  await main();
}

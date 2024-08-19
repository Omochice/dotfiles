import * as k from "https://deno.land/x/karabinerts@1.30.0/deno.ts";

export const rules: Array<k.Rule | k.RuleBuilder> = [];

function $(cmd: string): string {
  const prefix = "export PATH=$PATH:/opt/homebrew/bin:$HOME/.deno/bin";
  return `${prefix};${cmd}`;
}

const compass = [
  ["h", "west"],
  ["j", "south"],
  ["k", "north"],
  ["l", "east"],
] as const;

rules.push(
  ...compass.map(([key, way]) => {
    return k.rule(
      `Change window focus ${way}. if exists other display on the way, focus it`,
    )
      .manipulators([
        k
          .map({ key_code: key, modifiers: { mandatory: ["command"] } })
          .to$(
            $(`yabai -m window --focus ${way} || yabai -m display --focus ${way}`),
          ),
      ]);
  }),
);

rules.push(
  ...compass.map(([key, way]) => {
    return k.rule(
      `Move window to ${way}. if exists window, move into it.`,
    )
      .manipulators([
        k
          .map({
            key_code: key,
            modifiers: { mandatory: ["command", "shift"] },
          })
          .to$(
            $(`deno run -A ~/.config/karabiner/queries/move-window.ts ${way}`),
          ),
      ]);
  }),
);

rules.push(
  k.rule("Close app and focus other remain app.")
    .manipulators([
      k
        .map({
          key_code: "q",
          modifiers: { mandatory: ["command", "shift"] },
        })
        .to$(
          $("deno run -A ~/.config/karabiner/queries/close-window.ts"),
        ),
    ]),
);

const numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"] as const;

rules.push(
  ...numbers.map((num) =>
    k.rule(
      `Focus space ${num}. if not exists it, create untile it.`,
    )
      .manipulators([
        k
          .map({
            key_code: num,
            modifiers: { mandatory: ["command"] },
          })
          .to$(
            $(`deno run -A  ~/.config/karabiner/queries/focus-space.ts ${num}`),
          ),
      ])
  ),
);

rules.push(
  ...numbers.map((num) =>
    k.rule(
      `Move window to space ${num}. if not exist, create untile it.`,
    )
      .manipulators([
        k
          .map({
            key_code: num,
            modifiers: { mandatory: ["command", "shift"] },
          })
          .to$(
            $(`deno run -A  ~/.config/karabiner/queries/move-space.ts ${num}`),
          ),
      ])
  ),
);

const arrows = [
  ["right", "next"],
  ["left", "prev"],
] as const;

rules.push(
  ...arrows.map(([key, way]) =>
    k.rule(`Focus ${way} space in current display`)
      .manipulators([
        k
          .map({
            key_code: `${key}_arrow` as const,
            modifiers: { mandatory: ["command"] },
          })
          .to$(
            $(`deno run -A  ~/.config/karabiner/queries/focus-in-display.ts ${way}`),
          ),
      ])
  ),
);

rules.push(
  k.rule(
    `Format display sizes in current space like vim's <C-w>=.`,
  )
    .manipulators([
      k
        .map({
          key_code: "equal_sign",
          modifiers: { mandatory: ["command"] },
        })
        .to$($("yabai -m space --balance")),
    ]),
);

rules.push(
  k.rule(`Toggle fullscreen`)
    .manipulators([
      k
        .map({
          key_code: "f",
          modifiers: { mandatory: ["command"] },
        })
        .to$($("yabai -m window --toggle zoom-fullscreen")),
    ]),
);

rules.push(
  k.rule("Toggle current window to floating.")
    .manipulators([
      k
        .map({
          key_code: "spacebar",
          modifiers: { mandatory: ["command"] },
        })
        .to$($("yabai -m window --toggle zoom-fullscreen")),
    ]),
);

rules.push(
  k.rule("Toggle split way.")
    .manipulators([
      k
        .map({
          key_code: "spacebar",
          modifiers: { mandatory: ["command", "shift"] },
        })
        .to$($("yabai -m window --toggle split")),
    ]),
);

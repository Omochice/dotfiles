import * as k from "https://deno.land/x/karabinerts@1.29.0/deno.ts";

k.writeToProfile("Default profile", [
  k.rule("Launch vivaldi")
    .manipulators([
      k
        .map({
          key_code: "w",
          modifiers: { mandatory: ["command"] },
        })
        .to([{ shell_command: 'open --new -a "vivaldi".app' }]),
    ]),
  k.rule(
    "Launch wezterm without slack",
    k
      .ifApp({
        bundle_identifiers: ["^com\\.tinyspeck\\.slackmacgap$"],
      })
      .unless(),
  )
    .manipulators([
      k
        .map({
          key_code: "return_or_enter",
          modifiers: { mandatory: ["command"] },
        })
        .to([{ shell_command: 'open --new -a "wezterm".app' }]),
    ]),
  k.rule("Left command to alt")
    .manipulators([
      k
        .map({ key_code: "left_command" })
        .to([{ key_code: "left_option" }]),
    ]),
  k.rule("Eisu to escape")
    .manipulators([
      k
        .map({ key_code: "japanese_eisuu" })
        .to([{ key_code: "escape" }]),
    ]),
  k.rule("Send eisuu and <Esc> on escape")
    .manipulators([
      k
        .map({ key_code: "escape" })
        .to([
          { key_code: "lang2" },
          { key_code: "escape" },
        ]),
    ]),
  k.rule("Underscpre to backslash")
    .manipulators([
      k
        .map({ key_code: "international1" })
        .to([{ key_code: "international3" }]),
    ]),
  k.rule("Kana use to toggle IME")
    .manipulators([
      k
        .map({ key_code: "japanese_kana", modifiers: { optional: ["any"] } })
        .to([{ key_code: "japanese_eisuu" }])
        .condition({
          input_sources: [{ language: "ja" }],
          type: "input_source_if",
        }),
      k
        .map({ key_code: "japanese_kana", modifiers: { optional: ["any"] } })
        .to([{ key_code: "japanese_kana" }])
        .condition({
          input_sources: [{ language: "en" }],
          type: "input_source_if",
        }),
    ]),
  k.rule("Option+<BS> to <Delete>")
    .manipulators([
      k
        .map({
          key_code: "delete_or_backspace",
          modifiers: { mandatory: ["option"] },
        })
        .to([{ key_code: "delete_forward" }]),
    ]),
]);

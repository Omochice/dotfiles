import * as k from "https://deno.land/x/karabinerts@1.30.3/deno.ts";
import { rules } from "./yabai.ts";

function newApp(name: string) {
  return k.to$(`open -n -a "${name}".app`);
}

k.writeToProfile("Default profile", [
  k.rule("Launch vivaldi")
    .manipulators([
      k
        .map({
          key_code: "w",
          modifiers: { mandatory: ["command"] },
        })
        .to(newApp("vivaldi")),
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
  k.rule("Underscore to backslash")
    .manipulators([
      k
        .map({ key_code: "international1" })
        .to([{ key_code: "international3" }]),
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
  k.rule("Open misson control on Mod + up")
    .manipulators([
      k
        .map({
          key_code: "up_arrow",
          modifiers: { mandatory: ["command"] },
        })
        .toApp("Mission Control"),
    ]),
  k.rule(
    "Send message by mod+enter same as slack",
    k
      .ifApp({
        bundle_identifiers: ["^com\\.microsoft\\.teams2$"],
      }),
  )
    .manipulators([
      k
        .map({
          key_code: "return_or_enter",
          modifiers: { mandatory: ["command"] },
        })
        .to([{
          key_code: "return_or_enter",
          modifiers: ["control"],
        }]),
    ]),
  ...rules,
]);

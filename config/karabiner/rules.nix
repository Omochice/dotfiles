# General key remaps, formerly mod.ts.
{ k }:
[
  (k.rule "Launch vivaldi" [
    (
      k.map {
        key_code = "w";
        modifiers.mandatory = [ "command" ];
      }
      |> k.newApp "vivaldi"
    )
  ])
  (k.rule "Left command to alt" [
    (k.map { key_code = "left_command"; } |> k.to [ { key_code = "left_option"; } ])
  ])
  (k.rule "Eisu to escape" [
    (k.map { key_code = "japanese_eisuu"; } |> k.to [ { key_code = "escape"; } ])
  ])
  (
    k.rule "Underscore to backslash" [
      (k.map { key_code = "international1"; } |> k.to [ { key_code = "international3"; } ])
    ]
    |> k.ifApp [ "^org.alacritty$" ]
    |> k.unless
  )
  (k.rule "Option+<BS> to <Delete>" [
    (
      k.map {
        key_code = "delete_or_backspace";
        modifiers.mandatory = [ "option" ];
      }
      |> k.to [ { key_code = "delete_forward"; } ]
    )
  ])
  (k.rule "Open misson control on Mod + up" [
    (
      k.map {
        key_code = "up_arrow";
        modifiers.mandatory = [ "command" ];
      }
      |> k.toApp "Mission Control"
    )
  ])
  (
    k.rule "Send message by mod+enter same as slack" [
      (
        k.map {
          key_code = "return_or_enter";
          modifiers.mandatory = [ "command" ];
        }
        |> k.to [
          {
            key_code = "return_or_enter";
            modifiers = [ "control" ];
          }
        ]
      )
    ]
    |> k.ifApp [ "^com\\.microsoft\\.teams2$" ]
  )
  (
    k.rule "Focus URL bar on chrome same as other browser or os" [
      (
        k.map {
          key_code = "l";
          modifiers.mandatory = [ "control" ];
        }
        |> k.to [
          {
            key_code = "l";
            modifiers = [ "command" ];
          }
        ]
      )
    ]
    |> k.ifApp [ "^com\\.google\\.Chrome" ]
  )
]

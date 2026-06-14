# yabai window-management bindings, formerly yabai.ts.
{ k }:
let
  # yabai and the deno query scripts are not on karabiner's PATH, so each
  # command re-exports the locations where nix and deno install their binaries.
  sh = command: "export PATH=$PATH:/run/current-system/sw/bin:$HOME/.deno/bin;${command}";

  query = script: sh "deno run -A ~/.config/karabiner/queries/${script}";
  # The space/display queries are invoked with an extra space, kept verbatim.
  query' = script: sh "deno run -A  ~/.config/karabiner/queries/${script}";

  compass = [
    {
      key = "h";
      way = "west";
    }
    {
      key = "j";
      way = "south";
    }
    {
      key = "k";
      way = "north";
    }
    {
      key = "l";
      way = "east";
    }
  ];

  arrows = [
    {
      key = "right";
      way = "next";
    }
    {
      key = "left";
      way = "prev";
    }
  ];

  numbers = builtins.genList (i: toString (i + 1)) 9;
in
(builtins.map (
  { key, way }:
  k.rule "Change window focus ${way}. if exists other display on the way, focus it" [
    (
      k.map {
        key_code = key;
        modifiers.mandatory = [ "command" ];
      }
      |> k.toShell (sh "yabai -m window --focus ${way} || yabai -m display --focus ${way}")
    )
  ]
) compass)
++ (builtins.map (
  { key, way }:
  k.rule "Move window to ${way}. if exists window, move into it." [
    (
      k.map {
        key_code = key;
        modifiers.mandatory = [
          "command"
          "shift"
        ];
      }
      |> k.toShell (query "move-window.ts ${way}")
    )
  ]
) compass)
++ [
  (k.rule "Close app and focus other remain app." [
    (
      k.map {
        key_code = "q";
        modifiers.mandatory = [
          "command"
          "shift"
        ];
      }
      |> k.toShell (query "close-window.ts")
    )
  ])
]
++ (builtins.map (
  num:
  k.rule "Focus space ${num}. if not exists it, create untile it." [
    (
      k.map {
        key_code = num;
        modifiers.mandatory = [ "command" ];
      }
      |> k.toShell (query' "focus-space.ts ${num}")
    )
  ]
) numbers)
++ (builtins.map (
  num:
  k.rule "Move window to space ${num}. if not exist, create untile it." [
    (
      k.map {
        key_code = num;
        modifiers.mandatory = [
          "command"
          "shift"
        ];
      }
      |> k.toShell (query' "move-space.ts ${num}")
    )
  ]
) numbers)
++ (builtins.map (
  { key, way }:
  k.rule "Focus ${way} space in current display" [
    (
      k.map {
        key_code = "${key}_arrow";
        modifiers.mandatory = [ "command" ];
      }
      |> k.toShell (query' "focus-in-display.ts ${way}")
    )
  ]
) arrows)
++ [
  (k.rule "Format display sizes in current space like vim's <C-w>=." [
    (
      k.map {
        key_code = "equal_sign";
        modifiers.mandatory = [ "command" ];
      }
      |> k.toShell (sh "yabai -m space --balance")
    )
  ])
  (k.rule "Toggle fullscreen" [
    (
      k.map {
        key_code = "f";
        modifiers.mandatory = [ "command" ];
      }
      |> k.toShell (sh "yabai -m window --toggle zoom-fullscreen")
    )
  ])
  (k.rule "Toggle native fullscreen" [
    (
      k.map {
        key_code = "f";
        modifiers.mandatory = [
          "command"
          "shift"
        ];
      }
      |> k.toShell (sh "yabai -m window --toggle native-fullscreen")
    )
  ])
  (k.rule "Toggle current window to floating." [
    (
      k.map {
        key_code = "spacebar";
        modifiers.mandatory = [ "command" ];
      }
      |> k.toShell (sh "yabai -m window --toggle split")
    )
  ])
  (k.rule "Toggle split way." [
    (
      k.map {
        key_code = "spacebar";
        modifiers.mandatory = [
          "command"
          "shift"
        ];
      }
      |> k.toShell (sh "yabai -m window --toggle float && yabai -m window --grid 12:12:1:1:10:10")
    )
  ])
  (k.rule "Move current focused window to new space" [
    (
      k.map {
        key_code = "return_or_enter";
        modifiers.mandatory = [
          "command"
          "shift"
          "control"
        ];
      }
      |> k.toShell (query "move-to-new-space.ts")
    )
  ])
]

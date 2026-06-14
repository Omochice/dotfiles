# Helper library that mirrors the karabinerts authoring style on top of nix's
# pipe operator. A manipulator is built `from`-first and threaded through `to*`
# helpers; a rule wraps manipulators and is threaded through `ifApp`/`unless`.
{ }:
let
  addCondition =
    condition: manipulator:
    manipulator // { conditions = (manipulator.conditions or [ ]) ++ [ condition ]; };

  # `unless` only ever follows a single `ifApp`, so flipping every
  # frontmost_application_if to its _unless form is sufficient.
  flipToUnless =
    condition:
    if condition.type or "" == "frontmost_application_if" then
      condition // { type = "frontmost_application_unless"; }
    else
      condition;

  mapConditions =
    f: rule:
    rule
    // {
      manipulators = builtins.map (
        manipulator:
        manipulator
        // {
          conditions = builtins.map f (manipulator.conditions or [ ]);
        }
      ) rule.manipulators;
    };
in
rec {
  # Start a manipulator from a `from` definition.
  map = from: {
    type = "basic";
    inherit from;
  };

  # Attach an explicit `to` list to a manipulator.
  to = events: manipulator: manipulator // { to = events; };

  # Attach a single shell_command `to` event to a manipulator.
  # Named `toShell` rather than karabinerts' `to$`, since `$` is not a legal
  # character in a nix identifier.
  toShell = command: to [ { shell_command = command; } ];

  # Open an application, spawning a new instance.
  newApp = name: toShell ''open -n -a "${name}".app'';

  # Bring an application to the foreground.
  toApp = name: toShell ''open -a "${name}".app'';

  # Build a rule from a description and its manipulators.
  rule = description: manipulators: { inherit description manipulators; };

  # Restrict a rule to the given frontmost application bundle identifiers.
  ifApp =
    bundle_identifiers:
    mapConditionsAppend {
      type = "frontmost_application_if";
      inherit bundle_identifiers;
    };

  # Invert the most recently attached application condition.
  unless = mapConditions flipToUnless;

  mapConditionsAppend =
    condition: rule:
    rule
    // {
      manipulators = builtins.map (addCondition condition) rule.manipulators;
    };
}

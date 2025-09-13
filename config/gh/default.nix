{ pkgs, lib, ... }:
let
  extensions =
    pkgs.callPackage ../../_sources/generated.nix { }
    |> lib.attrsets.filterAttrs (name: _: name |> lib.strings.hasPrefix "gh-");
  runAs =
    name:
    {
      runtimeInputs,
      bashOptions,
      excludeShellChecks,
    }:
    text:
    pkgs.writeShellApplication {
      inherit
        name
        runtimeInputs
        text
        bashOptions
        excludeShellChecks
        ;
    };
  readShellExetension =
    {
      src,
      depends,
      bashOptions ? [
        "errexit"
        "nounset"
        "pipefail"
      ],
      excludeShellChecks ? [ ],
    }:
    (builtins.readFile "${src.src}/${src.pname}")
    |> runAs src.pname {
      inherit bashOptions excludeShellChecks;
      runtimeInputs = depends;
    }
    |> (program: {
      name = program.name;
      path = "${program}/bin";
    });

  shell-extensions =
    [
      {
        src = extensions.gh-q;
        depends = [
          pkgs.gh
          pkgs.ghq
          pkgs.fzf
          pkgs.coreutils
        ];
        bashOptions = [
          "errexit"
          "nounset"
          # NOTE: If you confirm before you accumulate enough candidates, gh api will pipefail.
        ];
        excludeShellChecks = [
          "SC2016"
          "SC2181"
        ];
      }
      {
        src = extensions.gh-fzgist;
        depends = [
          pkgs.gh
          pkgs.fzf
          pkgs.gawk
          pkgs.findutils
        ];
      }
      {
        src = extensions.gh-userfetch;
        depends = [
          pkgs.jq
          pkgs.coreutils
        ];
        excludeShellChecks = [
          "SC2059"
          "SC2086"
        ];
      }
    ]
    |> builtins.map (ext: readShellExetension ext);
  native-extensions = [
    {
      name = "gh-dash";
      path = "${pkgs.gh-dash}/bin";
    }
    {
      name = "gh-triage";
      path = "${pkgs.gh-triage}/bin";
    }
  ];
in
{
  xdg.configFile = {
    "gh/config.yml".source = ./config.yml;
  };
  xdg.dataFile."gh/extensions" = {
    source = pkgs.linkFarm "gh-extensions" (shell-extensions ++ native-extensions);
  };
}

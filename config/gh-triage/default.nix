{ ... }:
let
  config = {
    done = {
      max = 1000;
      conditions = [
        "merged"
        "is_issue && closed"
        "closed && author contains '[bot]'"
      ];
    };
    read = {
      max = 1000;
      conditions = [
        "is_release"
        "author contains '[bot]' && me not in reviewers"
        "is_pull_request && me not in reviewers && approved"
      ];
    };
    list = {
      max = 1000;
      conditions = [
        "*"
      ];
    };
  };
in
{
  xdg.dataFile = {
    # NOTE: toYAML is not provided by nixpkgs, so we use toJSON here.
    "gh-triage/default.yml".text = config |> builtins.toJSON;
  };
}

# NOTE: this is from https://github.com/natsukium/dotfiles/blob/ef5499ccb9f2381b4aea5147292e4fefc3efb96a/nix/modules/darwin/default.nix
{
  imports = (
    builtins.map (module: ./. + "/${module}") (
      builtins.filter (x: x != "default.nix") (builtins.attrNames (builtins.readDir ./.))
    )
  );
}

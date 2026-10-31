{ ... }:
{
  programs.my-jj = {
    enable = true;
    settings = {
      # keep-sorted start block=yes
      "--scope" = [
        {
          "--when".repositories = [ "~/ghq/github.com/Omochice/" ];
          user = {
            name = "Omochice";
            email = "mochice.mls.ntl@gmail.com";
          };
        }
      ];
      ui = {
        diff-formatter = ":git";
        editor = "nvim";
        pager = "delta";
      };
      # keep-sorted end
    };
  };
}

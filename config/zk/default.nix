{ pkgs, ... }:
{
  programs.zk = {
    enable = true;
    settings = {
      note = {
        language = "ja";
        default-title = "Untitled";
        filename = "{{id}}-{{slug title}}";
        extension = "md";
        template = "default.md";
        id-charset = "alphanum";
        id-length = 4;
        id-case = "lower";
      };
      tool = {
        editor = "nvim";
        fzf-preview = "${pkgs.bat}/bin/bat -p --color always {-1}";
      };
    };
  };
}

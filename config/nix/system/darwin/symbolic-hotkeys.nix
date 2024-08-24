{ ... }:
{
  # Disable S-Space
  "60" = {
    enabled = false;
    value = {
      parameters = [
        32
        49
        262144
      ];
      type = "standard";
    };
  };
  "61" = {
    enabled = false;
    value = {
      parameters = [
        32
        49
        786432
      ];
      type = "standard";
    };
  };
  # Show spotlight on Mod-r
  "64" = {
    enabled = true;
    value = {
      parameters = [
        114
        15
        1048576
      ];
      type = "standard";
    };
  };
}

# Pure karabiner.json content. Kept separate from default.nix so the generated
# profile is importable and verifiable without home-manager's module arguments.
{ k }:
let
  rules = import ./rules.nix { inherit k; };
  yabai = import ./yabai.nix { inherit k; };
in
{
  profiles = [
    {
      name = "Default profile";
      selected = true;
      virtual_hid_keyboard = {
        country_code = 0;
        keyboard_type_v2 = "jis";
      };
      # GUI-managed device remaps are owned by nix as a verbatim snapshot, since
      # activation rewrites the whole file on every rebuild.
      devices = [
        {
          identifiers = {
            is_keyboard = true;
            product_id = 834;
            vendor_id = 1452;
          };
          simple_modifications = [
            {
              from = {
                key_code = "japanese_eisuu";
              };
              to = [ { key_code = "escape"; } ];
            }
            {
              from = {
                key_code = "left_command";
              };
              to = [ { key_code = "left_option"; } ];
            }
            {
              from = {
                key_code = "right_option";
              };
              to = [ { key_code = "right_command"; } ];
            }
          ];
        }
        {
          identifiers = {
            is_keyboard = true;
            product_id = 34;
            vendor_id = 1278;
          };
          simple_modifications = [
            {
              from = {
                key_code = "grave_accent_and_tilde";
              };
              to = [ { key_code = "japanese_kana"; } ];
            }
          ];
        }
      ];
      complex_modifications.rules = rules ++ yabai;
    }
  ];
}

{ specialArgs, ... }:
let
  inherit (specialArgs) user home;
  documents = "${home}/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents";
  # NSEvent.ModifierFlags
  modifier = {
    shift = 131072;
    control = 262144;
    option = 524288;
    function = 8388608;
  };
  # Carbon kVK_* virtual key codes
  keyCode = {
    return = 36;
    quote = 39;
    tab = 48;
    space = 49;
    delete = 51;
    escape = 53;
    jisEisu = 102;
    jisKana = 104;
    forwardDelete = 117;
    leftArrow = 123;
    rightArrow = 124;
    downArrow = 125;
    upArrow = 126;
  };
in
{
  # macSKK is sandboxed and cannot follow a symlink into /nix/store, so the file is copied instead.
  system.activationScripts.postActivation.text = ''
    if [ -d "${documents}" ]; then
      sudo --user=${user} -- mkdir -p "${documents}/Settings"
      sudo --user=${user} -- install -m 0644 ${./kana-rule.conf} "${documents}/Settings/kana-rule.conf"
    fi
  '';
  system.defaults.CustomUserPreferences."net.mtgto.inputmethod.macSKK" = {
    completionConfirmationTimeLimit = 700;
    dateConversions = {
      conversions = [
        {
          calendar = "gregorian";
          format = "yyyy-MM-dd";
          locale = "en_US";
        }
        {
          calendar = "gregorian";
          format = "yyyy/MM/dd";
          locale = "en_US";
        }
        {
          calendar = "gregorian";
          format = "yyyy年M月d日";
          locale = "en_US";
        }
        {
          calendar = "japanese";
          format = "Gy年M月d日";
          locale = "ja_JP";
        }
      ];
      yomis = [
        {
          relative = "now";
          yomi = "きょう";
        }
        {
          relative = "yesterday";
          yomi = "きのう";
        }
        {
          relative = "tomorrow";
          yomi = "あした";
        }
        {
          relative = "now";
          yomi = "today";
        }
        {
          relative = "yesterday";
          yomi = "yesterday";
        }
        {
          relative = "tomorrow";
          yomi = "tomorrow";
        }
      ];
    };
    dictionaries = [
      {
        enabled = true;
        encoding = 3;
        filename = "SKK-JISYO.L";
        saveToUserDict = true;
        type = "traditional";
      }
    ];
    directModeBundleIdentifiers = [
      "com.github.wez.wezterm"
      "com.natsukium.felis"
    ];
    keyBindingSets = [
      {
        id = "azik";
        keyBindings = [
          {
            action = "hiragana";
            inputs = [
              {
                key = "j";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "toggleKana";
            inputs = [
              {
                key = "@";
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "toggleAndFixKana";
            inputs = [
              {
                key = "@";
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "hankakuKana";
            inputs = [
              {
                key = "@";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "direct";
            inputs = [
              {
                key = "l";
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "zenkaku";
            inputs = [
              {
                key = "l";
                modifierFlags = modifier.shift;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "abbrev";
            inputs = [
              {
                key = "/";
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "japanese";
            inputs = [ ];
          }
          {
            action = "stickyShift";
            inputs = [
              {
                key = keyCode.quote;
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "enter";
            inputs = [
              {
                key = keyCode.return;
                modifierFlags = 0;
                optionalModifierFlags = (builtins.bitOr modifier.shift modifier.option);
              }
            ];
          }
          {
            action = "space";
            inputs = [
              {
                key = keyCode.space;
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "backwardCandidate";
            inputs = [
              {
                key = "x";
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "tab";
            inputs = [
              {
                key = keyCode.tab;
                modifierFlags = 0;
                optionalModifierFlags = modifier.shift;
              }
            ];
          }
          {
            action = "backspace";
            inputs = [
              {
                key = keyCode.delete;
                modifierFlags = 0;
                optionalModifierFlags = modifier.shift;
              }
              {
                key = "h";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "delete";
            inputs = [
              {
                key = keyCode.forwardDelete;
                modifierFlags = modifier.function;
                optionalModifierFlags = 0;
              }
              {
                key = "d";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "cancel";
            inputs = [
              {
                key = keyCode.escape;
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
              {
                key = "g";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "left";
            inputs = [
              {
                key = keyCode.leftArrow;
                modifierFlags = modifier.function;
                optionalModifierFlags = modifier.shift;
              }
              {
                key = "b";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "right";
            inputs = [
              {
                key = keyCode.rightArrow;
                modifierFlags = modifier.function;
                optionalModifierFlags = modifier.shift;
              }
              {
                key = "f";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "down";
            inputs = [
              {
                key = keyCode.downArrow;
                modifierFlags = modifier.function;
                optionalModifierFlags = modifier.shift;
              }
              {
                key = "n";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "up";
            inputs = [
              {
                key = keyCode.upArrow;
                modifierFlags = modifier.function;
                optionalModifierFlags = modifier.shift;
              }
              {
                key = "p";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "startOfLine";
            inputs = [
              {
                key = "a";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "endOfLine";
            inputs = [
              {
                key = "e";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "unregister";
            inputs = [
              {
                key = "x";
                modifierFlags = modifier.shift;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "registerPaste";
            inputs = [
              {
                key = "y";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "reconvert";
            inputs = [
              {
                key = "/";
                modifierFlags = modifier.control;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "affix";
            inputs = [
              {
                key = ".";
                modifierFlags = modifier.shift;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "eisu";
            inputs = [
              {
                key = keyCode.jisEisu;
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
          {
            action = "kana";
            inputs = [
              {
                key = keyCode.jisKana;
                modifierFlags = 0;
                optionalModifierFlags = 0;
              }
            ];
          }
        ];
        version = 1;
      }
    ];
    selectCandidateKeys = "ASDFGHJKL";
    selectedKeyBindingSetId = "azik";
    skkserv = {
      address = "127.0.0.1";
      enableCompletion = false;
      enabled = false;
      encoding = 3;
      port = 1178;
      requestEncoding = 3;
      responseEncoding = 3;
      saveToUserDict = true;
    };
    workarounds = [
      {
        bundleIdentifier = "net.kovidgoyal.kitty";
        insertBlankString = true;
        showMarkerWhenEmpty = false;
        treatFirstCharacterAsMarkedText = false;
      }
      {
        bundleIdentifier = "jp.naver.line.mac";
        insertBlankString = true;
        showMarkerWhenEmpty = false;
        treatFirstCharacterAsMarkedText = false;
      }
      {
        bundleIdentifier = "org.alacritty";
        insertBlankString = true;
        showMarkerWhenEmpty = false;
        treatFirstCharacterAsMarkedText = false;
      }
      {
        bundleIdentifier = "co.zeit.hyper";
        insertBlankString = false;
        showMarkerWhenEmpty = false;
        treatFirstCharacterAsMarkedText = true;
      }
    ];
  };
}

{
  lib,
  pkgs,
  ...
}:
let
  actionIds = builtins.fromJSON (builtins.readFile ./action-ids.json);

  workspaceBarHeight = 32.0;

  workspaceNumbers = lib.range 1 9;

  workspaceBindings = lib.listToAttrs (
    lib.concatMap (n: [
      (lib.nameValuePair "switchWorkspace.${toString (n - 1)}" "Command+${toString n}")
      (lib.nameValuePair "moveToWorkspace.${toString (n - 1)}" "Shift+Command+${toString n}")
    ]) workspaceNumbers
  );

  bindings = workspaceBindings // {
    "focus.left" = "Command+H";
    "focus.down" = "Command+J";
    "focus.up" = "Command+K";
    "focus.right" = "Command+L";
    "move.left" = "Shift+Command+H";
    "move.down" = "Shift+Command+J";
    "move.up" = "Shift+Command+K";
    "move.right" = "Shift+Command+L";
    "switchWorkspace.previous" = "Command+Left Arrow";
    "switchWorkspace.next" = "Command+Right Arrow";
    closeFocusedWindow = "Shift+Command+Q";
    balanceSizes = "Command+Equal";
    toggleContainerFullPrimarySpan = "Command+F";
    toggleNativeFullscreen = "Shift+Command+F";
    toggleOverview = "Command+Space";
    toggleFocusedWindowFloating = "Shift+Command+Space";
  };

  hotkeys = map (id: {
    inherit id;
    binding = bindings.${id} or "Unassigned";
  }) actionIds;

  workspaces = map (n: {
    id = "00000000-0000-4000-8000-00000000000${toString n}";
    name = toString n;
    monitorAssignment.type = "main";
    layoutType = "niri";
  }) workspaceNumbers;

  floatRule =
    id: match:
    {
      inherit id;
      layout = "float";
    }
    // match;

  artoBackgroundHelper = floatRule "6f1a0d2e-0000-4000-8000-000000000006" {
    bundleId = "";
    titleRegex = "^tao window$";
  };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    programs.omniwm = {
      enable = true;
      settings = {
        schemaVersion = 3;

        general = {
          animationsEnabled = true;
          defaultLayoutType = "niri";
          hotkeysEnabled = true;
          hyperKeyModifiers = "Control+Option+Shift+Command";
          ipcEnabled = true;
          preventSleepEnabled = false;
          systemHyperTrigger = "None";
          updateChecksEnabled = false;
        };

        focus = {
          crossesMonitorAtEdge = true;
          moveCrossesMonitorAtEdge = true;
          followsMouse = false;
          followsWindowToMonitor = false;
          lockModifier = "off";
          moveMouseToFocusedWindow = false;
          raiseOnMouseFocus = false;
        };

        mouseWarp = {
          constrainToArrangement = false;
          enabled = false;
          margin = 1;
        };

        routing = {
          mode = "macOS";
          arrangements = [ ];
        };

        gaps = {
          size = 12.0;
          fullscreenUsesOuterGaps = false;
          outer = {
            bottom = 12.0;
            left = 12.0;
            right = 12.0;
            top = workspaceBarHeight + 12.0;
          };
        };

        niri = {
          alwaysCenterSingleColumn = false;
          centerFocusedColumn = "never";
          infiniteLoop = false;
          singleWindowFit = "fill";
          visibleContainerCount = 2;
        };

        dwindle = {
          defaultSplitRatio = 1.0;
          moveToRootStable = true;
          singleWindowFit = "fill";
          smartSplit = false;
          splitWidthMultiplier = 1.0;
          useGlobalGaps = true;
        };

        borders = {
          enabled = true;
          width = 3.0;
          color = {
            red = 0.12941176470588237;
            green = 0.7803921568627451;
            blue = 0.9098039215686274;
            alpha = 1.0;
          };
        };

        overview = {
          zoom = 1.0;
          backdrop = {
            red = 0.05;
            green = 0.05;
            blue = 0.08;
            alpha = 1.0;
          };
          windowBorders = {
            normal = {
              red = 0.3;
              green = 0.3;
              blue = 0.35;
              alpha = 0.5;
            };
            hovered = {
              red = 0.4;
              green = 0.6;
              blue = 1.0;
              alpha = 1.0;
            };
            selected = {
              red = 0.3;
              green = 0.8;
              blue = 0.4;
              alpha = 1.0;
            };
          };
        };

        workspaceBar = {
          enabled = true;
          backgroundOpacity = 1.0;
          deduplicateAppIcons = true;
          excludedBundleIDs = [ ];
          height = workspaceBarHeight;
          hideEmptyWorkspaces = true;
          hideInNativeFullscreen = true;
          iconOverrides = { };
          notchActiveZoneWidth = 180.0;
          notchMode = "off";
          position = "overlappingMenuBar";
          reserveLayoutSpace = false;
          revealHoldMilliseconds = 200.0;
          revealModifier = "off";
          showFloatingWindows = true;
          showLabels = true;
          systemStatsButton = true;
          windowLevel = "floating";
          xOffset = -393.0;
          yOffset = 0.0;
        };

        gestures = {
          mouseMoveModifierKey = "option";
          mouseResizeModifierKey = "option";
          scrollEnabled = true;
          scrollModifierKey = "optionShift";
          scrollSensitivity = 5.0;
          fingerCount = 3;
          invertDirection = false;
          trackpadScrollStyle = "snap";
          workspaceSwipeAxis = "horizontal";
          workspaceSwipeEnabled = false;
          workspaceSwipeFingerCount = 3;
        };

        statusBar = {
          showAppNames = false;
          showWorkspaceName = false;
          useWorkspaceId = false;
        };

        hiddenBar = {
          enabled = false;
          hiddenBundleIDs = [ ];
          rehideIntervalSeconds = 5.0;
        };

        clipboard = {
          historyEnabled = false;
          maxItems = 200;
          maxItemBytes = 8388608;
          maxTotalBytes = 67108864;
        };

        quakeTerminal = {
          enabled = false;
          animationDuration = 0.2;
          autoHide = true;
          backgroundEffect = "standardBlur";
          heightPercent = 50.0;
          monitorMode = "mouseCursor";
          position = "top";
          widthPercent = 100.0;
        };

        scratchpads.labels = { };

        appearance.mode = "automatic";

        inherit hotkeys workspaces;

        appRules = [
          (floatRule "6f1a0d2e-0000-4000-8000-000000000001" {
            bundleId = "org.pqrs.Karabiner-Elements.Settings";
          })
          (floatRule "6f1a0d2e-0000-4000-8000-000000000002" {
            bundleId = "org.pqrs.Karabiner-EventViewer";
          })
          (floatRule "6f1a0d2e-0000-4000-8000-000000000004" {
            bundleId = "com.apple.SystemProfiler";
          })
          (floatRule "6f1a0d2e-0000-4000-8000-000000000005" {
            bundleId = "com.apple.finder";
          })
          artoBackgroundHelper
        ];

        monitorBarOverrides = [ ];
        monitorDwindleOverrides = [ ];
        monitorGapOverrides = [ ];
        monitorNiriOverrides = [ ];
        monitorOrientationOverrides = [ ];
      };
    };
  };
}

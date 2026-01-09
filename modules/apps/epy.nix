# --- Epy ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  wrapped-epy = pkgs.python3Packages.buildPythonPackage {
    pname = "epy-reader";
    version = "2023.6.11";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "wustho";
      repo = "epy";
      rev = "6b0e9fe0773f05fdf844b574f0f28df3961f60ab";
      sha256 = "sha256-nUccxSg2sp4FVReQhfx/R8EC9KuzoBuH8JsWKwrGiSQ=";
    };

    nativeBuildInputs = with pkgs.python3Packages; [
      poetry-core
    ];
    propagatedBuildInputs = with pkgs.python3Packages; [
      standard-imghdr
    ];
    doCheck = false; # no tests in repo
  };

  # WARN: These settings are not actually applied!
  # > A patch is probably required to make wrapping work, as the database
  # > file uses the same path as the configuration file. I could use
  # > home-manager here, but honestly I do not want to.
  epy-settings = ''
    {
      "Setting": {
        "DefaultViewer": "mpv",
        "DictionaryClient": "auto",
        "ShowProgressIndicator": true,
        "PageScrollAnimation": false,
        "MouseSupport": true,
        "StartWithDoubleSpread": false,
        "DefaultColorFG": -1,
        "DefaultColorBG": -1,
        "DarkColorFG": 252,
        "DarkColorBG": 235,
        "LightColorFG": 238,
        "LightColorBG": 253,
        "SeamlessBetweenChapters": false,
        "PreferredTTSEngine": null,
        "TTSEngineArgs": []
      },
      "Keymap": {
        "ScrollUp": "k",
        "ScrollDown": "j",
        "PageUp": "h",
        "PageDown": "l",
        "NextChapter": "L",
        "PrevChapter": "H",
        "BeginningOfCh": "g",
        "EndOfCh": "G",
        "Shrink": "-",
        "Enlarge": "+",
        "SetWidth": "=",
        "Metadata": "M",
        "DefineWord": "d",
        "TableOfContents": "t",
        "Follow": "f",
        "OpenImage": "o",
        "RegexSearch": "/",
        "ShowHideProgress": "s",
        "MarkPosition": "m",
        "JumpToPosition": "`",
        "AddBookmark": "b",
        "ShowBookmarks": "B",
        "Quit": "q",
        "Help": "?",
        "SwitchColor": "c",
        "TTSToggle": "!",
        "DoubleSpreadToggle": "D",
        "Library": "R"
      }
    }
  '';

in
{

  options.modules = {
    apps.epy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables the Epy e-book reader.
      '';
    };
  };

  config =
    lib.mkAlwaysThenIf config.modules.apps.epy
      {
        modules.export-apps.epy = wrapped-epy;
      }
      {
        environment.systemPackages = [ wrapped-epy ];
      };

}

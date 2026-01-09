# --- Epy ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # wrapped-epy = pkgs.python3Packages.buildPythonApplication {
  #   pname = "epy";
  #   version = "master";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "wustho";
  #     repo = "epy";
  #     rev = "6b0e9fe0773f05fdf844b574f0f28df3961f60ab";
  #     sha256 = "sha256-nUccxSg2sp4FVReQhfx/R8EC9KuzoBuH8JsWKwrGiSQ=";
  #   };
  #   pyproject = true;
  #   build-system = [ pkgs.python3Packages.setuptools ];
  #   doCheck = false;
  # };

  # inherit (inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
  #
  # epy-src = pkgs.fetchFromGitHub {
  #   owner = "wustho";
  #   repo = "epy";
  #   rev = "6b0e9fe0773f05fdf844b574f0f28df3961f60ab";
  #   sha256 = "sha256-nUccxSg2sp4FVReQhfx/R8EC9KuzoBuH8JsWKwrGiSQ=";
  # };
  #
  # wrapped-epy = mkPoetryApplication {
  #   projectDir = epy-src;
  #   checkGroups = [];
  #   extras = [];
  #   # python = pkgs.python3;
  # };

  wrapped-epy = pkgs.python312Packages.buildPythonPackage {
    pname = "epy-reader";
    version = "2023.6.11";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "wustho";
      repo = "epy";
      rev = "6b0e9fe0773f05fdf844b574f0f28df3961f60ab";
      sha256 = "sha256-nUccxSg2sp4FVReQhfx/R8EC9KuzoBuH8JsWKwrGiSQ=";
    };

    nativeBuildInputs = [ pkgs.python312Packages.poetry-core ];
    doCheck = false; # no tests in repo
  };

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

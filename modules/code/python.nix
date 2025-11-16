# --- Python ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.python = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for Python.
      '';
    };
  };

  config = lib.mkIf config.modules.code.python {

    environment.systemPackages = with pkgs; [

      sqlite # Simple database, for data analytics.

      (python312.withPackages (
        p: with p; [

          # Jupyter Notebook
          jupyter
          ipython

          # Packages
          numpy
          pandas
          matplotlib
          scikit-learn
          seaborn
          statsmodels
          anysqlite

        ]
      ))

    ];

  };
}

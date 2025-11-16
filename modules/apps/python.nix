# --- Python ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.programming.python = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Python.
      '';
    };
  };

  config = lib.mkIf config.modules.programming.python {

    environment.systemPackages = with pkgs; [

      sqlite
      # conda

      (python312.withPackages (
        p: with p; [

          # Jupyter notebook.
          jupyter
          ipython

          # Other packages.
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

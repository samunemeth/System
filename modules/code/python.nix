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
        Includes LSP server, formatter, Jupyter Notebook,
        and Python packages.
      '';
    };
  };

  config = lib.mkIf config.modules.code.python {

    environment.systemPackages = with pkgs; [

      sqlite # Simple database, for data analytics.

      (python3.withPackages (
        p: with p; [

          # LSP server.
          python-lsp-server
          pylsp-rope
          pyflakes

          # Formatter.
          autopep8

          # Jupyter Notebook
          jupyter
          ipython

          # General
          numpy

          # Data Analytics
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

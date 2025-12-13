# --- IPython Calculator ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # Unreasonably powerful python calculator for about 300MiB.
  ipycalc =
    let

      # Python code to run on startup.
      ipyinit = pkgs.writers.writeText "ipyinit.py" /* python */ ''
        from sympy import *
        init_printing()
        x, y, z = symbols('x y z')
        k, m, n = symbols('k m n', integer=True)
        f, g, h = symbols('f g h', cls=Function)
        A, B, C = MatrixSymbol('A', 3, 3), MatrixSymbol('B', 3, 3), MatrixSymbol('C', 3, 3)
        a, b, c = MatrixSymbol('a', 3, 1), MatrixSymbol('b', 3, 1), MatrixSymbol('c', 3, 1)
        ITALIC = "\033[3m"
        BOLD = "\033[1m"
        RESET = "\033[0m"
        print(f"""\
        {ITALIC}IPython based calculator running with:{RESET}

        {BOLD}>>>{RESET} from sympy import *

        {ITALIC}You have the following available:{RESET}

          x y z  ->  Numers
          k m n  ->  Integers
          f g h  ->  Funstions
          A B C  ->  Matrices (3x3)
          a b c  ->  Vectors (3)\
        """)
      '';

      # Python distribution with needed packages.
      calcpython = pkgs.python312.withPackages (p: [
        p.sympy
        p.ipython
      ]);

    in
    pkgs.writers.writeBashBin "calc" ''
      PYTHONSTARTUP=${ipyinit} ${calcpython}/bin/ipython \
        --no-banner --no-tip --no-confirm-exit \
        --TerminalInteractiveShell.autosuggestions_provider=None
    '';

in
{

  options.modules = {
    apps.ipycalc = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables the IPython Calculator.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.ipycalc {

    environment.systemPackages = [ ipycalc ];

  };

}

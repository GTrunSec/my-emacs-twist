{
  pkgs,
  centaur,
}: {
  emacsPackage = pkgs.emacsUnstable;

  lockDir = ./lock;
  sandboxArgs = {
    enableWindow = false;
    extraBubblewrapOptions = [
      "--ro-bind" "${centaur}/lisp" "$HOME/.emacs.d/lisp"
      "--ro-bind" "${centaur}/site-lisp" "$HOME/.emacs.d/site-lisp"
    ];
  };
  initFiles = [
    (centaur + "/init.el")
  ];
  extraPackages = [
    "use-package"
    "readable-typo-theme"
    "readable-mono-theme"
  ];
  extraRecipeDir = ./recipes;
  extraInputOverrides = {};
}

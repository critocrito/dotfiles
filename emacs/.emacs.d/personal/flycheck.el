(prelude-require-package 'flycheck-color-mode-line)

(eval-after-load "flycheck"
  '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

(evil-leader/set-key
  "fl" 'flycheck-list-errors
  "fn" 'flycheck-next-error
  "fp" 'flycheck-previous-error)

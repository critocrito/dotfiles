;;; yasnippet-cfg --- Configure yasnippet

;;; Commentary:

;;; Code:
(prelude-require-package 'yasnippet)

(yas-global-mode 1)
;; (add-hook 'prog-mode-hook
;;           '(lambda ()
;;              (yas-minor-mode)))

(define-key yas-minor-mode-map (kbd "<tab>") nil)
(define-key yas-minor-mode-map (kbd "TAB") nil)
(define-key yas-minor-mode-map (kbd "M-TAB") 'yas-expand)
(evil-leader/set-key
  "y" 'yas-insert-snippet)

(setq yas/indent-line nil)

;;; yasnippet.el ends here

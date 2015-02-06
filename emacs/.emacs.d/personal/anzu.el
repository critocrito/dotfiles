;;; package -- anzul.el

;;; Commentary:

;;; Code:

(global-set-key (kbd "M-%") 'anzu-query-replace)
(global-set-key (kbd "C-M-%") 'anzu-query-replace-regexp)

(evil-leader/set-key
  "A" 'anzu-replace-at-cursor-thing)

;;; anzul,el ends here

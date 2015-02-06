;;; eshell.el --- Helper functions for eshell

;;; Commentary:
;; http://www.howardism.org/Technical/Emacs/eshell-fun.html
;; http://www.masteringemacs.org/article/complete-guide-mastering-eshell

;;; Code:
(require 'eshell)
(require 'em-smart)

(defun eshell-here ()
  "Opens up a new shell in the directory location of the current buffer's file.
The eshell is renamed to match that directory to make multiple eshell windows
easier."
  (interactive)
  (let* ((parent (if (buffer-file-name)
                     (file-name-directory (buffer-file-name))
                   default-directory))
         (height (/ (window-total-height) 3))
         (name   (car (last (split-string parent "/" t)))))
    (split-window-vertically (- height))
    (other-window 1)
    (eshell "new")
    (rename-buffer (concat "*eshell: " name "*"))

    (insert (concat "ls"))
    (eshell-send-input)))

(defun eshell/open (parent)
  "Open a new eshell in a parent directory."
  (let* ((height (/ (window-total-height) 3))
         (name (car (last (split-string parent "/" t)))))
    (split-window-vertically (- height))
    (other-window 1)
    (eshell "new")
    (rename-buffer (concat "*eshell: " name "*"))
    (insert (concat "ls"))
    (eshell-send-input)))

(defun eshell/project-root ()
  "Open a new eshell in the projectile root directory of the current buffer."
  (interactive)
  (eshell/open (projectile-project-root)))

(evil-leader/set-key
  "e" 'eshell-here)

(defun eshell/x ()
  "Close an open eshell buffer."
  (insert "exit")
  (eshell-send-input)
  (delete-window))

(setq eshell-where-to-jump 'begin)
(setq eshell-review-quick-commands nil)
(setq eshell-smart-space-goes-to-end t)
:
(provide 'eshell)
;;; eshell.el ends here

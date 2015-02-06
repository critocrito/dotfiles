(prelude-require-package 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader ",")
(evil-leader/set-key
  "," 'helm-projectile
  "\\" 'comment-or-uncomment-region
  "w" 'save-buffer
  "b" 'helm-mini
  "k" 'kill-buffer
  "J" 'prelude-switch-to-previous-buffer
  "U" 'undo-tree-visualize
  "Y" 'browse-kill-ring
  "X" 'execute-extended-command
  "p" 'projectile-switch-project)

;; Get back some default behavior of emacs
(global-set-key (kbd "C-e") 'move-end-of-line)
(global-set-key (kbd "C-a") 'prelude-move-beginning-of-line)

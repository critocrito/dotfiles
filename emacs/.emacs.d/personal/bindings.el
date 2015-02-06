;; map the window manipulation keys to control 0, 1, 2, o
(global-set-key (kbd "M-3") 'split-window-horizontally) ; was digit-argument
(global-set-key (kbd "M-2") 'split-window-vertically) ; was digit-argument
(global-set-key (kbd "M-1") 'delete-other-windows) ; was digit-argument
(global-set-key (kbd "M-0") 'delete-window) ; was digit-argument
(global-set-key (kbd "M-o") 'other-window) ; was facemenu-keymap

;; Expand Region
(global-set-key (kbd "C-@") 'er/expand-region)

;; Get back some default behavior of emacs
(global-set-key (kbd "C-e") 'move-end-of-line)
(global-set-key (kbd "C-a") 'prelude-move-beginning-of-line)

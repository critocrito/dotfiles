; Disable that damn guru mode
(guru-mode -1)

; display line and column numbers
(global-linum-mode t)
(setq line-number-mode t)
(setq column-number-mode t)

; line wrapping
(setq-default fill-column 78)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

; windmove for easier pane navigation
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

; show the end of the buffer
(setq-default indicate-empty-line t)

(global-hl-line-mode t)

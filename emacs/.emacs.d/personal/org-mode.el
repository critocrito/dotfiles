;;; package --- summary

;;; Commentary:

;;; Code:

(require 'org-helpers)
(require 'org-habit)
;; (require 'org-pomodoro)

; Apply this mode to files using this file ending
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\)\'" . org-mode))
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\)$" . org-mode))

; Set Some variables
(setq org-directory "~/.org")
(setq org-agenda-files (list (expand-file-name "uyb.org" org-directory)
                             (expand-file-name "uyb.org_archive" org-directory)
                             (expand-file-name "projects.org" org-directory)
                             (expand-file-name "projects.org_archive" org-directory)
                             (expand-file-name "tasks.org" org-directory)
                             (expand-file-name "tasks.org_archive" org-directory)
                             (expand-file-name "reading.org" org-directory)
                             (expand-file-name "reading.org_archive" org-directory)
                             (expand-file-name "calendar.org" org-directory)))

(setq org-default-notes-file (expand-file-name "notes.org" org-directory))

(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/.org/inbox.org" "Inbox")
         "* TODO %?\n%U\n%a\n")
        ("r" "Reading" entry (file+headline "~/.org/reading.org" "Reading")
         "* TODO %?\n%U\n%a\n")
        ("j" "Journal" entry (file+datetree "~/.org/journal.org")
         "* %?\n%U\n")))

; Make sure that we immediately can type since we use evil mode
(add-hook 'org-capture-mode-hook 'evil-insert-state)

; TODO keywords
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
        (sequence "WAITING(w@/!)" "HOLD(h@/!)" "SOMEDAY(o)" "|" "CANCELLED(c@/!)")))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "green" :weight bold)
              ("WAITING" :foreground "yellow" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "cyan")
              ("SOMEDAY" :foreground "black" :weight bold))))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

; Refile setup
; Targets include this file and any file contributing to the agenda - up to 9 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))

; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path t)

; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)

; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

; Use IDO for both buffer and file completion and ido-everywhere to t
(setq org-completion-handler 'helm)
(when (and (boundp 'org-completion-handler)
               (require 'helm nil t))
      (defun org-helm-completion-handler
          (prompt collection &optional predicate require-match
                  initial-input hist def inherit-input-method)
        (helm-comp-read prompt
                        collection
                        ;; the character \ is filtered out by default ;(
                        :fc-transformer nil
                        :test predicate
                        :must-match require-match
                        :initial-input initial-input
                        :history hist
                        :default def))
      (setq org-completion-handler 'org-helm-completion-handler))

; Use the current window for indirect buffer display
(setq org-indirect-buffer-display 'current-window)

;;;; Refile settings
; Exclude DONE state tasks from refile targets
(defun bh/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))

(setq org-refile-target-verify-function 'bh/verify-refile-target)

; Use utf-8 for all org files
(setq org-export-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-charset-priority 'unicode)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

; Startup in folded view
(setq org-startup-folded t)

;; Standard key bindings
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(global-set-key "\C-cc" 'org-capture)
;; (global-set-key "\M-x" 'org-insert-heading)

; Start and stop a pomodoro
(global-set-key (kbd "C-c C-x C-i") 'org-clock-in)
(global-set-key (kbd "C-c C-x C-o") 'org-clock-out)

;; Shortcuts
;; (define-key global-map "\C-cr"
;;   (lambda () (interactive) (org-capture nil "r")))
;; (define-key global-map "\C-cj"
;;   (lambda () (interactive) (org-capture nil "j")))

; Configure org-habit
;; display the tags farther right
(setq org-agenda-tags-column -102)
;; display the org-habit graph right of the tags
(setq org-habit-graph-column 102)
(setq org-habit-following-days 7)
(setq org-habit-preceding-days 21)

(defun custom-org-agenda-mode-defaults ()
  (org-defkey org-agenda-mode-map "W" 'oh/agenda-remove-restriction)
  (org-defkey org-agenda-mode-map "N" 'oh/agenda-restrict-to-subtree)
  (org-defkey org-agenda-mode-map "P" 'oh/agenda-restrict-to-project)
  (org-defkey org-agenda-mode-map "q" 'bury-buffer)
  (org-defkey org-agenda-mode-map "I" 'org-clock-in)
  (org-defkey org-agenda-mode-map "O" 'org-clock-in)
  (org-defkey org-agenda-mode-map (kbd "C-c C-x C-i") 'org-clock-in)
  (org-defkey org-agenda-mode-map (kbd "C-c C-x C-o") 'org-clock-out))

(add-hook 'org-agenda-mode-hook 'custom-org-agenda-mode-defaults 'append)

(setq org-agenda-custom-commands
      '(("a" "Agenda"
       ((agenda "" nil)
          (alltodo ""
                   ((org-agenda-overriding-header "Tasks to Refile")
                    (org-agenda-files '("~/.org/inbox.org"))
                    (org-agenda-skip-function
                     '(oh/agenda-skip :headline-if-restricted-and '(todo)))))
          (tags-todo "-CANCELLED/!-HOLD-WAITING"
                     ((org-agenda-overriding-header "Stuck Projects")
                      (org-agenda-skip-function
                       '(oh/agenda-skip :subtree-if '(inactive non-project non-stuck-project habit scheduled deadline)))))
          (tags-todo "-WAITING-CANCELLED/!NEXT"
                     ((org-agenda-overriding-header "Next Tasks")
                      (org-agenda-skip-function
                       '(oh/agenda-skip :subtree-if '(inactive project habit scheduled deadline)))
                      (org-tags-match-list-sublevels t)
                      (org-agenda-sorting-strategy '(todo-state-down effort-up category-keep))))
          (tags-todo "-CANCELLED/!-NEXT-HOLD-WAITING"
                     ((org-agenda-overriding-header "Available Tasks")
                      (org-agenda-skip-function
                       '(oh/agenda-skip :headline-if '(project)
                                        :subtree-if '(inactive habit scheduled deadline)
                                        :subtree-if-unrestricted-and '(subtask)
                                        :subtree-if-restricted-and '(single-task)))
                      (org-agenda-sorting-strategy '(category-keep))))
          (tags-todo "-CANCELLED/!"
                     ((org-agenda-overriding-header "Currently Active Projects")
                      (org-agenda-skip-function
                       '(oh/agenda-skip :subtree-if '(non-project stuck-project inactive habit)
                                        :headline-if-unrestricted-and '(subproject)
                                        :headline-if-restricted-and '(top-project)))
                      (org-agenda-sorting-strategy '(category-keep))))
          (tags-todo "-CANCELLED/!WAITING|HOLD"
                     ((org-agenda-overriding-header "Waiting and Postponed Tasks")
                      (org-agenda-skip-function
                       '(oh/agenda-skip :subtree-if '(project habit))))))
         nil)
        ("r" "Tasks to Refile" alltodo ""
         ((org-agenda-overriding-header "Tasks to Refile")
          (org-agenda-files '("~/.org/inbox.org"))))
        ("#" "Stuck Projects" tags-todo "-CANCELLED/!-HOLD-WAITING"
         ((org-agenda-overriding-header "Stuck Projects")
          (org-agenda-skip-function
           '(oh/agenda-skip :subtree-if '(inactive non-project non-stuck-project
                                          habit scheduled deadline)))))
        ("n" "Next Tasks" tags-todo "-WAITING-CANCELLED/!NEXT"
         ((org-agenda-overriding-header "Next Tasks")
          (org-agenda-skip-function
           '(oh/agenda-skip :subtree-if '(inactive project habit scheduled deadline)))
          (org-tags-match-list-sublevels t)
          (org-agenda-sorting-strategy '(todo-state-down effort-up category-keep))))
        ("R" "Tasks" tags-todo "-CANCELLED/!-NEXT-HOLD-WAITING"
         ((org-agenda-overriding-header "Available Tasks")
          (org-agenda-skip-function
           '(oh/agenda-skip :headline-if '(project)
                            :subtree-if '(inactive habit scheduled deadline)
                            :subtree-if-unrestricted-and '(subtask)
                            :subtree-if-restricted-and '(single-task)))
          (org-agenda-sorting-strategy '(category-keep))))
        ("p" "Projects" tags-todo "-CANCELLED/!"
         ((org-agenda-overriding-header "Currently Active Projects")
          (org-agenda-skip-function
           '(oh/agenda-skip :subtree-if '(non-project inactive habit)))
              (org-agenda-sorting-strategy '(category-keep))
              (org-tags-match-list-sublevels 'indented)))
        ("w" "Waiting Tasks" tags-todo "-CANCELLED/!WAITING|HOLD"
         ((org-agenda-overriding-header "Waiting and Postponed Tasks")
          (org-agenda-skip-function '(oh/agenda-skip :subtree-if '(project habit)))))))

(provide 'org-mode)
;;; org-mode.el ends here

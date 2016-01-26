(require 'gnus)
(require 'gnus-demon)
(require 'smtpmail)

;;; Personal settings
(setq my-news-server "news.gmane.org"
      my-smtp-server "localhost"

      ;; We use the posting styles to manage different mail accounts
      gnus-posting-styles '(("cryptodrunks"
                             (address "crito@cryptodrunks.net")
                             (name "crito")
                             (gcc "cryptodrunks.Sent"))
                            ("ttc"
                             (address "christo@tacticaltech.org")
                             (name "Christo")
                             (gcc "nnmaildir+ttc:INBOX.Sent")))
      ;; The currently selected posting style
      gnus-posting-style-index 0)

;;; Mail splitting


;;; Account configuration
(setq
 gnus-select-method
 '(nnmaildir "cryptodrunks"
             (directory "~/.mail/cryptodrunks")
             (directory-files nnheader-directory-files-safe)
             (get-new-mail nil))

 gnus-secondary-select-methods
 '((nnmaildir "ttc"
              (directory "~/.mail/tacticaltech")
              (directory-files nnheader-directory-files-safe)
              (get-new-mail nil))
   ;;(nntp 'my-news-server)
   (nntp "news.gmane.org"))
 )

(setq nndraft-directory "~/.mail/gnus")

;;; Archive Sent mail
;;(setq gnus-message-archive-group "cryptodrunks.Sent")

;;; Outbound mail
(setq smtpmail-smtp-server "localhost" ;;my-smtp-server
      send-mail-function 'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it)

;;; GPG integration
(setq mml2015-encrypt-to-self t
      mml2015-signers '("290576A0E6A053E0")
      mm-verify-option 'known
      mm-decrypt-option 'known
      gnus-buttonized-mime-types '("multipart/encrypted" "multipart/signed"))

(setq
 ;; Don't write the ~/.newsrc file to speed up gnus.
 gnus-save-newsrc-file nil
 ;; smtpmail-default-smtp-server "localhost"

 ;; When a new message arrives, show also the old messages of this thread
 gnus-fetch-old-headers t

 ;; Do not use the html part of a message, use the text part if possible!
 ;; mm-discouraged-alternatives '("text/html" "text/richtext")
 )

;; Auto fetch every 2 minutes
;;FIXME: This currently fetches every group, maybe better instead fetch only
;;       nnmaildir of only groups of level 1 and 2 or something like it.
;;FIXME: This is not working!!
;(gnus-demon-add-rescan)
;(gnus-demon-init)

;; If we can ...
(if (fboundp 'w3m)
    (setq mm-text-html-renderer 'w3m)
  nil)

;; Theme the summary threading
(setq-default
 gnus-summary-line-format "%U%R%z %(%&user-date;  %-15,15f  %B%s%)\n"
 gnus-user-date-format-alist '((t . "%d-%m-%Y %H:%M"))
 gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
 gnus-thread-sort-functions '(gnus-thread-sort-by-date)
 gnus-sum-thread-tree-false-root ""
 gnus-sum-thread-tree-indent " "
 gnus-sum-thread-tree-leaf-with-other "├► "
 gnus-sum-thread-tree-root ""
 gnus-sum-thread-tree-single-leaf "╰► "
 gnus-sum-thread-tree-vertical "│")

;;; Mode hooks
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)
(add-hook 'message-setup-hook 'mml-secure-message-sign-pgpmime)

;; Auto complete mail addresses.
;; (add-hook 'message-mode-hook
;;           '(lambda ()
;;              ;; (bbdb-initialize 'message)
;;              ;; (bbdb-initialize 'gnus)
;;              ;; (bbdb-initialize 'pgp)
;;              (local-set-key "<TAB>" 'bbdb-complete-mail)))

;; FIXME: Only use this hook for the gnus stand alone emacs
(add-hook 'gnus-after-exiting-gnus-hook '(lambda () (kill-emacs)))

(defun emd/gnus-group-list-subscribed-groups ()
  "List all subscribed groups with or without un-read messages."
  (interactive)
  (gnus-group-list-all-groups 5))

(defun emd/filter-posting-styles (key styles)
  "Return a new list containing extracted KEY from STYLES."
  (let ((match-style (lambda (style)
                       (if (equal key (car style))
                           t
                         nil))))
    (->> styles
         (-map 'cdr)                 ; Remove the posting style name
         (-reduce-from 'append '())  ; Make one flat list of all styles
         (-filter match-style)       ; Filter by style name
         (-map 'cdr)                 ; Map the values
         (-flatten))))               ; Make sure we have a single list

(defun emd/choose-posting-style ()
  "Cycle to the posting style."
  (interactive)
  (let* ((names (emd/filter-posting-styles 'name gnus-posting-styles))
         (addresses (emd/filter-posting-styles 'address gnus-posting-styles))
         (archives (emd/filter-posting-styles 'gcc gnus-posting-styles))
         (posting-style-index (if (< gnus-posting-style-index (length addresses))
                                  gnus-posting-style-index
                                  0))
         (name (nth posting-style-index names))
         (address (nth posting-style-index addresses))
         (archive (nth posting-style-index archives))
         (message-current-point (point)))

    ;; FIXME: Maybe only do those mutations when in messaging mode??
    ;; Replace the sender
    (goto-char (point-min))
    (while (re-search-forward "^From:.*$" nil t)
      (replace-match (concat "From: " name " <" address ">")))

    ;; Replace the sent archive
    (goto-char (point-min))
    (while (re-search-forward "^Gcc:.*$" nil t)
      (replace-match (concat "Gcc: " archive)))

    (goto-char message-current-point)
    (setq gnus-posting-style-index (+ posting-style-index 1))))

;;; Keybindings
(global-set-key (kbd "C-c f") 'emd/choose-posting-style)

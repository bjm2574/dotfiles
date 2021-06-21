;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Brad Mitchell"
      user-mail-address "bjm@bradjm.io")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Begin my customizations BJM 6/19/2021

;; Mu4e options
(after! mu4e
  (setq mu4e-change-filenames-when-moving t)

  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 2 60))
  (setq mu4e-get-mail-command "mbsync -a")
  (setq mu4e-maildir "~/Mail")
  (setq message-send-mail-function 'smtpmail-send-it)

  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "google"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/gmail" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "bjm@bradjm.io")
                  (user-full-name    . "Brad Mitchell")
                  (smtpmail-smtp-server  . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-smtp-user . "bjm@bradjm.io")
                  (smtpmail-smtp-type    . starttls)
                  (mu4e-drafts-folder  . "/gmail/[Gmail]/Drafts")
                  (mu4e-sent-folder  . "/gmail/[Gmail]/Sent")
                  (mu4e-refile-folder  . "/gmail/[Gmail]/All Mail")
                  (mu4e-trash-folder  . "/gmail/[Gmail]/Trash")))

         ;; Personal account
         (make-mu4e-context
          :name "terillium"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/terillium" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "bmitchell@terillium.com")
                  (user-full-name    . "Brad Mitchell")
                  (smtpmail-smtp-server  . "smtp.office365.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-smtp-user . "bmitchell@terillium.com")
                  ;; (smtpmail-smtp-type    . starttls)
                  (mu4e-drafts-folder  . "/terillium/Drafts")
                  (mu4e-sent-folder  . "/terillium/Sent")
                  (mu4e-refile-folder  . "/terillium/Archive")
                  (mu4e-trash-folder  . "/terillium/Trash")))

         ;; Personal account
         (make-mu4e-context
          :name "apple"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/apple" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "bradmitchell@me.com")
                  (user-full-name    . "Brad Mitchell")
                  (smtpmail-smtp-server  . "smtp.mail.me.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-smtp-user . "bradmitchell@me.com")
                  (smtpmail-smtp-type    . starttls)
                  (mu4e-drafts-folder  . "/apple/Drafts")
                  (mu4e-sent-folder  . "/apple/Sent")
                  (mu4e-refile-folder  . "/apple/Archive")
                  (mu4e-trash-folder  . "/apple/Trash"))))))


;; (setq mu4e-bookmarks
      ;; '("m:/terillium/INBOX or m:/gmail/INBOX or m:/apple/INBOX" . ?i))

  (setq mu4e-maildir-shortcuts
        '(("/gmail/INBOX"      . ?g)
         ("/terillium/INBOX" . ?t)
         ("/apple/INBOX"     . ?a)))

(setq mail-user-agent 'gnus-user-agent)
 (require 'org-msg)
 (setq org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil author:nil email:nil \\n:t"
	org-msg-startup "hidestars indent inlineimages"
	org-msg-greeting-fmt "\nHi %s,\n\n"
	org-msg-recipient-names '(("bjm@bradjm.io" . "Brad"))
	org-msg-greeting-name-limit 3
	org-msg-default-alternatives '((new		. (text html))
				       (reply-to-html	. (text html))
				       (reply-to-text	. (text)))
	org-msg-convert-citation t
	org-msg-signature "

Thanks,

#+begin_signature
 --
Brad Mitchell | Senior Consultant | Terillium
www.terillium.com
Cell: 615.506.7100
bmitchell@terillium.com
#+end_signature")
(org-msg-mode)

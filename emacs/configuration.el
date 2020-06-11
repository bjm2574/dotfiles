;; Don't edit this file, edit /Users/bradmitchell/emacs-config/configuration.org instead ...

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)
  (setq tls-checktrust t)
  (setq gnutls-verify-error t)
(mapc
 (lambda (package)
   (if (not (package-installed-p package))
       (progn
         (package-refresh-contents)
         (package-install package))))
 '(use-package diminish bind-key))
(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)
(setq use-package-always-ensure t)
  (use-package flx)
  (use-package helm-flx)
  (use-package helm
    :demand
    :diminish helm-mode
    :bind (("M-x" . helm-M-x)
           ("M-y" . helm-show-kill-ring)
           ("C-x b" . helm-mini)
           ("C-x C-f" . helm-find-files)
           ("C-x r l" . helm-bookmarks)
           ("C-c s" . helm-occur)
           :map helm-find-files-map ;; I like these from Ido
           ("C-<tab>"         . helm-execute-persistent-action)
           ("C-<backspace>" . helm-find-files-up-one-level))
    :config
    (helm-mode 1)
    (helm-flx-mode +1)
    (setq helm-M-x-fuzzy-match t)
    (setq helm-locate-fuzzy-match t)
    (setq helm-lisp-fuzzy-completion t)
    (setq helm-bookmark-show-location t))
  (defun imenu-anywhere-same-buffer-p (current other)
    (eq current other))

  (use-package imenu-anywhere
    :bind (("C-c C-i" . helm-imenu-anywhere))
    :config (setq imenu-anywhere-buffer-filter-functions
                  '(imenu-anywhere-same-buffer-p)))
  (use-package helm-system-packages)
(use-package magit
  :bind ("C-x g" . magit-status))
  (use-package forge)
  (use-package git-timemachine)
  (setq user-full-name "Brad Mitchell"
        user-mail-address "bjm@bradjm.io"
        calendar-latitude 41.476243
        calendar-longitude -81.711444
        calendar-location-name "Cleveland, OH")
(defun generate-scratch-buffer ()
  "Create and switch to a temporary scratch buffer with a random
     name."
  (interactive)
  (switch-to-buffer (make-temp-name "scratch-")))
(defun sudo ()
  "Use TRAMP to `sudo' the current buffer"
  (interactive)
  (when buffer-file-name
    (find-alternate-file
     (concat "/sudo:root@localhost:"
             buffer-file-name))))
(defun replace-token (token)
  "Replace JSON web token for requests"
  (interactive "sEnter the new token: ")
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "Bearer .*\"" nil t)
      (replace-match (concat "Bearer " token "\"")))))
(eval-after-load "dired"
  '(progn
     (define-key dired-mode-map "F" 'my-dired-find-file)
     (defun my-dired-find-file (&optional arg)
       "Open each of the marked files, or the file under the point, or when prefix arg, the next N files "
       (interactive "P")
       (let* ((fn-list (dired-get-marked-files nil arg)))
         (mapc 'find-file fn-list)))))
(defun browse-current-file ()
  "Open the current file as a URL using `browse-url'."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if (and (fboundp 'tramp-tramp-file-p)
             (tramp-tramp-file-p file-name))
        (error "Cannot open tramp file")
      (browse-url (concat "file://" file-name)))))
(use-package sgml-mode)

(defun reformat-xml ()
  (interactive)
  (save-excursion
    (sgml-pretty-print (point-min) (point-max))
    (indent-region (point-min) (point-max))))
(defun refill-paragraphs ()
  "fill individual paragraphs with large fill column"
  (interactive)
  (let ((fill-column 100000))
    (fill-individual-paragraphs (point-min) (point-max))))
(defun copy-filename ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))
(defun align-docstring ()
  "Align lines by double space"
  (interactive)
  (align-regexp (region-beginning) (region-end) "\\(\\s-*\\)  " 1 1 t))
(defun rename-local-var (name)
  (interactive "sEnter new name: ")
  (let ((var (word-at-point)))
    (mark-defun)
    (replace-string var name nil (region-beginning) (region-end))))
  (defun increment-number-at-point ()
    (interactive)
    (skip-chars-backward "0-9")
    (or (looking-at "[0-9]+")
        (error "No number at point"))
    (replace-match (number-to-string (1+ (string-to-number (match-string 0))))))

  (defun decrement-number-at-point ()
    (interactive)
    (skip-chars-backward "0-9")
    (or (looking-at "[0-9]+")
        (error "No number at point"))
    (replace-match (number-to-string (- (string-to-number (match-string 0)) 1))))
  (defun comment-line ()
    (interactive)
    (save-excursion
      (end-of-line)
      (set-mark (point))
      (beginning-of-line)
      (if (comment-only-p (region-beginning) (region-end))
          (uncomment-region (region-beginning) (region-end))
        (comment-region (region-beginning) (region-end)))))
  (defun edit-config-file ()
    (interactive)
    (find-file (concat config-load-path "configuration.org")))
  (defun email-selection ()
    (interactive)
    (copy-region-as-kill (region-beginning) (region-end))
    (let ((tmp-file (concat "/tmp/" (buffer-name (current-buffer))))
          (recipient (read-string "Enter a recipient: "))
          (subject (read-string "Enter a subject: ")))
      (find-file tmp-file)
      (yank)
      (save-buffer)
      (kill-buffer (current-buffer))
      (shell-command (concat "mutt -s \"" subject "\" " recipient " < " tmp-file))
      (shell-command (concat "rm -f " tmp-file)))
    (message "Sent!"))
  (defun move-file ()
    "Write this file to a new location, and delete the old one."
    (interactive)
    (let ((old-location (buffer-file-name)))
      (call-interactively #'write-file)
      (when old-location
        (delete-file old-location))))
  (defun insert-filename ()
    (interactive)
    (insert (read-file-name "File:")))
  (defun insert-relative-filename ()
    (interactive)
    (insert (file-relative-name (read-file-name "File: "))))
  (defun format-function-parameters ()
    "Turn the list of function parameters into multiline."
    (interactive)
    (beginning-of-line)
    (search-forward "(" (line-end-position))
    (newline-and-indent)
    (while (search-forward "," (line-end-position) t)
      (newline-and-indent))
    (end-of-line)
    (c-hungry-delete-forward)
    (insert " ")
    (search-backward ")")
    (newline-and-indent))
  (defun eshell-here ()
    "Opens up a new shell in the directory associated with the
      current buffer's file. The eshell is renamed to match that
      directory to make multiple eshell windows easier."
    (interactive)
    (let* ((height (/ (window-total-height) 3)))
      (split-window-vertically (- height))
      (other-window 1)
      (eshell "new")
      (insert (concat "ls"))
      (eshell-send-input)))

  (bind-key "C-!" 'eshell-here)
  (defun relative-pwd ()
    (interactive)
    (let* ((prj (cdr (project-current)))
           (current-file buffer-file-truename)
           (prj-name (file-name-as-directory (file-name-nondirectory (directory-file-name prj))))
           (output (concat prj-name (file-relative-name current-file prj))))
      (kill-new output)
      (message output)))
  (add-hook 'git-commit-setup-hook
      '(lambda ()
          (let ((has-ticket-title (string-match "^[A-Z]+-[0-9]+"
                                      (magit-get-current-branch)))
                (words (s-split-words (magit-get-current-branch))))
            (if has-ticket-title
                (insert (format "[%s-%s] " (car words) (car (cdr words))))))))
  (defun what-is-my-ip ()
    (interactive)
    (message "IP: %s"
             (with-current-buffer (url-retrieve-synchronously "https://api.ipify.org")
               (buffer-substring (+ 1 url-http-end-of-headers) (point-max)))))
  (defun what-the-commit ()
    (interactive)
    (insert
     (with-current-buffer
         (url-retrieve-synchronously "http://whatthecommit.com")
       (re-search-backward "<p>\\([^<]+\\)\n<\/p>")
       (match-string 1))))
(define-key global-map (kbd "C-c r") 'revert-buffer)
(define-key global-map (kbd "C-c x") 'eval-buffer)
(define-key global-map (kbd "C-c X") 'eval-region)
(global-set-key (kbd "<home>") 'beginning-of-buffer)
(global-set-key (kbd "<end>") 'end-of-buffer)
(global-set-key (kbd "C-c q") 'auto-fill-mode)
(global-set-key (kbd "C-c d") 'c-hungry-delete-forward)
  (global-set-key (kbd "C-x C-;") 'comment-line)
  (use-package f)
  (use-package org)
  (setq org-directory "~/Documents/org/")
  (setq org-agenda-files (directory-files-recursively "~/Documents/" "\.org$"))
  (defun org-file-path (filename)
    "Return the absolute address of an org file, given its relative name."
    (concat (file-name-as-directory org-directory) filename))

  (defun org-find-file ()
    "Leverage Helm to quickly open any org files."
    (interactive)
    (find-file (org-file-path (helm-comp-read "Select your org file: " (directory-files org-directory nil "\.org$")))))
  (setq org-src-fontify-natively t)
  (require 'color)
  (if (display-graphic-p)
      (set-face-attribute 'org-block nil :background
                          (color-darken-name
                           (face-attribute 'default :background) 3)))

  (global-set-key (kbd "C-c a") 'org-agenda)
(setq org-default-notes-file (concat org-directory "/inbox.org"))
(define-key global-map "\C-cc" 'org-capture)
      (setq org-todo-keywords
            '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))
      (
  setq org-todo-keyword-faces
                 '(("WAIT" . "yellow")
                   ("NEXT" . "red")
                   ("CANCELED" . (:foreground "blue" :weight bold))))
  (add-hook 'org-mode-hook 'flyspell-mode)
  (add-hook 'text-mode-hook 'flyspell-mode)
  (org-babel-do-load-languages
   (quote org-babel-load-languages)
   (quote ((emacs-lisp . t)
           (dot . t)
           (plantuml . t)
           (python . t)
           (gnuplot . t)
           (shell . t)
           (ledger . t)
           (org . t)
           (latex . t)
           (haskell . t))))
  (use-package org-bullets
    :config (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))
  (setq org-startup-with-inline-images t)
  (require 'ox-md)
  (global-set-key (kbd "<f5>") 'org-find-file)
  (global-set-key (kbd "<f6>") 'org-agenda)
  (use-package org-journal
    :custom (org-journal-dir "~/Documents/org/journal" "Set journal location"))
(use-package htmlize)
;; Resume clocking task when emacs is restarted
(org-clock-persistence-insinuate)
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist t)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Do not prompt to resume an active clock, just resume it
(setq org-clock-persist-query-resume nil)
;; Change tasks to whatever when clocking in
(setq org-clock-in-switch-to-state "NEXT")
;; Save clock data and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks
;; with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)
;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)
;; use pretty things for the clocktable
(setq org-pretty-entities t)

  (setq org-catch-invisible-edits 'show-and-error)
(use-package elfeed
  :bind ("C-x w" . elfeed))

(use-package elfeed-org
  :config
  (setq rmh-elfeed-org-files (list (concat config-load-path "elfeed.org")))
  (elfeed-org))
(use-package maxframe)
(toggle-frame-fullscreen)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq initial-major-mode 'emacs-lisp-mode)
(setq initial-scratch-message nil)
(setq visible-bell 1)
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
  (setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
  (setq auto-window-vscroll nil)
(setq confirm-kill-emacs 'y-or-n-p)
(when window-system
  (global-hl-line-mode))
  (global-set-key [mouse-8] 'switch-to-prev-buffer)
  (global-set-key [mouse-9] 'switch-to-next-buffer)
  (use-package dabbrev
    :diminish abbrev-mode)
  (global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups"))))
(fset 'yes-or-no-p 'y-or-n-p)
(setq tags-revert-without-query 1)
  (put 'narrow-to-region 'disabled nil)
  (use-package dracula-theme
  :config (load-theme 'dracula t)
  (set-face-background 'mode-line "#510370")
  (set-face-background 'mode-line-inactive "#212020"))
  (setq-default mode-line-format '("%e"
                                   mode-line-front-space
                                   " "
                                   mode-line-modified
                                   " "
                                   "%[" mode-line-buffer-identification "%]"
                                   "   "
                                   "L%l"
                                   "  "
                                   mode-line-modes
                                   mode-line-misc-info
                                   projectile-mode-line
                                   " "
                                   (:propertize " " display ((space :align-to (- right 14)))) ;; push to the right side
                                   (vc-mode vc-mode)
                                   mode-line-end-spaces))
  (use-package minions
    :config (minions-mode 1))
  (if (condition-case nil
          (x-list-fonts "Hack")
        (error nil))
      (progn
        (add-to-list 'default-frame-alist '(font . "Hack-10"))
        (set-face-attribute 'default nil :font "Hack-10")))
(if (eq system-type 'windows-nt)
    (progn
      (setenv "PATH" (concat "C:\\cygwin64\\bin\\"
                             path-separator
                             (getenv "PATH")))
      )
  (progn
    (use-package exec-path-from-shell
      :config (exec-path-from-shell-copy-env "PATH"))
    )
  )
  (if (eq system-type 'windows-nt)
      (progn
        (add-to-list 'exec-path "C:/Aspell/bin/")
        (setq ispell-program-name "aspell")
        (require 'ispell)))
  (use-package yasnippet
    :diminish yas-minor-mode
    :config (yas-global-mode 1))
  (use-package org-sync-snippets
    :config (setq org-sync-snippets-org-snippets-file
                  (concat (file-name-as-directory config-load-path) "snippets.org")))
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq tab-width 4)
(setq require-final-newline t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
  (setq-default buffer-file-coding-system 'utf-8-unix)
  (setq-default default-buffer-file-coding-system 'utf-8-unix)
  (set-default-coding-systems 'utf-8-unix)
  (prefer-coding-system 'utf-8-unix)
  (defvar yank-indent-modes '(php-mode js2-mode)
    "Modes in which to indent regions that are yanked (or yank-popped)")

  (defvar yank-advised-indent-threshold 1000
    "Threshold (# chars) over which indentation does not automatically occur.")

  (defun yank-advised-indent-function (beg end)
    "Do indentation, as long as the region isn't too large."
    (if (<= (- end beg) yank-advised-indent-threshold)
        (indent-region beg end nil)))

  (defadvice yank (after yank-indent activate)
    "If current mode is one of 'yank-indent-modes, indent yanked text (with prefix arg don't indent)."
    (if (and (not (ad-get-arg 0))
             (--any? (derived-mode-p it) yank-indent-modes))
        (let ((transient-mark-mode nil))
          (yank-advised-indent-function (region-beginning) (region-end)))))

  (defadvice yank-pop (after yank-pop-indent activate)
    "If current mode is one of 'yank-indent-modes, indent yanked text (with prefix arg don't indent)."
    (if (and (not (ad-get-arg 0))
             (member major-mode yank-indent-modes))
        (let ((transient-mark-mode nil))
          (yank-advised-indent-function (region-beginning) (region-end)))))

  (defun yank-unindented ()
    (interactive)
    (yank 1))
  (setq comment-start "#")
     (use-package poporg
       :bind (("C-c \"" . poporg-dwim)))
  (use-package prog-fill
    :bind (("M-q" . prog-fill)))
(show-paren-mode 1)
(electric-pair-mode 1)
  (use-package paradox
    :custom
    (paradox-execute-asynchronously t)
    :config
    (paradox-enable))
  (use-package helpful
    :bind (("C-h f" . helpful-callable)
           ("C-h v" . helpful-variable)
           ("C-h k" . helpful-key)
           ("C-h F" . helpful-function)
           ("C-h C" . helpful-command)))
  (use-package elisp-demos
    :config (advice-add 'helpful-update
                        :after #'elisp-demos-advice-helpful-update))
  (use-package avy
    :bind (("C-c SPC" . avy-goto-char-2)
           ("M-g f" . avy-goto-line)
           ("M-g w" . avy-goto-word-1)))
(use-package win-switch
  :bind ("C-x o" . win-switch-dispatch)
  :config
  (setq win-switch-provide-visual-feedback t)
  (setq win-switch-feedback-background-color "purple")
  (setq win-switch-feedback-foreground-color "white")
  (win-switch-setup-keys-default))
(use-package which-key
  :diminish which-key-mode
  :config (which-key-mode 1))
(winner-mode 1)
(use-package smooth-scrolling
  :config
  (smooth-scrolling-mode 1)
  (setq smooth-scroll-margin 5))
(use-package neotree)
(use-package ibuffer-vc)
(use-package ibuffer-git)
(define-key global-map (kbd "C-x C-b") 'ibuffer)
(use-package yascroll
  :config (global-yascroll-bar-mode 1))
(use-package minimap
  :config
  (setq minimap-window-location "right")
  (setq minimap-major-modes '(prog-mode org-mode)))
  (use-package rotate
    :config (global-set-key (kbd "C-|") 'rotate-layout))
(use-package anzu
  :config (global-anzu-mode +1)
          (setq anzu-mode-lighter ""))
  (use-package hamburger-menu
    :config (setq mode-line-front-space 'hamburger-menu-mode-line))
  (use-package origami
    :config
    (global-set-key (kbd "C-c n o") 'origami-open-node)
    (global-set-key (kbd "C-c n c") 'origami-close-node)
    (global-set-key (kbd "C-c n a") 'origami-open-all-nodes)
    (global-set-key (kbd "C-c n u") 'origami-undo)
    (global-set-key (kbd "C-c n n") 'origami-show-only-node)
    (global-set-key (kbd "C-c n TAB") 'origami-recursively-toggle-node))
  (use-package eyebrowse
    :config (eyebrowse-mode t))
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))
(use-package zzz-to-char
  :bind ("M-z" . zzz-up-to-char))
  (use-package whole-line-or-region
    :diminish whole-line-or-region-global-mode
    :config (whole-line-or-region-global-mode t))
  ;; (use-package viking-mode
  ;;   :diminish viking-mode
  ;;   :config
  ;;   (viking-global-mode)
  ;;   (setq viking-greedy-kill nil)
  ;;   (setq viking-enable-region-kill t)
  ;;   (setq viking-kill-functions (list '(lambda()
  ;;                                        (if (region-active-p)
  ;;                                            (kill-region (region-beginning) (region-end))
  ;;                                        (delete-char 1 t)))
  ;;                                     '(lambda()
  ;;                                        (insert (pop kill-ring)) ;; insert the char back
  ;;                                        (kill-new "") ;; start a new entry in the kill-ring
  ;;                                        (viking-kill-word)
  ;;                                        (kill-append " " nil)) ;; append the extra space
  ;;                                     'viking-kill-line-from-point
  ;;                                     'viking-kill-line
  ;;                                     'viking-kill-paragraph
  ;;                                     'viking-kill-buffer)))
(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode t)
  (setq undo-tree-visualizer-diff t))
(use-package volatile-highlights
  :diminish volatile-highlights-mode
  :config
  (vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
  (vhl/install-extension 'undo-tree)
  (volatile-highlights-mode t))
(use-package ciel
  :bind (("C-c i" . ciel-ci)
         ("C-c o" . ciel-co)))
  (use-package fancy-narrow
    :diminish fancy-narrow-mode)
  (use-package ag)
  (use-package helm-ag)
  (setq projectile-go-function nil) ;; temporary workaround
  (use-package projectile
    :config
    (projectile-mode)
    (setq-default projectile-mode-line
     '(:eval
       (if (file-remote-p default-directory)
           " Proj"
         (format " Proj[%s]" (projectile-project-name)))))
    (add-to-list 'projectile-globally-ignored-directories "node_modules"))
(use-package helm-projectile
  :bind (("C-c v" . helm-projectile)
         ("C-c C-v" . helm-projectile-ag)
         ("C-c w" . helm-projectile-switch-project)))
  (use-package company
    :diminish company-mode
    :config
    (add-hook 'after-init-hook 'global-company-mode)
    (setq company-minimum-prefix-length 2)
    (setq company-dabbrev-downcase nil))
  (use-package company-go)
  (use-package flycheck
    :diminish flycheck-mode
    :config (flycheck-mode 1)
    (setq flycheck-phpcs-standard "PSR2")
    (add-hook 'python-mode-hook 'flycheck-mode)
    (add-hook 'emacs-lisp-mode-hook 'flycheck-mode)
    (add-hook 'json-mode-hook 'flycheck-mode)
    (add-hook 'rjsx-mode-hook 'flycheck-mode))
(use-package helm-flycheck
  :bind ("C-c f" . helm-flycheck))
  (use-package electric-operator
    :config
    (electric-operator-add-rules-for-mode 'php-mode
                                          (cons " - >" "->"))
    (electric-operator-add-rules-for-mode 'php-mode
                                          (cons " / /" "// "))
    (electric-operator-add-rules-for-mode 'php-mode
                                          (cons " = > " " => "))
    (electric-operator-add-rules-for-mode 'php-mode
                                          (cons " < ?" "<?"))
    (electric-operator-add-rules-for-mode 'js2-mode
                                          (cons " = > " " => "))
    (electric-operator-add-rules-for-mode 'js2-jsx-mode
                                          (cons " = > " " => "))
    (electric-operator-add-rules-for-mode 'rjsx-mode
                                          (cons " = > " " => ")))
  (use-package dumb-jump
    :config (setq dumb-jump-aggressive nil))
  (use-package highlight-numbers
    :config (add-hook 'prog-mode-hook 'highlight-numbers-mode))
  (use-package eldoc
    :diminish eldoc-mode
    :config (add-hook 'emacs-lisp-mode-hook 'eldoc-mode))

(use-package rainbow-delimiters
  :config
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode))
(use-package paredit
  :config
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode))
  (use-package eros
    :config (add-hook 'emacs-lisp-mode-hook 'eros-mode))
  (use-package simple-call-tree)
  (use-package suggest)
(require 'sql)
(sql-set-product "mysql")
(use-package sqlup-mode
  :config (add-hook 'sql-mode-hook 'sqlup-mode))
(use-package mysql-to-org
  :config
  (add-hook 'sql-mode-hook 'mysql-to-org-mode))
  (use-package php-mode
    :config
    (add-hook 'php-mode-hook 'flycheck-mode)
    (add-hook 'php-mode-hook 'electric-operator-mode)
    (add-hook 'php-mode-hook 'dumb-jump-mode)
    (add-hook 'php-mode-hook 'php-enable-psr2-coding-style))
  (use-package company-php
    :config
    (add-hook 'php-mode-hook 'company-mode)
    (add-hook 'php-mode-hook '(lambda ()
                                (if (not (member 'php-mode company-dabbrev-code-modes))
                                    (add-to-list 'company-dabbrev-code-modes 'php-mode)))))
  (setq auto-complete-mode nil) ;; Hack while my PR is pending
  (use-package php-eldoc
    :diminish eldoc-mode
    :config (add-hook 'php-mode-hook 'php-eldoc-enable))
  (use-package phpcbf
    :config (setq phpcbf-standard "PSR2"))
(use-package web-mode
  :mode "\\.phtml\\'"
  :mode "\\.volt\\'"
  :mode "\\.html\\'")
  (use-package emmet-mode
    :config
    (add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
    (add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
    )
  (use-package js2-mode
    :mode "\\.js\\'"
    :config
    (add-hook 'js2-mode-hook 'electric-operator-mode)
    (add-hook 'js2-mode-hook 'flycheck-mode)
    (setq js2-basic-offset 2))
  (use-package js2-refactor
    :diminish js2-refactor-mode
    :defer t
    :config
    (add-hook 'js2-mode-hook #'js2-refactor-mode)
    (js2r-add-keybindings-with-prefix "C-c C-m"))
  (use-package js-doc)
  (use-package rjsx-mode)
  (use-package tide)

  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    (company-mode +1))

  ;; formats the buffer before saving
  (add-hook 'before-save-hook 'tide-format-before-save)

  (add-hook 'typescript-mode-hook #'setup-tide-mode)
  (use-package web-mode)
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  ;; enable typescript-tslint checker
  (flycheck-add-mode 'typescript-tslint 'web-mode)
  (use-package sml-mode)
  (use-package go-mode
    :config
    (add-hook 'before-save-hook #'gofmt-before-save)
    (add-hook 'go-mode-hook 'flycheck-mode)
    (add-hook 'go-mode-hook 'dumb-jump-mode)
    (setq go-packages-function 'go-packages-go-list))
  (use-package company-go
    :config
    (add-hook 'go-mode-hook 'company-mode)
    (add-to-list 'company-backends 'company-go))
  (use-package go-stacktracer)
  (use-package go-add-tags)
  (use-package go-eldoc
    :diminish eldoc-mode
    :config (add-hook 'go-mode-hook 'go-eldoc-setup))
  (use-package go-gopath)
  (use-package go-direx)
  (use-package gotest)
  (defun moq ()
    (interactive)
    (let ((interface (word-at-point))
          (test-file (concat (downcase (word-at-point)) "_test.go")))
      (shell-command
       (concat "moq -out " test-file " . " interface))
      (find-file test-file)))
    (defun go-coverage-here ()
      (interactive)
      (shell-command "go test . -coverprofile=cover.out")
      (go-coverage "cover.out")
      (rotate:even-horizontal))
   (use-package elpy)
   (use-package pyenv-mode)
   (elpy-enable)
   ;; (pyenv-mode)
   (setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "--simple-prompt -c exec('__import__(\\'readline\\')') -i")
  (use-package dockerfile-mode
    :mode "Dockerfile\\'")
  ;; (use-package syslog-mode)
  (add-to-list 'auto-mode-alist '("\\.log\\'" . auto-revert-tail-mode))
  (defun open-syslog ()
    (interactive)
    (find-file "/var/log/syslog")
    ;; (syslog-mode)
    (goto-char (point-max)))
  (use-package eshell
    :init
    (setq eshell-scroll-to-bottom-on-input 'all
          eshell-error-if-no-glob t
          eshell-hist-ignoredups t
          eshell-save-history-on-exit t
          eshell-prefer-lisp-functions nil
          eshell-destroy-buffer-when-process-dies t))
  (setq eshell-prompt-function
        (lambda ()
          (concat
           (propertize "┌─[" 'face `(:foreground "green"))
           (propertize (user-login-name) 'face `(:foreground "red"))
           (propertize "@" 'face `(:foreground "green"))
           (propertize (system-name) 'face `(:foreground "lightblue"))
           (propertize "]──[" 'face `(:foreground "green"))
           (propertize (format-time-string "%H:%M" (current-time)) 'face `(:foreground "yellow"))
           (propertize "]──[" 'face `(:foreground "green"))
           (propertize (concat (eshell/pwd)) 'face `(:foreground "white"))
           (propertize "]\n" 'face `(:foreground "green"))
           (propertize "└─>" 'face `(:foreground "green"))
           (propertize (if (= (user-uid) 0) " # " " $ ") 'face `(:foreground "green"))
           )))
  (setq eshell-visual-commands '("htop" "vi" "screen" "top" "less"
                                 "more" "lynx" "ncftp" "pine" "tin" "trn" "elm"
                                 "vim"))

  (setq eshell-visual-subcommands '("git" "log" "diff" "show" "ssh"))
  (setenv "PAGER" "cat")
  (use-package eshell-autojump)
  (defalias 'ff 'find-file)
  (defalias 'd 'dired)
  (defun eshell/clear ()
    (let ((inhibit-read-only t))
      (erase-buffer)))
  (defun eshell/gst (&rest args)
      (magit-status (pop args) nil)
      (eshell/echo))   ;; The echo command suppresses output
  (defun eshell/-buffer-as-args (buffer separator command)
    "Takes the contents of BUFFER, and splits it on SEPARATOR, and
  runs the COMMAND with the contents as arguments. Use an argument
  `%' to substitute the contents at a particular point, otherwise,
  they are appended."
    (let* ((lines (with-current-buffer buffer
                    (split-string
                     (buffer-substring-no-properties (point-min) (point-max))
                     separator)))
           (subcmd (if (-contains? command "%")
                       (-flatten (-replace "%" lines command))
                     (-concat command lines)))
           (cmd-str  (string-join subcmd " ")))
      (message cmd-str)
      (eshell-command-result cmd-str)))

  (defun eshell/bargs (buffer &rest command)
    "Passes the lines from BUFFER as arguments to COMMAND."
    (eshell/-buffer-as-args buffer "\n" command))

  (defun eshell/sargs (buffer &rest command)
    "Passes the words from BUFFER as arguments to COMMAND."
    (eshell/-buffer-as-args buffer nil command))
  (defun eshell/close ()
    (delete-window))
  (add-hook 'eshell-mode-hook
            (lambda ()
              (define-key eshell-mode-map (kbd "C-M-a") 'eshell-previous-prompt)
              (define-key eshell-mode-map (kbd "C-M-e") 'eshell-next-prompt)
              (define-key eshell-mode-map (kbd "M-r") 'helm-eshell-history)))
  (defun eshell-pop--kill-and-delete-window ()
    (unless (one-window-p)
      (delete-window)))

  (add-hook 'eshell-exit-hook 'eshell-pop--kill-and-delete-window)
  (require 'dired-x)
  (setq dired-listing-switches "-alh")
  (use-package yaml-mode
    :config
    (add-hook 'yaml-mode-hook 'flycheck-mode)
    (add-hook 'yaml-mode-hook 'flyspell-mode))
  (use-package flycheck-yamllint)
  (use-package highlight-indentation
    :config
    (set-face-background 'highlight-indentation-face "#8B6090")
    (add-hook 'yaml-mode-hook 'highlight-indentation-mode))
  (use-package restclient
    :mode ("\\.restclient\\'" . restclient-mode))
  (use-package company-restclient
    :config (add-to-list 'company-backends 'company-restclient))
  (use-package ob-restclient)
  (use-package plantuml-mode)
  (let ((plantuml-directory (concat config-load-path "extra/"))
        (plantuml-link "https://superb-dca2.dl.sourceforge.net/project/plantuml/plantuml.jar"))
    (let ((plantuml-target (concat plantuml-directory "plantuml.jar")))
      (if (not (f-exists? plantuml-target))
          (progn (message "Downloading plantuml.jar")
                 (shell-command
                  (mapconcat 'identity (list "wget" plantuml-link "-O" plantuml-target) " "))
                 (kill-buffer "*Shell Command Output*")))
      (setq org-plantuml-jar-path plantuml-target)))
(use-package ledger-mode)
(setq ledger-schedule-file "~/Documents/Financial/ledger-schedule.ledger")
(setq ledger-schedule-look-forward 30)
(use-package flycheck-ledger)
(use-package dklrt)
(use-package hledger-mode)


  (use-package 2048-game)
  (use-package isend-mode)
  (use-package lorem-ipsum)
  (use-package markdown-mode)
  (use-package pdf-tools
    :defer t)
  (use-package refine)
  (use-package request)
  (use-package csv-mode)
  ;; (use-package csharp-mode)
  (use-package keychain-environment)
  (use-package prodigy)
  (use-package vlf)
  (use-package helm-flyspell)
  (use-package kubel)
  (use-package kubernetes-helm)
  (use-package mermaid-mode)

  (use-package load-dir
    :config (setq load-dirs (concat config-load-path "extra/")))

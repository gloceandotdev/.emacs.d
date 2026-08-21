;; -*- lexical-binding: t; -*-

;; --- init.el ---
;; The main configuration, this is where all the settings, keybindings, and packages are configured.

;; -----------------------------------------------------------------------------
;; PACKAGE MANAGER SETUP
;; -----------------------------------------------------------------------------

;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Make straight.el work with use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq straight-check-for-modifications '(not-at-startup))

;; -----------------------------------------------------------------------------
;; DIRECTORY CLEANUP WITH NO-LITTERING
;; -----------------------------------------------------------------------------

;; Use no-littering to keep Emacs configuration directories clean
(use-package no-littering
  :demand t
  :config
  ;; Redirect backup files
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;; Keep recentf clean
(use-package recentf
  :config
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-etc-directory))
  (add-to-list 'recentf-exclude "/opt/homebrew/")
  (add-to-list 'recentf-exclude "/usr/local/Cellar/")
  (recentf-mode 1))

;; -----------------------------------------------------------------------------
;; GENERAL SETTINGS
;; -----------------------------------------------------------------------------

;; Set default font
(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-14"))

;; Basic UI and editing preferences
(setq-default cursor-type '(box . 2) ; Set cursor to a blinking box
              fill-column 80 ; Set a line-wrap guide at 80 chars
              tab-width 4 ; Set tab width to 4 spaces
              indent-tabs-mode nil) ; Use spaces, not tabs

(setq blink-cursor-blinks 0) ; Make the blinks not stop
(blink-cursor-mode 1)
(setq display-line-numbers-type 'relative) ; Make them relative
(global-display-line-numbers-mode t) ; And enable line numbers globally
(global-hl-line-mode t) ; Highlight the current line
(column-number-mode t) ; Show column number in modeline

;; System and performance settings
(setq native-comp-async-report-warnings-errors 'silent) ; Silence native compilation warnings
(setq make-backup-files nil ; Disable backup files
      auto-save-default nil) ; Disable auto-save files

;; Auto-revert buffers when files change on disk (useful for Syncthing)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)
(global-visual-line-mode 1)

;; macOS specific fixes
(setq locate-command "mdfind") ; Use spotlight's search backend
(setq ns-use-native-fullscreen nil) ; Disable native fullscreen to avoid issues
(setq ns-pop-up-frames nil) ; Make files opened outside of emacs open in an existing window
(setq delete-by-moving-to-trash (not noninteractive)) ; Delete files to the macOS trashcan

;; Shell fixes
(setq shell-file-name (executable-find "bash")) ; Make emacs use bash internally
(setq-default vterm-shell "/opt/homebrew/bin/fish") ; Use fish for vterm
(setq-default explicit-shell-file-name "/opt/homebrew/bin/fish") ; And for explicit shells

;; -----------------------------------------------------------------------------
;; CORE PACKAGES AND EVIL MODE
;; -----------------------------------------------------------------------------

;; Fix emacs launched from the .app file not seeing your environment variables
(use-package exec-path-from-shell
  :custom
  (exec-path-from-shell-shell-name "/opt/homebrew/bin/fish")
  (exec-path-from-shell-arguments '("-l"))
  :config
  (when (string-equal system-type "darwin")
    (exec-path-from-shell-initialize)))

;; Package for easier keybindings
(use-package general
  :config
  (general-evil-setup t))

;; Better undo/redo
(use-package undo-fu
  :after evil)

;; Save undo history between sessions.
(use-package undo-fu-session
  :init
  (undo-fu-session-global-mode))

;; Join the dark side
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-integration t)
  (setq evil-respect-visual-line-mode t)
  :config
  (evil-mode 1)
  (define-key evil-normal-state-map (kbd "SPC") nil)
  (define-key evil-visual-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "SPC") nil))

;; Join the dark side, but EVERYWHERE
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Visualize yank/change/delete etc.
(use-package evil-goggles
  :after evil
  :config
  (evil-goggles-mode 1))

;; Easily delete surrounding quotes, parentheses, etc.
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;; Work with comments in evil mode
(use-package evil-nerd-commenter
  :after evil)

;; -----------------------------------------------------------------------------
;; UI ENHANCEMENTS AND APPEARANCE
;; -----------------------------------------------------------------------------

;; Load the custom Rose Pine Modus theme
(load-file (expand-file-name "rose-pine-modus.el" user-emacs-directory))

;; Nerd icons
(use-package nerd-icons)

;; Startup dashboard
(use-package dashboard
  :after (nerd-icons projectile)
  :init
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  :config
  (defun dashboard-resize-on-hook (&optional _)
    (let ((space-win (get-buffer-window dashboard-buffer-name))
          (frame-win (frame-selected-window)))
      (when (and space-win
                 (not (window-minibuffer-p frame-win)))
        (with-selected-window space-win
          (dashboard-insert-startupify-lists t)))))
  (dashboard-setup-startup-hook)
  (add-hook 'dashboard-mode-hook (lambda () 
                                   (setq-local global-hl-line-mode nil)
                                   (hl-line-mode -1)))
  (setq dashboard-startup-banner (expand-file-name "assets/xemacs_color_pine.svg" user-emacs-directory)
        dashboard-banner-logo-title "Welcome to Emacs!"
        dashboard-items '((recents   . 5)
                          (projects  . 5)
                          (bookmarks . 5)))
  :custom
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-projects-backend 'projectile))

;; Indent guides
(use-package highlight-indent-guides
  :hook ((prog-mode . highlight-indent-guides-mode)
         (prog-mode . (lambda () (setq-local line-spacing 0.18)))) ; increase line height
  :config
  (setq highlight-indent-guides-method 'character)
  (setq highlight-indent-guides-character ?│)
  (setq highlight-indent-guides-responsive 'top)
  (setq highlight-indent-guides-delay 0)
  (setq highlight-indent-guides-auto-enabled nil)
  ;; Set colors at load time by reading the active theme (theme function handles switches)
  (let ((dark (eq (car custom-enabled-themes) 'modus-vivendi)))
    (set-face-attribute 'highlight-indent-guides-character-face nil
                        :foreground (if dark "#403d52" "#cecacd"))
    (set-face-attribute 'highlight-indent-guides-top-character-face nil
                        :foreground (if dark "#908caa" "#797593"))))

;; Smooth scroll
(use-package ultra-scroll
  :init
  (setq scroll-conservatively 3
        scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

;; Modern modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t) 
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-minor-modes nil)
  (doom-modeline-enable-word-count t)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-project-name t))

;; -----------------------------------------------------------------------------
;; COMPLETION AND SEARCHING
;; -----------------------------------------------------------------------------

;; Which-key for displaying available keybindings
(use-package which-key
  :straight (:type built-in)
  :init
  (setq which-key-idle-delay 0.0)
  (which-key-mode))

;; Projectile for project management
(use-package projectile
  :init
  (projectile-mode +1)
  :config
  (setq projectile-project-search-path '("~/Projects/"))
  (setq projectile-switch-project-action #'projectile-dired)
  (add-to-list 'projectile-ignored-projects "/opt/homebrew/")
  (add-to-list 'projectile-ignored-projects (expand-file-name user-emacs-directory)))

;; Completion with vertico
(use-package vertico
  :init
  (vertico-mode 1)
  :config
  (setq vertico-resize t
        vertico-cycle t
        vertico-count 15))

;; Save minibuffer history
(use-package savehist
  :init
  (savehist-mode))

;; Orderless completion and sorting
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;; Rich annotations in the minibuffer
(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

;; In-buffer completion with corfu
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-quit-no-match 'separator)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 1)
  (corfu-popupinfo-mode t)
  (corfu-popupinfo-delay 0)
  :bind
  (:map corfu-map
        ("TAB" . nil)
        ("[tab]" . nil)
        ("S-RET" . (lambda () (interactive) (corfu-quit) (newline-and-indent)))
        ("S-<return>" . (lambda () (interactive) (corfu-quit) (newline-and-indent)))))

;; Nerd icons for corfu
(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)
  (add-to-list 'nerd-icons-corfu-mapping
               '(snippet :style "cod" :icon "insert" :face font-lock-constant-face)))

;; Completion extensions with cape
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;; Consult for enhanced searching
(use-package consult)

;; Custom function to toggle bookmarks for a file
(defun gl/toggle-file-bookmark ()
  "Toggle a bookmark for the current file."
  (interactive)
  (require 'bookmark)
  (bookmark-maybe-load-default-file)
  (let ((curr-file (buffer-file-name)))
    (if (not curr-file)
        (message "Not visiting a file.")
      (let ((name (file-name-nondirectory curr-file)))
        (if (bookmark-get-bookmark name t)
            (progn
              (bookmark-delete name)
              (message "Deleted bookmark: %s" name))
          (save-excursion
            (goto-char (point-min))
            (bookmark-set name)
            (bookmark-set-filename name (expand-file-name curr-file))
            (message "Set bookmark: %s" name)))))))

;; -----------------------------------------------------------------------------
;; DEVELOPMENT TOOLS AND UTILITIES
;; -----------------------------------------------------------------------------

;; Modern terminal emulator
(use-package vterm
  :custom
  (vterm-max-scrollback 10000)
  (vterm-timer-delay 0.1)
  :config
  (add-hook 'vterm-mode-hook (lambda ()
                               (display-line-numbers-mode -1)
                               (evil-local-mode -1)))
  (evil-initial-state 'vterm-mode 'emacs)
  (with-eval-after-load 'vterm
    (define-key vterm-mode-map (kbd "<escape>") 'vterm-send-escape)))

;; Vterm-toggle for easy terminal toggling
(use-package vterm-toggle
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _) 
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3))))

;; Quickrun with modifications to run in vterm
(use-package quickrun
  :commands (quickrun)
  :init
  (defun gl/quickrun-in-vterm (&optional _prefix)
    (interactive "P")
    (save-buffer)
    (require 'quickrun)
    (quickrun--set-executed-file)
    (quickrun--remove-temp-files)
    (let* ((orig    quickrun--executed-file)
           (beg     (if (use-region-p) (region-beginning) (point-min)))
           (end     (if (use-region-p) (region-end)        (point-max)))
           (cmdkey  (quickrun--command-key orig))
           (src     (if (and (use-region-p) (quickrun--use-tempfile-p cmdkey))
                        (let ((dst (quickrun--temp-name (or orig ""))))
                          (quickrun--copy-region-to-tempfile beg end dst)
                          dst)
                      orig))
           (info    (quickrun--fill-templates cmdkey src))
           (exec    (gethash :exec info))
           (default-directory (or quickrun-option-default-directory
                                  default-directory))
           (buf     (if (get-buffer "*quickrun-vterm*")
                        (pop-to-buffer "*quickrun-vterm*")
                      (vterm "*quickrun-vterm*"))))
      (with-current-buffer buf
        (dolist (cmd (if (listp exec) exec (list exec))) 
          (vterm-send-string cmd)
          (vterm-send-return)))))

  (add-to-list 'display-buffer-alist
               '("\\*quickrun-vterm\\*"
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3))))

;; Show git diffs in the gutter
(use-package diff-hl
  :init
  (global-diff-hl-mode)
  :config
  (diff-hl-flydiff-mode)
  (diff-hl-margin-mode)
  :hook
  (dired-mode . diff-hl-dired-mode)
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh))

;; Git interface (evil-collection provides the vim-style bindings)
(use-package magit
  :defer t
  :custom
  ;; Open magit in the current window instead of splitting,
  ;; except for diffs which still pop up beside
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Highlight TODO/FIXME comments
(use-package hl-todo
  :init
  (global-hl-todo-mode 1)
  :config
  (setq hl-todo-highlight-punctuation ":"))

;; Treemacs file explorer
(use-package treemacs
  :defer t
  :hook (treemacs-mode . (lambda () (display-line-numbers-mode -1)))
  :config
  (setq treemacs-position 'right)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-project-follow-mode t)
  (treemacs-hide-gitignored-files-mode -1))

;; Evil integration for treemacs
(use-package treemacs-evil
  :after (evil treemacs))

;; Projectile integration for treemacs
(use-package treemacs-projectile
  :after (treemacs projectile))

;; Nerd icons for treemacs
(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :config
  (treemacs-load-theme "nerd-icons"))

;; Auto-format code on save
(use-package apheleia
  :init
  (apheleia-global-mode +1))

;; Automatically close matching parentheses, brackets, quotes, etc.
(use-package smartparens
  :init
  (smartparens-global-mode 1)
  :config
  (require 'smartparens-config)
  (show-paren-mode 1)
  (sp-local-pair 'org-mode "$" "$"))

;; IRC Client
(use-package erc
  :custom
  (erc-server "irc.libera.chat")
  (erc-nick "Glocean")
  (erc-user-full-name "Glass Ocean")
  (erc-track-shorten-start 8)
  (erc-track-exclude-types '("JOIN" "PART" "QUIT" "NICK" "MODE"
                             "324" "329" "332" "333" "353" "477"))
  (erc-track-exclude-server-buffer t)
  (erc-track-showcount t)
  (erc-kill-buffer-on-part t)
  (erc-kill-server-buffer-on-quit t)
  (erc-auto-query 'bury)
  (erc-fill-column 100)
  (erc-fill-function 'erc-fill-static)
  (erc-fill-static-center 20)
  (erc-header-line-format "%n on %t (%m)")
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  :config
  (add-to-list 'erc-modules 'spelling)
  (add-to-list 'erc-modules 'scrolltobottom)
  (erc-update-modules)

  (defun gl/erc-macos-notify (nick msg)
    "Show a macOS notification for MSG from NICK."
    (call-process "osascript" nil 0 nil "-e"
                  (format "display notification %S with title %S"
                          (substring-no-properties (erc-controls-strip msg))
                          (concat "ERC: " (substring-no-properties nick)))))

  (defun gl/erc-looking-at-buffer-p (buffer)
    "Non-nil if BUFFER is visible and Emacs is focused."
    (and buffer
         (get-buffer-window buffer 'visible)
         (eq (frame-focus-state) t)))

  (defun gl/erc-notify-dm (proc parsed)
    "Notify on private messages."
    (let ((nick (car (erc-parse-user (erc-response.sender parsed))))
          (target (car (erc-response.command-args parsed)))
          (msg (erc-response.contents parsed)))
      (when (and (erc-current-nick-p target)
                 (not (erc-is-message-ctcp-and-not-action-p msg))
                 (not (gl/erc-looking-at-buffer-p (erc-get-buffer nick proc))))
        (gl/erc-macos-notify nick msg)))
    nil)

  (defun gl/erc-notify-mention (match-type nickuserhost msg)
    "Notify when someone says your nick in a channel."
    (when (and (eq match-type 'current-nick)
               (not (erc-server-or-unjoined-channel-buffer-p))
               (not (gl/erc-looking-at-buffer-p (current-buffer))))
      (gl/erc-macos-notify (car (erc-parse-user nickuserhost)) msg)))

  (add-hook 'erc-server-PRIVMSG-functions #'gl/erc-notify-dm)
  (add-hook 'erc-text-matched-hook #'gl/erc-notify-mention)

  (evil-set-initial-state 'erc-mode 'emacs)

  (add-hook 'erc-mode-hook (lambda ()
                             (display-line-numbers-mode -1)
                             (setq-local global-hl-line-mode nil)
                             (hl-line-mode -1)
                             (visual-fill-column-mode))))

(use-package erc-hl-nicks
  :after erc
  :config
  (erc-hl-nicks-mode 1))

;; -----------------------------------------------------------------------------
;; LANGUAGES AND CODING
;; -----------------------------------------------------------------------------

;; Tree-sitter for better syntax highlighting
(use-package tree-sitter
  :config
  (defun gl/enable-tree-sitter-maybe ()
    (unless (derived-mode-p 'emacs-lisp-mode)
      (tree-sitter-mode)))
  :hook
  (prog-mode . gl/enable-tree-sitter-maybe)
  (tree-sitter-after-on-hook . tree-sitter-hl-mode))

;; Language definitions for tree-sitter
(use-package tree-sitter-langs
  :after tree-sitter)

;; Programming language snippets with yasnippet
(use-package yasnippet
  :config
  (setq yas-snippet-dirs (list (no-littering-expand-etc-file-name "yasnippet/snippets")))
  :init
  (yas-global-mode 1))

;; Pre-made yasnippet collections
(use-package yasnippet-snippets
  :after yasnippet)

;; Spellcheck with jinx
(use-package jinx
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
  :config
  (add-to-list 'jinx-include-faces '(prog-mode font-lock-comment-face font-lock-string-face))
  (add-to-list 'jinx-exclude-faces '(prog-mode font-lock-constant-face font-lock-keyword-face font-lock-function-name-face font-lock-variable-name-face)))

;; Linting with flycheck
(use-package flycheck
  :init
  (global-flycheck-mode)
  :config
  (setq flycheck-global-modes '(not emacs-lisp-mode)))

;; AI assistant with gptel
(use-package gptel
  :config
  (setq-default gptel-model 'gpt-5-mini)
  (setq-default gptel-backend
                (gptel-make-gh-copilot "Copilot")))

;; GitHub Copilot 
(use-package copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . copilot-accept-completion)
              ("TAB" . copilot-accept-completion)
              ("C-TAB" . copilot-accept-completion-by-word)
              ("C-<tab>" . copilot-accept-completion-by-word))
  :config
  (setq copilot-indent-offset-alist '((prog-mode . 4) (emacs-lisp-mode . 2)))
  (setq copilot-indent-offset-warning-disable t))

;; Language server support (starts automatically when a server is installed
;; for the buffer's language, stays quiet otherwise)
(use-package lsp-mode
  :hook (
         (prog-mode . lsp-deferred)
         (lsp-mode  . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-completion-provider :none)
  (setq lsp-warn-no-matched-clients nil)
  :config
  (setq lsp-idle-delay 0.5)
  (setq lsp-log-io nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-modeline-code-action-fallback-icon (nerd-icons-codicon "nf-cod-lightbulb")))

;; Lsp-ui
(use-package lsp-ui
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 0.5)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-sideline-show-code-actions t))

;; -----------------------------------------------------------------------------
;; ORG-MODE
;; -----------------------------------------------------------------------------

;; Main org configuration
(use-package org
  :hook ((org-mode . org-indent-mode)
         (org-mode . (lambda () (electric-indent-local-mode -1))))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)))

  (setq org-adapt-indentation nil)
  (setq org-directory "~/org")
  (setq org-default-notes-file (expand-file-name "scratchpad.org" org-directory))
  (setq org-capture-bookmark nil)
  (setq org-preview-latex-image-directory
        (expand-file-name "ltximg/" user-emacs-directory))

  (defvar gl/university-current-dir "~/University/Current"
    "Directory holding the current semester's course folders.")

  (defun gl/refresh-org-agenda-files ()
    "Rebuild `org-agenda-files' from the current semester's course files."
    (interactive)
    (let ((uni (expand-file-name gl/university-current-dir)))
      (setq org-agenda-files
            (and (file-directory-p uni)
                 (directory-files-recursively uni "\\.org\\'")))))

  (gl/refresh-org-agenda-files)

  ;; Modern appearance settings
  (setq org-ellipsis ""
        org-cycle-hide-drawer-startup nil
        org-hide-emphasis-markers t
        org-pretty-entities nil
        org-use-sub-superscripts nil
        org-startup-with-latex-preview nil
        org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-insert-heading-respect-content t
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 0
        org-src-preserve-indentation t)

  (setq org-preview-latex-default-process 'dvisvgm)

  ;; Manual Latex preview for daemon compatibility
  (defun gl/org-enable-latex-preview ()
    "Enable latex preview if in a graphical environment."
    (when (display-graphic-p)
      (org-latex-preview '(16))))

  (add-hook 'org-mode-hook #'gl/org-enable-latex-preview)

  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (dolist (buf (buffer-list))
                (with-current-buffer buf
                  (when (eq major-mode 'org-mode)
                    (org-latex-preview '(16)))))))

  ;; TODOs and Logging
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROJ(p)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  ;; Agenda styling
  (setq org-agenda-start-with-log-mode t)
  (setq org-agenda-tags-column 0)
  (setq org-agenda-block-separator ?─)
  (setq org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"))
  (setq org-agenda-current-time-string
        "◄ NOW ─────────────────────────────────────────────────")

  ;; Force Org Agenda to the right
  (setq org-agenda-window-setup 'current-window)
  (add-to-list 'display-buffer-alist
               '("\\*Org Agenda\\*"
                 (display-buffer-in-side-window)
                 (side . right)
                 (slot . 0)
                 (window-width . 0.4)
                 (preserve-size . (t . nil))
                 (window-parameters . ((no-delete-other-windows . t)))))

  (defvar gl/blog-posts-dir "~/Projects/glocean.dev/posts/"
    "Directory holding glocean.dev blog post sources.")

  (defvar gl/blog--title nil
    "Title of the glocean.dev blog post currently being captured.")

  (defun gl/blog-slugify (title)
    "Turn TITLE into a filename-safe slug."
    (string-trim (replace-regexp-in-string "[^a-z0-9]+" "-" (downcase title)) "-+" "-+"))

  (defun gl/blog-capture-target ()
    "Prompt for a post title and visit a fresh posts/<slug>.org buffer."
    (setq gl/blog--title (read-string "Post title: "))
    (set-buffer (org-capture-target-buffer
                 (expand-file-name (concat (gl/blog-slugify gl/blog--title) ".org")
                                   (expand-file-name gl/blog-posts-dir))))
    (goto-char (point-max)))

  (defvar gl/lecture-heading-regexp "^\\*+ +\\(?:Lecture\\|Week\\)\\b"
    "Regex matching a lecture heading inside a course file.")

  (defun gl/course-code ()
    "Course code for the capture in progress, from its directory name."
    (let ((file (or (org-capture-get :original-file) (buffer-file-name))))
      (if file
          (file-name-nondirectory
           (directory-file-name (file-name-directory file)))
        "")))

  (defconst gl/file-icon "" "File icon for course file links.")
  (defconst gl/folder-icon "" "Folder icon for slide links.")

  (defun gl/course-file ()
    "The University course file the capture was invoked from."
    (let ((file (buffer-file-name (org-capture-get :original-buffer))))
      (if (and file (string-match-p "/University/" file))
          file
        (user-error "Not in a University course file"))))

  (defun gl/course-attachment-link (subdir label icon)
    "Org link to a file picked from SUBDIR of the current course.
Completes over the directory but accepts names not there yet."
    (let* ((file (or (org-capture-get :original-file) (buffer-file-name)))
           (dir (and file (expand-file-name subdir (file-name-directory file))))
           (choices (and dir (file-directory-p dir)
                         (directory-files dir nil "\\`[^.].*\\.[[:alnum:]]+\\'")))
           (pick (string-trim
                  (if choices
                      (completing-read (format "%s file: " subdir) choices nil nil)
                    (read-string (format "%s file name: " subdir))))))
      (if (string-empty-p pick)
          ""
        (format "[[file:%s/%s][%s %s]]" subdir pick icon label))))

  (defun gl/next-lecture-number ()
    "Prompt for a lecture number, pre-filled with the next unused one."
    (let ((buf (org-capture-get :original-buffer))
          (n 0))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (save-excursion
            (save-restriction
              (widen)
              (goto-char (point-min))
              (while (re-search-forward "^\\*+ +Lecture +\\([0-9]+\\)" nil t)
                (setq n (max n (string-to-number (match-string 1)))))))))
      (read-string "Lecture number: " (number-to-string (1+ n)))))

  (defun gl/org-goto-current-lecture ()
    "Put point on the lecture heading a captured assignment belongs under."
    (unless (derived-mode-p 'org-mode)
      (user-error "Not in an Org buffer"))
    (org-capture-put-target-region-and-position)
    (widen)
    (end-of-line)
    (unless (or (re-search-backward gl/lecture-heading-regexp nil t)
                (progn (goto-char (point-max))
                       (re-search-backward gl/lecture-heading-regexp nil t)))
      (user-error "No lecture heading in %s" (buffer-name)))
    (beginning-of-line))

  (setq org-capture-templates
        '(("u" "University")

          ("ul" "Lecture" entry
           (file+headline gl/course-file "Lectures")
           "* Lecture %(gl/next-lecture-number) - %^{Topic}\n\n%(gl/course-attachment-link \"Slides\" \"Lecture Slides\" gl/folder-icon)\n\n%?"
           :empty-lines 1)

          ("uh" "Homework" entry
           (function gl/org-goto-current-lecture)
           "* TODO %(gl/course-code) - %^{Assignment}\nDEADLINE: %^t\n:PROPERTIES:\n:TYPE: %^{Type|Homework|Quiz|Exam|Project|Group|Lab|Essay|Presentation}\n:END:\n\n%(gl/course-attachment-link \"Homeworks\" \"Open Homework\" gl/file-icon)\n%?"
           :prepend t :empty-lines 1)

          ("ur" "Reading" entry
           (file+headline gl/course-file "Readings")
           "* %^{Reading}\n\n%(gl/course-attachment-link \"Readings\" \"Open Reading\" gl/file-icon)\n\n%?"
           :empty-lines 1)

          ("b" "Blog post (glocean.dev)" plain
           (function gl/blog-capture-target)
           "#+title: %(progn gl/blog--title)\n#+date: <%<%Y-%m-%d>>\n#+filetags: %^{Tags}\n#+excerpt: %^{Excerpt}\n\n%?"
           :unnarrowed t :empty-lines 0))))

;; Automatically continue lists with when pressing RET
(use-package org-autolist
  :after org
  :hook (org-mode . org-autolist-mode))

;; Automatically toggle org-mode latex previews
(use-package org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode))

;; Toggle emphasis markers when the cursor is over them
(use-package org-appear
  :after org
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks t))

;; Modern look for org-mode
(use-package org-modern
  :after org
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-star '("◉" "○" "◈" "◇" "✳"))
  (setq org-modern-table-vertical 1)
  (setq org-modern-table-horizontal 0.2)
  (setq org-modern-block-fringe nil)
  (setq org-modern-todo-faces
        '(("WAIT" :background "#6e6a86" :foreground "#e0def4")
          ("PROJ" :background "#c4a7e7" :foreground "#191724"))))

;; Center the content for a better reading experience
(use-package visual-fill-column
  :hook ((org-mode . visual-fill-column-mode))
  :config
  (setq-default visual-fill-column-width 100
                visual-fill-column-center-text t))

;; Powerful LaTeX editing environment
(use-package auctex
  :defer t
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-master nil))

;; Fast LaTeX math entry
(use-package cdlatex
  :hook ((org-mode . turn-on-org-cdlatex)
         (LaTeX-mode . turn-on-cdlatex))
  :config
  (add-to-list 'cdlatex-command-alist
               '("lim" "Limit n to infinity"
                 "\\lim\\limits_{n \\to \\infty} ?"
                 cdlatex-position-cursor nil nil t))
  (add-to-list 'cdlatex-command-alist
               '("neglim" "Limit n to minus infinity"
                 "\\lim\\limits_{n \\to -\\infty} ?"
                 cdlatex-position-cursor nil nil t))
  (add-to-list 'cdlatex-command-alist
               '("funclim" "Function limit"
                 "\\lim\\limits_{x \\to ?}"
                 cdlatex-position-cursor nil nil t)))

;; Enable visual line mode and disable line numbers for org mode
(add-hook 'org-mode-hook (lambda ()
                           (display-line-numbers-mode -1)
                           (setq-local global-hl-line-mode nil)
                           (hl-line-mode -1)
                           (setq-local line-spacing 0.18))) ; increase line height

;; -----------------------------------------------------------------------------
;; KEYBINDINGS
;; -----------------------------------------------------------------------------

;; macOS specific bindings
(when (string-equal system-type "darwin")

  (general-define-key
   :keymaps 'global
   "s-`" #'other-frame
   "s-w" #'delete-window
   "s-W" #'delete-frame
   "s-n" #'make-frame
   "s-l" #'goto-line
   "s-q" (if (daemonp) #'delete-frame #'save-buffers-kill-terminal)
   "s-s" #'save-buffer
   "s-a" #'mark-whole-buffer
   "s-z" #'undo))

;; Evil normal mode binds
(general-define-key
 :states 'normal
 "gcc" #'evilnc-comment-or-uncomment-lines
 "gc"  #'evilnc-comment-operator
 "K"   #'jinx-correct)

;; Evil visual mode binds
(general-define-key
 :states 'visual
 "gc" #'evilnc-comment-or-uncomment-lines)

;; Leader key definition
;; SPC in normal/visual/motion; M-SPC (i.e. ESC then SPC) in insert/emacs
;; state buffers like ERC and vterm
(general-create-definer gl-leader-def
  :prefix "SPC"
  :non-normal-prefix "M-SPC"
  :states '(normal visual motion insert emacs)
  :keymaps 'override)

;; Leader keybindings
(gl-leader-def
  "SPC" '(consult-buffer :which-key "Switch Buffer")
  "."   '(find-file :which-key "Find File")
  "r"   '(gl/quickrun-in-vterm :which-key "Run Code")
  "e"   '(treemacs :which-key "File Explorer")
  "k"   '(jinx-correct :which-key "Correct Word")

  ;; IRC (ERC)
  "i"   '(:ignore t :which-key "IRC")
  "ii"  '((lambda () (interactive) (erc-tls :server "irc.libera.chat" :port 6697 :nick "Glocean")) :which-key "Connect (Libera)")
  "ia"  '(erc-track-switch-buffer :which-key "Goto Activity")
  "ib"  '(erc-switch-to-buffer :which-key "Switch IRC Buffer")

  ;; Buffer Management
  "b"   '(:ignore t :which-key "Buffer")
  "bb"  '(consult-buffer :which-key "Switch Buffer")
  "bm"  '(consult-bookmark :which-key "Jump to Bookmark")
  "bd"  '(bookmark-delete :which-key "Delete Bookmark")
  "bk"  '(kill-current-buffer :which-key "Kill Buffer")
  "bn"  '(next-buffer :which-key "Next Buffer")
  "bp"  '(previous-buffer :which-key "Prev Buffer")
  "be"  '(eval-buffer :which-key "Eval Buffer")
  "bK"  '(kill-buffer-and-window :which-key "Kill Buffer & Window")

  ;; Window Management
  "w"   '(:ignore t :which-key "Window")
  "wh"  '(evil-window-left :which-key "Left")
  "wj"  '(evil-window-down :which-key "Down")
  "wk"  '(evil-window-up :which-key "Up")
  "wl"  '(evil-window-right :which-key "Right")
  "wv"  '(evil-window-vsplit :which-key "Split Vertical")
  "ws"  '(evil-window-split :which-key "Split Horizontal")
  "ww"  '(other-window :which-key "Cycle Window")
  "wc"  '(evil-window-delete :which-key "Close Window")
  "wo"  '(delete-other-windows :which-key "Close Others")
  "we"  '(balance-windows :which-key "Equalize Windows")

  ;; File Management
  "f"   '(:ignore t :which-key "Files")
  "ff"  '(find-file :which-key "Find File")
  "fr"  '(consult-recent-file :which-key "Recent Files")
  "fs"  '(save-buffer :which-key "Save File")
  "fd"  '(delete-file :which-key "Delete File")
  "fp"  '((lambda () (interactive) (find-file (expand-file-name "init.el" user-emacs-directory))) :which-key "Open Config")

  ;; Toggle
  "t"   '(:ignore t :which-key "Toggle")
  "tb"  '(gl/toggle-file-bookmark :which-key "Toggle File Bookmark")
  "tt"  '(vterm-toggle-cd :which-key "Toggle VTerm")
  "te"  '(treemacs :which-key "File Explorer")
  "tl"  '(display-line-numbers-mode :which-key "Toggle Line Numbers")

  ;; Projectile
  "p"   '(:ignore t :which-key "Project")
  "pa"  '(projectile-add-known-project :which-key "Add New Project")
  "pf"  '(projectile-find-file :which-key "Find File")
  "pp"  '(projectile-switch-project :which-key "Switch Project")
  "pr"  '(projectile-recentf :which-key "Recent Project Files")
  "pk"  '(projectile-kill-buffers :which-key "Kill Project Buffers")

  ;; Org-mode
  "o"   '(:ignore t :which-key "Org-mode")
  "oa"  '(org-agenda-list :which-key "Weekly Agenda")
  "os"  '((lambda () (interactive) (find-file (expand-file-name "scratchpad.org" org-directory))) :which-key "Scratchpad")
  "oc"  '(org-capture :which-key "Capture Task")
  "ot"  '(org-todo-list :which-key "Global TODOs")
  "or"  '(gl/refresh-org-agenda-files :which-key "Refresh Agenda Files")

  ;; Code/LSP
  "c"   '(:ignore t :which-key "Code")
  "ca"  '(lsp-execute-code-action :which-key "Code Actions")
  "cd"  '(lsp-find-definition :which-key "Jump to Definition")
  "cr"  '(lsp-rename :which-key "Rename Variable")
  "cf"  '(lsp-format-buffer :which-key "Format Buffer")
  "cQ"  '(lsp-workspace-restart :which-key "Restart LSP Server")

  ;; Magit
  "m"   '(:ignore t :which-key "Magit")
  "mm"  '(magit-status :which-key "Status")
  "mb"  '(magit-blame :which-key "Blame")
  "ml"  '(magit-log-current :which-key "Log")
  "mf"  '(magit-file-dispatch :which-key "File Actions")

  ;; GPTel
  "g"   '(:ignore t :which-key "GPTel")
  "gg"  '(gptel-send :which-key "Send")
  "gc"  '(gptel :which-key "Chat")
  "gr"  '(gptel-rewrite :which-key "Rewrite")
  "gm"  '(gptel-menu :which-key "Menu"))

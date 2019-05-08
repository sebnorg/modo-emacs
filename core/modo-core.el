;;; modo-core.el --- core settings -*- lexical-binding: t -*-
;;; Commentary:

;; Core settings and definitions that must always be loaded.

;;; Code:

;;; Directory variables
(defvar modo-emacs-dir (file-truename (expand-file-name user-emacs-directory))
  "The path to the emacs.d directory containing the modo emacs files.")

(defvar modo-core-dir (concat modo-emacs-dir "core/")
  "The directory containing the core of modo emacs.")

(defvar modo-modules-dir (concat modo-emacs-dir "modules/")
  "The directory containing modo modules.")

(defvar modo-cache-dir (concat modo-emacs-dir "cache/")
  "The directory storing persistent information.")
(unless (file-exists-p modo-cache-dir)
  (make-directory modo-cache-dir))

(defvar modo-temp-dir (concat modo-emacs-dir "temp/")
  "The directory storing temporary files.")
(unless (file-exists-p modo-temp-dir)
  (make-directory modo-temp-dir))

(defvar modo-private-dir (concat modo-emacs-dir "private/")
  "Directory for storing private configuration files.")
(unless (file-exists-p modo-private-dir)
  (make-directory modo-private-dir))

(defvar modo-private-init-file (concat modo-emacs-dir "init-private.el")
  "Private equivalent of init.el.")

;;; UTF-8 all the things
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8)
(set-fontset-font "fontset-default" 'unicode
                  (font-spec :family "DejaVu Sans Mono"))

;;; Custom file
(setq custom-file (expand-file-name "custom.el" modo-emacs-dir))
(load custom-file t t)

;; Be quiet at startup
(advice-add #'display-startup-echo-area-message :override #'ignore)
(setq inhibit-splash-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;;; Initial high threshold for garbage collection
(let ((normal-gc-cons-threshold (* 20 1024 1024)) ;; ~20 mb
      (init-gc-cons-threshold (* 256 1024 1024)) ;; ~256 mb
      (base-file-name-handler-alist file-name-handler-alist))
  (setq gc-cons-threshold init-gc-cons-threshold
        gc-cons-percentage 0.6
        file-name-handler-alist nil)
  (add-hook 'emacs-startup-hook
            (lambda () (setq gc-cons-threshold normal-gc-cons-threshold
                             gc-cons-percentage 0.1
                             file-name-handler-alist base-file-name-handler-alist))))

;;; Load package system
(require 'modo-package (concat modo-core-dir "modo-package"))

;;; Just get it over with
(straight-use-package 'dash)
(straight-use-package 's)
(straight-use-package 'f)

(require 'cl-lib)
(require 'dash)
(require 's)
(require 'f)

;;; Load rest of core
(unless noninteractive
  ;; Keybind definers
  ;; hydra
  (straight-use-package 'lv)
  (straight-use-package 'hydra)
  (use-package hydra
    :demand t)

  ;; general.el --- get your keybinds here!
  (straight-use-package 'general)
  (use-package general
    :demand t
    :config
    (general-override-mode))

  ;; Leader keys
  (defconst modo-leader "SPC"
    "The general purpose leader accessible from normal mode.")

  (defconst modo-non-normal-leader "C-c"
    "Equivalent to the normal mode leader, but used in insert and emacs mode.")

  (defconst modo-major-leader ","
    "Shortcut for major mode keys, also bound to \"<leader> m\"")

  ;; Definer for standard shortcuts
  (general-create-definer modo-define-leader-key
                          :states '(motion normal visual insert emacs)
                          :prefix modo-leader
                          :non-normal-prefix modo-non-normal-leader)
  (general-create-definer modo--direct-major-leader-key
                          :states '(motion normal visual)
                          :prefix modo-major-leader)
  (general-create-definer modo--indirect-major-leader-key
                          :states '(motion normal visual insert emacs)
                          :prefix (concat modo-leader " m")
                          :non-normal-prefix (concat modo-non-normal-leader " m"))
  (defmacro modo-define-major-leader-key (&rest args)
    "Defines leader key bindings for a major mode. Commands are
bound both under <major-leader>, as well as \"<leader> m\"."
    (declare (indent defun))
    (let ((expansion nil)
          (map (plist-get args :keymaps)))
      (push `(modo--direct-major-leader-key ,@args) expansion)
      (when map
        (push '(quote (:ignore t :which-key "major mode")) args)
        (push "m" args))
      (push `(modo--indirect-major-leader-key ,@args) expansion)
      `(progn
         ,@expansion)))

  ;; Rest of the core features
  (require 'modo-os)
  (require 'modo-utils)
  (require 'modo-evil)
  (require 'modo-editor)
  (require 'modo-projects)
  (require 'modo-ui)
  (require 'modo-keybinds))

(provide 'modo-core)
;;; modo-core.el ends here

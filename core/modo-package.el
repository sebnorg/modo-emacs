;;; modo-package.el --- package management -*- lexical-binding: t -*-
;;; Commentary:

;; Handles package management for modo emacs.

;;; Code:

;;; org shenanigans
;; This deletes the built-in org from the load path, _hopefully_ preventing it
;; from interfering with the straight provided one
;; TODO: condition this on org module being requested
(require 'subr-x)
(when-let* ((org-path (locate-library "org")))
 (setq load-path (delete (substring (file-name-directory org-path) 0 -1)
                         load-path)))

;;; straight.el
;; Bootstrap snippet
(setq straight-repository-branch "develop"
      straight-fix-org nil)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Use the elpa mirror
(setq straight-recipes-gnu-elpa-use-mirror t)

;;; Set up core profiles
(setq straight-profiles
      '((modo-core . "../../versions/modo-core-versions.el")
        (nil . "../../versions/default.el")))
(setq straight-current-profile 'modo-core)
(add-hook 'after-init-hook
          (lambda () (setq straight-current-profile nil)))

;; Prefer newer files
(setq load-prefer-newer t)
;; Add core dir and modules dir to load path
(add-to-list 'load-path modo-core-dir)
(add-to-list 'load-path modo-modules-dir)

;; Early loading of meta-packages
(straight-use-package 'melpa)
(straight-use-package 'epl)
(straight-use-package 'pkg-info)

;; Macro for requiring modules
(defmacro modo-module (&rest modules)
  "Load all the modules listed in MODULES, with the prefix modo-.
For example, the module name ivy translates to a call to (require 'modo-ivy)."
  (let ((expansion nil)
        (module-name)
        (module-symbol))
    (dolist (module modules)
      (setq module-name (format "modo-%s" (symbol-name module)))
      (setq module-symbol (intern module-name))
      (push `(push '(,module-symbol . ,(format "../../versions/%s-versions.el" module-name))
                   straight-profiles)
            expansion)
      (push `(setq straight-current-profile ',module-symbol) expansion)
      (push `(require ',module-symbol) expansion))
    (setq expansion (nreverse expansion))
    `(progn
       ,@expansion
       ;; After loading modules we switch to private configuration for the
       ;; remainder of init.el
       (push '(modo-private . "../../private/modo-private-versions.el")
             straight-profiles)
       (setq straight-profiles (nreverse straight-profiles))
       (setq straight-current-profile 'modo-private))))

;; Clone from github
(defun modo-github-clone (username repo)
  "Clones the repository USERNAME/REPO from github using HTTPS."
  (let ((target (concat modo-repo-dir repo))
        (repo-url (format "https://github.com/%s/%s.git" username repo)))
    (make-directory target)
    (message "Cloning %s into %s..." repo target)
    (when (not (= 0 (shell-command (format "git clone %s %s" repo-url target)
                                   "*git clone output*")))
      (error "Failed to clone %s" repo))
    (message "Cloning %s into %s... done." repo target)))

;;; use-package
(straight-use-package 'diminish)
(straight-use-package 'use-package)

(setq use-package-verbose t)
(setq use-package-always-defer t)
(eval-when-compile
  (require 'use-package))
(require 'diminish)

(provide 'modo-package)
;;; modo-package.el ends here

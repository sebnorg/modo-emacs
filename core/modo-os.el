;;; modo-os.el --- os specific configuration -*- lexical-binding: t -*-
;;; Commentary:

;; Core settings that are specific to a certain operating system go here.

;;; Code:

;;; Windows

;; Since we are using straight.el, git is required to be installed. Thus,
;; M-x shell is configured to use git-bash once the user has configured
;; its location. DO NOT expect miracles with this, but its something.
(when (eq system-type 'windows-nt)

  (defcustom modo-git-path nil
    "String specifying the root directory of the git for windows installation.")

  ;; TODO: Validate path
  (when (stringp modo-git-path)
    (setq explicit-shell-file-name
          (expand-file-name "usr/bin/bash.exe" modo-git-path)
          shell-file-name explicit-shell-file-name
          explicit-bash.exe-args '("--login" "-i"))
    (setenv "SHELL" shell-file-name)
    (add-to-list 'exec-path modo-git-path)
    (add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)))

(provide 'modo-os)
;;; modo-os.el ends here
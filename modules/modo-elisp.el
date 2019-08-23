;;; modo-elisp.el --- elisp editting -*- lexical-binding: t -*-
;;; Commentary:

;; Editing the engine itself!

;;; Code:

(defun modo--elisp-extra-fontification ()
  "Fontify modo functions."
  (font-lock-add-keywords
   nil `(("\\(^\\|\\s-\\|,\\)(\\(\\(modo\\|\\+\\)[^) ]+\\)[) \n]" (2 font-lock-keyword-face)))))

(add-hook 'emacs-lisp-mode-hook #'modo--elisp-extra-fontification)

(provide 'modo-elisp)
;;; modo-elisp.el ends here

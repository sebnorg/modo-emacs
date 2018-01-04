;;; modo-snippets.el --- computer types so you don't have to -*- lexical-binding: t -*-
;;; Commentary:

;; Snippet expansion based on yasnippet.

;;; Code:
(straight-use-package 'yasnippet)
(use-package yasnippet
  :commands (yas-minor-mode
             yas-minor-mode-on)
  :init
  (add-hook 'text-mode-hook #'yas-minor-mode-on)
  (add-hook 'prog-mode-hook #'yas-minor-mode-on)
  (add-hook 'snippet-mode-hook #'yas-minor-mode-on)
  :config
  (setq yas-snippet-dirs `(,(concat modo-emacs-dir "snippets/"))
        yas-triggers-in-field t
        yas-use-menu nil)
  (yas-reload-all))

(provide 'modo-snippets)
;;; modo-snippet.el ends here

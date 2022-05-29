;;; sway-mode.el --- major mode for sway  -*- lexical-binding: t; -*-
;;; commentary:
;;; code:
(eval-when-compile
  (require 'rx))

(defun sway-mode-fmt-custom (path)
  "Formats sway files within the supplied PATH."
  (interactive "spath to toml file:")
  (shell-command "forc fmt --path %s" path))


(defun sway-mode-fmt ()
  "Formats a single sway file."
  (interactive)
  (let ((default-directory (expand-file-name "../")))
    (shell-command-to-string "forc fmt")))


(defun sway-mode-activate-lsp ()
  "Activates forc-lsp for lsp mode in Emacs."
  (interactive)
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration
                 '(sway-mode . "sway-mode"))

    (lsp-register-client
     (make-lsp-client :new-connection (lsp-stdio-connection "forc-lsp")
                      :activation-fn (lsp-activate-on "sway-mode")
                      :server-id 'forc-lsp)))
  (lsp)
  )

(defvar function-call-highlights "\\(\\(?:\\w\\|\\s_\\)+\\)\\(<.+>\\)?\s*("
  "Regex for general Sway function calls.")

(defvar function-call-type-highlights "\\b\\([A-Za-z][A-Za-z0-9_]*\\|_[A-Za-z0-9_]+\\)\\(::\\)\\(<.*>\s*\\)\("
  "Regex for Sway function calls with type.")


(defvar declarations-without-name '("contract" "script" "predicate")
  "Sway specific declarations.")

(defvar sway-type-level-declaration  "\\b\\(abi\\|library\\)\\s-"
  "Sway specific type level declaration.")

(setq sway-highlights
      `(
        (,(regexp-opt declarations-without-name 'symbols) . 'font-lock-keyword-face)
        (, sway-type-level-declaration . 'font-lock-keyword-face)
        (,function-call-highlights . (1 'font-lock-function-name-face))
        (,function-call-type-highlights . (1 'font-lock-function-name-face))
        ))



;;; KeyMap
(defvar sway-mode-map
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap (kbd "C-c c") 'sway-mode-fmt)
    (define-key keymap (kbd "C-c a") 'sway-mode-fmt-custom)
    (define-key keymap (kbd "C-c r") 'sway-mode-activate-lsp)
    keymap)
  "Keymap for `sway-mode'.")


;;;###autoload
(define-derived-mode sway-mode rust-mode
  "Sway"
  (font-lock-add-keywords nil sway-highlights)
  (use-local-map sway-mode-map)

  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.sw" . sway-mode))

;; add to feature list
(provide 'sway-mode)
;;; sway-mode.el ends here

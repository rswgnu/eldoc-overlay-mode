;;; eldoc-overlay-mode.el --- Display eldoc with contextual documentation overlay.

;; Author: stardiviner <numbchild@gmail.com>
;; Keywords: eldoc overlay
;; URL: https://github.com/stardiviner/eldoc-overlay
;; Created: 14th Jan 2017
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.3"))

;;; Commentary:



;;; Code:
;;; ----------------------------------------------------------------------------

(defvar eldoc-overlay-display-overlay nil)

(defface eldoc-overlay-face
  '((nil (:background "light gray" :box '(:color "gray" :line-width 1))))
  "Face for eldoc-overlay-mode."
  :group 'eldoc)

(defun eldoc-overlay-delete-string-display ()
  (when (overlayp eldoc-overlay-display-overlay)
    (delete-overlay eldoc-overlay-display-overlay))
  (remove-hook 'post-command-hook 'eldoc-overlay-delete-string-display))

(defun eldoc-overlay-string-display-next-line (string)
  "Overwrite contents of next line with STRING until next command."
  (let ((str (concat (make-string (1+ (current-indentation)) 32)
                     (copy-sequence string)))
        start-pos end-pos)
    (unwind-protect
        (save-excursion
          (eldoc-overlay-delete-string-display)
          (forward-line)
          (setq start-pos (point))
          (end-of-line)
          (setq end-pos (point))
          (setq eldoc-overlay-display-overlay (make-overlay start-pos end-pos))
          ;; Change the face
          (overlay-put eldoc-overlay-display-overlay 'face 'eldoc-overlay-face)
          ;; Hide full line
          (overlay-put eldoc-overlay-display-overlay 'display "")
          ;; Display message
          (overlay-put eldoc-overlay-display-overlay 'before-string str))
      (add-hook 'post-command-hook 'eldoc-overlay-delete-string-display))))

(defun eldoc-overlay-display-message-momentary (format-string &rest args)
  "Display eldoc message near point."
  (when format-string
    (eldoc-overlay-string-display-next-line
     (apply 'format format-string args))))

(defvar eldoc-overlay-mode-map
  (let ((map (make-sparse-keymap)))
    map))

;;;###autoload
(define-minor-mode eldoc-overlay-mode
  "Minor mode for displaying eldoc with contextual documentation overlay."
  t
  :lighter "ElDoc overlay"
  :keymap eldoc-overlay-mode-map
  :global t
  (if eldoc-overlay-mode
      (setq eldoc-message-function #'eldoc-overlay-display-message-momentary)
    (setq eldoc-message-function #'eldoc-minibuffer-message)
    )
  )

;;; ----------------------------------------------------------------------------

(provide 'eldoc-overlay-mode)

;;; eldoc-overlay-mode.el ends here

;;; wordle-colors.el --- Color wordle blocks -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Edward Minnix III
;;
;; Author: Edward Minnix III <egregius313@gmail.com>
;; Maintainer: Edward Minnix III <egregius313@gmail.com>
;; Created: October 30, 2025
;; Modified: October 30, 2025
;; Version: 0.0.1
;; Keywords: faces games
;; Homepage: https://github.com/egregius313/wordle-colors
;; Package-Requires: ((emacs "30.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;; Adds support for syntax highlighting results from Wordle games
;;
;;; Code:
;;;
(eval-when-compile
  (require 'cl-lib))
(require 'org-element)
(require 'org-element-ast)

(defgroup wordle-colors ()
  "Highlight Wordle colors."
  :group 'font-lock-extra-types)

(defface wordle-colors-green
  '((t (:bold t :background "#6ca965" :foreground "#ffffff")))
  "Wordle green."
  :group 'wordle-colors)

(defface wordle-colors-yellow
  '((t (:background "#c8b653" :foreground "#ffffff")))
  "Wordle yellow."
  :group 'wordle-colors)

(defface wordle-colors-gray
  '((t :background "#787c7f" :foreground "#ffffff"))
  "Wordle gray."
  :group 'wordle-colors)

(defun wordle-colors--in-wordle-block-p ()
  "Return t when point is at a source block element.
When INSIDE is non-nil, return t only when point is between #+BEGIN_SRC
and #+END_SRC lines.

Note that affiliated keywords and blank lines after are considered a
part of a source block.

When ELEMENT is provided, it is considered to be element at point."
  (cl-loop
   for el = (org-element-at-point) then (org-element-parent el)
   for i from 0
   when (and (eq 'special-block (org-element-type el))
             (string-equal-ignore-case (org-element-property :type el) "WORDLE"))
   return t
   when (> i 10)
   return nil))

(defun wordle-colors--search (&optional bound backward)
  "Search for a Wordle cell.

BOUND is where to start the search.

BACKWARD is incase we need to search backwards (based on `hl-todo-mode')."
  (let ((regexp (rx (group-n 2 (any "+/*")) (group-n 1 alpha) (backref 2))))
    (cl-block nil
      (while (funcall (if backward #'re-search-backward #'re-search-forward) regexp bound t)
        (cond
         ((wordle-colors--in-wordle-block-p)
          (cl-return t))
         ((and bound (funcall (if backward #'<= #'>=) (point) bound))
          (cl-return nil)))))))

(defun wordle-colors--get-face ()
  "Get the face for the current Wordle cell."
  (pcase (match-string 2)
    ("/" 'wordle-colors-yellow)
    ("*" 'wordle-colors-green)
    ("+" 'wordle-colors-gray)))

(defvar wordle-colors--keywords
  `((,(lambda (bound) (wordle-colors--search bound))
     (0 (wordle-colors--get-face) prepend t)))
  "Wordle Colors font-lock keywords.")

(define-minor-mode wordle-colors-mode
  "Highlight [!IMPORTANT] and similar keywords in quote blocks."
  :group 'wordle-colors
  (if wordle-colors-mode
      (font-lock-add-keywords nil wordle-colors--keywords t)
    (font-lock-remove-keywords nil wordle-colors--keywords)))

(provide 'wordle-colors)
;;; wordle-colors.el ends here

; -*-emacs-lisp-*-

(package-initialize)

(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)

(setq column-number-mode t)
(setq inhibit-splash-screen t)
(setq ispell-dictionary "british")
(setq kill-do-not-save-duplicates t)
(setq make-backup-files nil)
(setq scroll-preserve-screen-position t)
(setq select-active-regions t)
(setq tab-always-indent 'complete)
(setq truncate-partial-width-windows nil)
(setq user-full-name "Ben Spencer")
(setq user-mail-address "ben.spencer@openeyes.org.uk")
(setq vc-make-backup-files nil)

(setq-default indicate-empty-lines t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)

(global-unset-key (kbd "<prior>"))
(global-unset-key (kbd "<next>"))
(global-unset-key (kbd "<left>"))
(global-unset-key (kbd "<right>"))
(global-unset-key (kbd "<up>"))
(global-unset-key (kbd "<down>"))
(global-unset-key (kbd "C-x C-c"))

(global-set-key (kbd "C-c d") 'flymake-display-err-minibuf)
(global-set-key (kbd "C-x f") 'find-file-at-point)

(global-set-key (kbd "C-c h") 'openeyes-file-header)
(global-set-key (kbd "C-c b") 'docblock)

(global-set-key (kbd "C-x c") 'open-shell-in-current-dir)

(global-set-key
 (kbd "C-x F")
 (lambda ()
   (interactive)
   (kill-new buffer-file-name)
   (message buffer-file-name)))

(define-key emacs-lisp-mode-map (kbd "C-c C-c") 'eval-defun)

(add-hook 'after-init-hook 'server-start)
(setq server-raise-frame t)

(ido-mode t)
(setq ido-default-buffer-method 'selected-window)
(setq ido-default-file-method 'selected-window)
(setq ido-auto-merge-work-directories-length -1)
(setq ido-enable-flex-matching t)

(require 'dabbrev)
(setq dabbrev-case-replace nil)

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

(require 'vc-annotate)
(define-key vc-annotate-mode-map (kbd "q") 'kill-buffer-and-window)

(eval-after-load "comint"
  '(define-key comint-mode-map (kbd "C-c M-o")
    (lambda () (interactive) (let ((comint-buffer-maximum-size 0)) (comint-truncate-buffer)))))

(load (expand-file-name "~/quicklisp/slime-helper.el"))
(setq inferior-lisp-program "ccl")

(defun my-emacs-lisp-mode-hook ()
  (eldoc-mode 1))
(add-hook 'emacs-lisp-mode-hook 'my-emacs-lisp-mode-hook)

(defconst oe-php-style
  '((c-offsets-alist . ((arglist-close . 0)
			(arglist-cont-nonempty . +)
			(arglist-cont-nonempty . +)
			(case-label . +)))
    (indent-tabs-mode . t)
    (comment-start . "// ")
    (comment-end . ""))
  "OpenEyes PHP Coding Standard")
(c-add-style "oe-php" oe-php-style)

(defun my-php-mode-hook ()
  (c-set-style "oe-php")
  (subword-mode 1)
  (setq show-trailing-whitespace t)
  (php-eldoc-enable)
  (flymake-php-load)
  (when (string-match-p "/views/" buffer-file-name)
    (c-toggle-electric-state -1)))
(add-hook 'php-mode-hook 'my-php-mode-hook)

(defun my-js-mode-hook ()
  (setq indent-tabs-mode t
	tab-width 4)
  (subword-mode t))
(add-hook 'js-mode-hook 'my-js-mode-hook)

(defun my-json-mode-hook ()
  (subword-mode 1)
  (flymake-json-load))
(add-hook 'json-mode-hook 'my-json-mode-hook)

(defun my-scala-mode-hook ()
  (subword-mode 1))
(add-hook 'scala-mode-hook 'my-scala-mode-hook)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

(defun flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list)))
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)))
      (setq count (1- count)))))

(defun open-shell-in-current-dir ()
  (interactive)
  (call-process "screen" nil nil nil "-X" "screen" "/Users/ben/bin/cdbash" (file-name-directory buffer-file-name)))

(defun docblock ()
  (interactive)
  (let ((m (point-marker))
	(empty (empty-line-p (point)))
	(eol (eolp))
	(params (php-get-function-params)))
    (when (and (not empty) eol)
      (insert "\n"))
    (insert "\t/**\n")
    (unless params
      (insert "*\n"))
    (mapc (lambda (p) (insert (concat "* @param " p "\n"))) params)
    (insert "*/")
    (when (and (not empty) (not eol))
      (insert "\n"))
    (forward-char)
    (indent-region m (point))
    (unless params
      (forward-line -2)
      (end-of-line)
      (insert " "))))

(defun openeyes-file-header ()
  (interactive)
  (when (string= (substring buffer-file-name -3) "php")
    (insert"<?php\n"))
  (let ((year (format-time-string "%Y")))
    (insert "/**
 * (C) OpenEyes Foundation, " year "
 * This file is part of OpenEyes.
 * OpenEyes is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 * OpenEyes is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with OpenEyes in a file titled COPYING. If not, see <http://www.gnu.org/licenses/>.
 *
 * @package OpenEyes
 * @link http://www.openeyes.org.uk
 * @author OpenEyes <info@openeyes.org.uk>
 * @copyright Copyright (C) " year ", OpenEyes Foundation
 * @license http://www.gnu.org/licenses/gpl-3.0.html The GNU General Public License V3.0
 */

")))

(defun php-get-function-params ()
  (save-excursion
    (let* ((start (point-marker))
	  (limit (progn (forward-word 5) (point-marker)))
	  (r (progn (goto-char start) (search-forward "(" limit t))))
      (when r
	(let* ((open (point-marker))
	       (close (progn (backward-char) (forward-list) (backward-char) (point-marker)))
	       (str (buffer-substring-no-properties open close)))
	  (unless (string= str "")
	    (mapcar (lambda (s) (car (split-string s "\s*=\s*")))
		    (split-string str "\s*,\s*"))))))))

(defun empty-line-p (p)
  (and (eq ?\n (char-before p))
       (eq ?\n (char-after p))))

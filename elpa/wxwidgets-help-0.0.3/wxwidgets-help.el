;;; wxwidgets-help.el --- Look up wxWidgets API by using local html manual

;; Copyright (C) 2012 Chen Bin
;; Author: Chen Bin <chenbin.sh@gmail.com>
;; URL: http://github.com/redguardtoo/wxwidgets-help
;; Keywords: wxWidgets C++ manual
;; Version: 0.0.3

;; This file is not part of GNU Emacs.

;; This file is free software (GPLv3 License)

;; How to set it up:
;; See README.org which is distributed with this file

;;; Code:
(defvar wxhelp-hash (make-hash-table :test 'equal ))
(defun wxhelp-init-hash ()
  (clrhash wxhelp-hash)
  (puthash "a" "0x61.html" wxhelp-hash)
  (puthash "b" "0x62.html" wxhelp-hash)
  (puthash "c" "0x63.html" wxhelp-hash)
  (puthash "d" "0x64.html" wxhelp-hash)
  (puthash "e" "0x65.html" wxhelp-hash)
  (puthash "f" "0x66.html" wxhelp-hash)
  (puthash "g" "0x67.html" wxhelp-hash)
  (puthash "h" "0x68.html" wxhelp-hash)
  (puthash "i" "0x69.html" wxhelp-hash)
  (puthash "j" "0x6a.html" wxhelp-hash)
  (puthash "k" "0x6b.html" wxhelp-hash)
  (puthash "l" "0x6c.html" wxhelp-hash)
  (puthash "m" "0x6d.html" wxhelp-hash)
  (puthash "n" "0x6e.html" wxhelp-hash)
  (puthash "o" "0x6f.html" wxhelp-hash)
  (puthash "p" "0x70.html" wxhelp-hash)
  (puthash "q" "0x71.html" wxhelp-hash)
  (puthash "r" "0x72.html" wxhelp-hash)
  (puthash "s" "0x73.html" wxhelp-hash)
  (puthash "t" "0x74.html" wxhelp-hash)
  (puthash "u" "0x75.html" wxhelp-hash)
  (puthash "v" "0x76.html" wxhelp-hash)
  (puthash "w" "0x77.html" wxhelp-hash)
  (puthash "x" "0x78.html" wxhelp-hash)
  (puthash "y" "0x79.html" wxhelp-hash)
  (puthash "z" "0x7a.html" wxhelp-hash)
  (puthash "~" "functions_0x7e.html" wxhelp-hash)
  (puthash "_" "functions.html" wxhelp-hash)
  )

(defun wxhelp-root-dir ()
  (let ((rd (getenv "WXWIN")))
    (if (not rd)
        (setq rd (getenv "WXWIDGETS"))
        )
    rd
    )
  )

;;;###autoload
(defun wxhelp-api-index ()
  "List wxWidgets API in its default HTML manual"
  (interactive)
  (let ((rd (wxhelp-root-dir)))
    (when rd
      (w3m-browse-url (concat rd "/docs/doxygen/out/html/group__group__funcmacro.html"))
      )
    )
  )

;;;###autoload
(defun wxhelp-class-index ()
  "List wxWidgets class in its default HTML manual"
  (interactive)
  (let ((rd (wxhelp-root-dir)))
    (when rd
      (w3m-browse-url (concat rd "/docs/doxygen/out/html/group__group__class.html"))
      )
    )
  )

(defun wxhelp-match-strs (s)
  (let ((cs case-fold-search) v r l (i 0))
    (setq case-fold-search nil) ;case sensitive search
    (while (setq i (string-match "\\([A-Z][a-z]*\\)" s i))
      (setq r (downcase (match-string 1 s)))
      (setq l (concat l "_" r))
      (setq i (+ i (length r) ))
      )
    ;restore
    (setq case-fold-search cs)
    l
    )
  )

(defun wxhelp-readlines (fPath)
    "Return a list of lines of a file at fPath."
      (with-temp-buffer
            (insert-file-contents fPath)
                (split-string (buffer-string) "\n" t)))

(defun wxhelp-query-var (f re)
  (let (v lines)
    (setq lines (wxhelp-readlines f))
    (catch 'brk
      (dolist (l lines)
        (when (string-match re l)
          (setq v (match-string 1 l))
          (throw 'brk t)
          )
        )
      )
    v
    )
  )

(defun wxhelp-prefix (k)
  (let (c)
    (if (string= (substring k 0 2) "wx")
        (setq c (substring k 2 3))
        (setq c (substring k 0 1))
        )
    (downcase c)
    )
  )
;;;###autoload
(defun wxhelp-browse-api (k)
  (interactive "sAPI or Macro: ")
  (wxhelp-init-hash)
  (let ((ck (wxhelp-prefix k))
        c
        hlp
        )
    (if (or (string= ck "_") (string= ck "~"))
      (setq c (gethash ck wxhelp-hash))
      (setq c (concat "functions_" (gethash ck wxhelp-hash)))
      )
    (when (and c (wxhelp-root-dir))
      (setq hlp (concat (wxhelp-root-dir) "/docs/doxygen/out/html/" c))
      (if (wxhelp-query-var hlp (concat "<li>\\(" k "\\)"))
          (w3m-browse-url hlp)
        ;; global functions?
        (setq c (concat "globals_func_" (gethash ck wxhelp-hash)))
        (setq hlp (concat (wxhelp-root-dir) "/docs/doxygen/out/html/" c))
        (if (wxhelp-query-var hlp (concat "<li>\\(" k "\\)"))
            (w3m-browse-url hlp)
          ;; global vars?
          (setq c (if (string= ck "a") "globals_vars.html" (concat "globals_vars_" (gethash ck wxhelp-hash))))
          (setq hlp (concat (wxhelp-root-dir) "/docs/doxygen/out/html/" c))
          (if (wxhelp-query-var hlp (concat "<li>w?x?\\(" k "\\)"))
              (w3m-browse-url hlp)
            ;; global enum?
            (setq c (if (string= ck "a") "globals_enum.html" (concat "globals_enum_" (gethash ck wxhelp-hash))))
            (setq hlp (concat (wxhelp-root-dir) "/docs/doxygen/out/html/" c))
            (if (wxhelp-query-var hlp (concat "<li>w?x?\\(" k "\\)"))
                (w3m-browse-url hlp)
              ;; maybe it's just in gidcmn.h?
              (setq hlp (concat (wxhelp-root-dir) "/docs/doxygen/out/html/" "gdicmn_8h.html"))
              (w3m-browse-url hlp)
              )
            )
          )
        )
      (kill-new k)
      (message "%s => clipboard" k)
      )
    )
  )

;;;###autoload
(defun wxhelp-browse-class-or-api (k)
  (interactive "sKeyword: ")
  (let ((rd (wxhelp-root-dir))
        ;; class?
        hlp
        )
    (when rd
      (setq hlp (concat rd "/docs/doxygen/out/html/classwx" (wxhelp-match-strs k) ".html"))
      (if (file-exists-p hlp)
        (w3m-browse-url hlp)
        ;; general topic?
        (setq hlp (concat rd "/docs/doxygen/out/html/group__group__class__" (downcase k) ".html"))
        (if (file-exists-p hlp)
            (w3m-browse-url hlp)
            ;; API or macro?
            (wxhelp-browse-api k)
          )
        )
      )
    )
  )

(provide 'wxhelp)

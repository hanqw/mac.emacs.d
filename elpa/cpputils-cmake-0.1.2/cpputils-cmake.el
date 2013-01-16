;;; cpputils-cmake.el --- Easy real time C++ syntax check and IntelliSense if you use CMake.

;; Copyright (C) 2012 Chen Bin
;; Author: Chen Bin <chenbin.sh@gmail.com>
;; URL: http://github.com/redguardtoo/cpputils-cmake
;; Keywords: CMake IntelliSense Flymake
;; Version: 0.1.2

;; This file is not part of GNU Emacs.

;; This file is free software (GPLv3 License)

;; How to set it up:
;; See README.org which is distributed with this file

;;; Code:
(defcustom cppcm-proj-max-dir-level 16 "maximum level of the project directory tree"
  :type 'number
  :group 'cpputils-cmake)

(defcustom cppcm-build-dirname "build" "The directory name of build directory"
  :type 'string
  :group 'cpputils-cmake)

(defvar cppcm-build-dir nil "The full path of build directory")
(defvar cppcm-src-dir nil "The full path of root source directory")
(defvar cppcm-include-dirs nil "List of include directories. Each directory string has '-I' prefix")

(defvar cppcm-hash (make-hash-table :test 'equal))
(defconst cppcm-prog "cpputils-cmake")
(defconst cppcm-makefile-name "Makefile")

(defun cppcm-readlines (fPath)
    "Return a list of lines of a file at fPath."
      (with-temp-buffer
            (insert-file-contents fPath)
                (split-string (buffer-string) "\n" t)))

(defun cppcm-parent-dir (d)
  (file-name-directory (directory-file-name d))
  )

(defun cppcm-query-var (f re)
  (let (v lines)
    (setq lines (cppcm-readlines f))
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

;; get all the possible targets
(defun cppcm-query-targets (f)
  (let ((vars ())
        (re "\\(add_executable\\|add_library\\)\s*(\\([^\s]+\\)")
        lines)
    (setq lines (cppcm-readlines f))
    (dolist (l lines)
      (when (string-match re l)
        (push (list (downcase (match-string 1 l)) (match-string 2 l)) vars)
        )
      )
    vars
    )
  )
;; get all the possible targets
;; @return matched line, use (match-string 2 line) to get results
(defun cppcm-match-all-lines (f)
  (let ((vars ())
        (re "\\(add_executable|add_library\\)\s*(\\([^\s]+\\)")
        lines)
    (setq lines (cppcm-readlines f))
    (catch 'brk
      (dolist (l lines)
        (when (string-match re l)
          (push l vars)
          )
        )
      )
    vars
    )
  )

(defun cppcm-query-match-line (f re)
  "return match line"
  (let (ml lines)
    (setq lines (cppcm-readlines f))
    (catch 'brk
      (dolist (l lines)
        (when (string-match re l)
          (setq ml l)
          (throw 'brk t)
          )
        )
      )
    ml
    )
  )
;; find the first line in CMakeCache.txt and assume it's the root src directory
;; kind of hack
(defun cppcm-get-source-dir (d)
    (cppcm-query-var (concat d "CMakeCache.txt") "[[:word:]]+_SOURCE_DIR\:STATIC\=\\(.*\\)")
    )

(defun cppcm-get-dirs ()
  (let ((crt-proj-dir (file-name-as-directory (file-name-directory buffer-file-name)))
        (i 0)
        (is-root-dir-found nil)
        )
    (setq cppcm-build-dir nil)
    (setq cppcm-src-dir nil)
    (catch 'brk
           ; if current directory does not contain CMakeLists.txt, we assume the
           ; whole project does not use cmake at all
           (if (not (file-exists-p (concat crt-proj-dir "CMakeLists.txt"))) (throw 'brk nil))

           (while (and (< i cppcm-proj-max-dir-level) (not is-root-dir-found) )
                  (setq cppcm-build-dir (concat crt-proj-dir (file-name-as-directory cppcm-build-dirname)))
                  (cond ((and (file-exists-p (concat cppcm-build-dir "CMakeCache.txt")))
                         (setq is-root-dir-found t)
                         )
                        (t ;default
                          (setq crt-proj-dir (cppcm-parent-dir crt-proj-dir))
                          )
                        )
                  (setq i (+ i 1))
                  )
           (when is-root-dir-found
             (setq cppcm-src-dir (cppcm-get-source-dir cppcm-build-dir))
             )
           )
    is-root-dir-found
  ))

(defun cppcm-guess-var (var cm)
    (cppcm-query-var cm (concat "\s*set(\s*" var "\s+\\(\\w+\\)\s*)" ) )
  )

(defun cppcm-replace-once (pattern str)
  (let (re)
    (setq re (concat "\\(" pattern "\\).*\\'"))
    ;; don't know why, copied from API documentation
    (replace-regexp-in-string re "" str nil nil 1)
    )
  )

(defun cppcm-trim-string (string)
  "Remove white spaces in beginning and ending of STRING.
White space here is any of: space, tab, emacs newline (line feed, ASCII 10)."
  (replace-regexp-in-string "\\`[ \t\n]*" "" (replace-regexp-in-string "[ \t\n]*\\'" "" string)))

(defun cppcm-trim-cppflags (cppflags)
  (let (tks
        (v ""))
    (setq tks (split-string (cppcm-trim-string cppflags) "\s+" t))
    (dolist (tk tks v)
      (when (string= (substring tk 0 2) "-I")
        (setq v (concat v " " tk))
        ))
    v
  ))

;; @return full path of executable and we are sure it exists
(defun cppcm-guess-exe-full-path (exe-dir tgt)
  (let (p
        (type (car tgt))
        (e (cadr tgt))
        )
    (if (string= type "add_executable")
        (progn
          ;; application bundle on OS X?
          (setq p (concat exe-dir e (if (eq system-type 'darwin) (concat ".app/Contents/MacOS/" e))))
          ;; maybe the guy on Mac prefer raw application? try again.
          (if (not (file-exists-p p)) (setq p (concat exe-dir e)))
          (if (not (file-exists-p p)) (setq p nil))
          )
      (if (file-exists-p (concat exe-dir "lib" e ".a"))
          (setq p (concat exe-dir "lib" e ".a"))
        (if (file-exists-p (concat exe-dir "lib" e ".so"))
            (setq p (concat exe-dir "lib" e ".so"))
          (if (file-exists-p (concat exe-dir "lib" e ".dylib"))
              (setq p (concat exe-dir "lib" e ".dylib"))
            (setq p nil)
            ))))
    p
    ))

(defun cppcm-get-exe-dir-path-current-buffer ()
  (let (cm
        exe-path
        )
    (setq cm (concat (file-name-as-directory (file-name-directory buffer-file-name)) "CMakeLists.txt"))
    (setq exe-path (gethash (concat cm "exe-dir") cppcm-hash))
    exe-path
    )
  )

(defun cppcm-create-one-makefile (root-src-dir build-dir cm tgt mk)
  (let (flag-make
        cppflags
        exe-dir
        exe-full-path
        (executable (cadr tgt))
        ml
        is-c
        )
    (setq exe-dir (concat
                   (directory-file-name build-dir)
                   (cppcm-replace-once root-src-dir (file-name-directory cm))))
    (setq flag-make
          (concat
           exe-dir
           "CMakeFiles/"
           executable
           ".dir/flags.make"
           ))
    ;; try to guess the executable file full path
    (setq exe-full-path (cppcm-guess-exe-full-path exe-dir tgt))
    (puthash (concat cm "exe-dir") exe-dir cppcm-hash)
    (when exe-full-path
      (puthash (concat cm "exe-full-path") exe-full-path cppcm-hash)
      (when (and (file-exists-p flag-make)
              (setq ml (cppcm-query-match-line flag-make "\s*\\(CX\\{0,2\\}_FLAGS\\)\s*=\s*\\(.*\\)")))
        (setq is-c (if (string= (match-string 1 ml) "C_FLAGS") "C" "CXX"))
        (setq cppflags (cppcm-trim-cppflags (match-string 2 ml)))
        (puthash cm cppflags cppcm-hash)
        (with-temp-file mk
          (insert (concat "# Generated by " cppcm-prog ".\n"
                          "include " flag-make "\n"
                          ".PHONY: check-syntax\ncheck-syntax:\n\t${"
                          (if (string= is-c "C") "CC" "CXX")
                          "} -o /dev/null ${"
                          is-c
                          "_FLAGS} ${"
                          is-c
                          "_DEFINES} -S ${CHK_SOURCES}"
                          ))
          ))
      )
    )
  )

(defun cppcm-create-flymake-makefiles(root-src-dir src-dir build-dir)
  (let ((base src-dir)
        cm
        mk
        subdir
        possible-targets
        tgt
        e
        )
    ;; search all the subdirectory for CMakeLists.txt
    (setq cm (concat (file-name-as-directory src-dir) "CMakeLists.txt"))
    ;; open CMakeLists.txt and find
    (when (file-exists-p cm)
      (setq possible-targets (cppcm-query-targets cm))
      (dolist (tgt possible-targets)
        ;; if the target is ${VAR_NAME}, we need query CMakeLists.txt to find actual value
        ;; of the target
        (setq e (cadr tgt))
        (setq e (if (string= (substring e 0 2) "${") (cppcm-guess-var (substring e 2 -1) cm) e))
        (setcar (nthcdr 1 tgt) e)
        (setq mk (concat (file-name-as-directory src-dir) cppcm-makefile-name))
        (cppcm-create-one-makefile root-src-dir build-dir cm tgt mk)
        )
      )
    (dolist (f (directory-files base))
      (setq subdir (concat (file-name-as-directory base) f))
      (when (and (file-directory-p subdir)
                 (not (equal f ".."))
                 (not (equal f "."))
                 (not (equal f ".git"))
                 (not (equal f cppcm-build-dirname))
                 (not (equal f ".svn"))
                 (not (equal f ".hg"))
                 )
        (cppcm-create-flymake-makefiles root-src-dir subdir build-dir)
        )
      )
    )
  )

;;;###autoload
(defun cppcm-get-exe-path-current-buffer ()
  (interactive)
  (let (cm
        exe-path
        )
    (setq cm (concat (file-name-as-directory (file-name-directory buffer-file-name)) "CMakeLists.txt"))
    (setq exe-path (gethash (concat cm "exe-full-path") cppcm-hash))
    (if exe-path
        (progn
          (kill-new exe-path)
          (message "%s => clipboard" exe-path)
          )
      (message "executable missing! Please run 'M-x compile' at first.")
      )
    exe-path
    )
  )

(defun cppcm-set-cxxflags-current-buffer ()
  (interactive)
  (let (cm
        cxxflags
        )
    (setq cm (concat (file-name-as-directory (file-name-directory buffer-file-name)) "CMakeLists.txt"))
    (setq cxxflags (gethash cm cppcm-hash))
    (setq cppcm-include-dirs (if cxxflags (split-string cxxflags "\s+" t)))
    )
  )

;;;###autoload
(defun cppcm-create-or-update-flymake-files ()
  "Create flymake files used by flymake and data used by (cppcm-get-cppflags-in-current-buffer)"
  (interactive)
  (let (dirs
        sd
        bd
        )
    ;; (clrhash cppcm-hash) ; if we open a cmake and non-cmake project ...
    (if (cppcm-get-dirs)
        (progn
          (cppcm-create-flymake-makefiles cppcm-src-dir cppcm-src-dir cppcm-build-dir)
          (cppcm-set-cxxflags-current-buffer)
          )
      (message "Build directory is missing! Create the directory. Then run cmake and make in it.")
      )
    )
  )

;;;###autoload
(defun cppcm-compile ()
  "compile the executable/library in current directory"
  (interactive)
  (when (and cppcm-build-dir (file-exists-p (concat cppcm-build-dir "CMakeCache.txt")))
    (setq compile-command (concat "make -C " (cppcm-get-exe-dir-path-current-buffer))))
  (call-interactively 'compile)
  )

;;;###autoload
(defun cppcm-reload-all ()
  "re-create Makefiles for flymake and re-set all the flags"
  (interactive)
  (cppcm-create-or-update-flymake-files)
  (when cppcm-include-dirs
    (setq ac-clang-flags cppcm-include-dirs)
    )
  (when (and cppcm-build-dir (file-exists-p (concat cppcm-build-dir "CMakeCache.txt")))
    (setq compile-command (concat "make -C " cppcm-build-dir))
    )
  )

(provide 'cpputils-cmake)

;;; cpputils-cmake.el ends here

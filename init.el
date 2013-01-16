;; -*- coding: utf-8 -*-
(setq emacs-load-start-time (current-time))
(add-to-list 'load-path (expand-file-name "~/.emacs.d"))

;;----------------------------------------------------------------------------
;; Which functionality to enable (use t or nil for true and false)
;;----------------------------------------------------------------------------
(setq *spell-check-support-enabled* t)
(setq *macbook-pro-support-enabled* t)
(setq *is-a-mac* (eq system-type 'darwin))
(setq *is-carbon-emacs* (and *is-a-mac* (eq window-system 'mac)))
(setq *is-cocoa-emacs* (and *is-a-mac* (eq window-system 'ns)))
(setq *win32* (eq system-type 'windows-nt) )
(setq *cygwin* (eq system-type 'cygwin) )
(setq *linux* (or (eq system-type 'gnu/linux) (eq system-type 'linux)) )
(setq *unix* (or *linux* (eq system-type 'usg-unix-v) (eq system-type 'berkeley-unix)) )
(setq *linux-x* (and window-system *linux*) )
(setq *xemacs* (featurep 'xemacs) )
(setq *emacs23* (and (not *xemacs*) (or (>= emacs-major-version 23))) )

;----------------------------------------------------------------------------
; Functions (load all files in defuns-dir)
; Copied from https://github.com/magnars/.emacs.d/blob/master/init.el
;----------------------------------------------------------------------------
(setq defuns-dir (expand-file-name "~/.emacs.d/defuns"))
(dolist (file (directory-files defuns-dir t "\\w+"))
  (when (file-regular-p file)
      (load file)))
;----------------------------------------------------------------------------
; Load configs for specific features and modes
;----------------------------------------------------------------------------
(require 'init-modeline)

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------
(require 'init-compat)
(require 'init-utils)
(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el

;; win32 auto configuration, assuming that cygwin is installed at "c:/cygwin"
(if *win32*
	(progn
		(setq cygwin-mount-cygwin-bin-directory "c:/cygwin/bin")
		(require 'setup-cygwin)
		;(setenv "HOME" "c:/cygwin/home/someuser") ;; better to set HOME env in GUI
		))

(require 'init-elpa)
(require 'init-exec-path) ;; Set up $PATH
(require 'init-frame-hooks)
(require 'init-xterm)
(require 'init-osx-keys)
(require 'init-gui-frames)
(require 'init-maxframe)
(require 'init-proxies)
(require 'init-dired)
(require 'init-isearch)
(require 'init-uniquify)
(require 'init-ibuffer)
(require 'init-flymake)
(require 'init-artbollocks-mode)
(require 'init-recentf)
(require 'init-ido)
(require 'init-hippie-expand)
(require 'init-windows)
(require 'init-sessions)
(require 'init-fonts)
(require 'init-mmm)
;(require 'init-growl)
(require 'init-editing-utils)
(require 'init-git)
(require 'init-crontab)
(require 'init-textile)
(require 'init-markdown)
(require 'init-csv)
(require 'init-erlang)
(require 'init-javascript)
(require 'init-sh)
(require 'init-php)
(require 'init-org)
(require 'init-org-mime)
(require 'init-nxml)
(require 'init-css)
(require 'init-haml)
(require 'init-python-mode)
(require 'init-haskell)
(require 'init-ruby-mode)
(require 'init-rails)
;(require 'init-rcirc)

(require 'init-lisp)
(require 'init-slime)
(require 'init-clojure)
(require 'init-common-lisp)

(when *spell-check-support-enabled*
  (require 'init-spelling))

(require 'init-marmalade)

;; Finally set up themes, after most possibly-customised faces have been defined
(require 'init-themes) ; color-themes 6.6.1 has some problem
;; Chinese inut method
(require 'init-org2blog)
;; (require 'init-fill-column-indicator) ;make auto-complete dropdown wierd
(require 'init-yasnippet)
(require 'init-better-registers) ; C-x j - jump to register
(require 'init-zencoding-mode) ;behind init-better-register to override C-j
(require 'init-yari)
(require 'init-cc-mode)
(require 'init-auto-complete) ; after init-yasnippeta to override TAB
(require 'init-semantic)
(require 'init-cmake-mode)
(require 'init-csharp-mode)
(require 'init-linum-mode)
;(require 'init-delicious) ;make startup slow, I don't use delicious in w3m
(require 'init-emacs-w3m)
(require 'init-eim)
(require 'init-thing-edit)
(require 'init-which-func)
(require 'init-keyfreq)
(require 'init-gist)
(require 'init-emacspeak)
(require 'init-pomodoro)
(require 'init-undo-tree)
(require 'init-moz)
(require 'init-gtags)
;;(require 'init-evil) ; use evil mode (vi key binding)
(require 'init-misc)
(require 'init-ctags)
(require 'init-ace-jump-mode);;mind the file if you use evil,just 2 line above
(require 'init-multiple-cursors)
;; (require 'init-uml)
(require 'init-sunrise-commander)
(require 'init-bbdb)
(require 'init-gnus)
(require 'init-smarter-compile)
(require 'init-twittering-mode)
(require 'init-weibo)
;; itune cannot play flac, so I use mplayer+emms instead
(if *is-a-mac* (require 'init-emms))
(require 'init-lua-mode)
(require 'init-doxygen)

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
;; Don't use emacsclient, and this code make emacs start up slow
;;(defconst --batch-mode (member "--batch-mode" command-line-args)
;;          "True when running in batch-mode (--batch-mode command-line switch set).")
;;
;;(unless --batch-mode
;;  (require 'server)
;;  (when (and (= emacs-major-version 23)
;;             (= emacs-minor-version 1)
;;             (equal window-system 'w32))
;;    ;; Suppress error "directory ~/.emacs.d/server is unsafe" on Windows.
;;    (defun server-ensure-safe-dir (dir) "Noop" t))
;;  (condition-case nil
;;      (unless (server-running-p) (server-start))
;;    (remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)
;;    (error
;;     (let* ((server-dir (if server-use-tcp server-auth-dir server-socket-dir)))
;;       (when (and server-use-tcp
;;                  (not (file-accessible-directory-p server-dir)))
;;         (display-warning
;;          'server (format "Creating %S" server-dir) :warning)
;;         (make-directory server-dir t)
;;         (server-start))))))

;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(if (file-readable-p (expand-file-name "~/.emacs.d/custom.el"))
     (load-file (expand-file-name "~/.emacs.d/custom.el"))
       nil)

;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-local" containing personal settings
;;----------------------------------------------------------------------------
(require 'init-local nil t)


;;----------------------------------------------------------------------------
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
;(require 'init-locales) ;does not work in cygwin


(when (require 'time-date nil t)
   (message "Emacs startup time: %d seconds."
    (time-to-seconds (time-since emacs-load-start-time)))
   )

;;; Local Variables:
;;; no-byte-compile: t
;;; End:
(put 'scroll-left 'disabled nil)
;(setq mac-option-modifier 'ctrl);'hyper) ; sets the Option key as Hyper
;(setq mac-command-modifier 'meta) ;set the Command key as Meta
;(setq mac-option-modifier 'ctrl);'super) ; sets the Option key as Super
;(setq mac-control-modifier 'ctrl) ; sets the Control key as Meta
(global-set-key (kbd "ESC <down>") 'scroll-up)
(global-set-key (kbd "ESC <up>") 'scroll-down)
(global-set-key (kbd "ESC <right>") 'end-of-line)
(global-set-key (kbd "ESC <left>") 'beginning-of-line)
(setq-default make-backup-file nil )
;;echo "" |g++ -v -x c++ -E -
"
 /usr/llvm-gcc-4.2/bin/../lib/gcc/i686-apple-darwin11/4.2.1/include
 /usr/include/c++/4.2.1
 /usr/include/c++/4.2.1/backward
 /usr/local/include
 /Applications/Xcode.app/Contents/Developer/usr/llvm-gcc-4.2/lib/gcc/i686-apple-darwin11/4.2.1/include
 /usr/include
"
;;end sys include for c++
(setenv "GTAGSLIBPATH" (concat "/usr/local/include" ":" "/usr/include" ":" "/usr/include/c++/4.2.1" ":" "/usr/include/c++/4.2.1/backward" ":" "/usr/llvm-gcc-4.2/bin/../lib/gcc/i686-apple-darwin11/4.2.1/include" ":"  (getenv "GTAGSLIBPATH")))
(setq kill-whole-line t)

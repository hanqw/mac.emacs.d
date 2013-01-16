;;; evil-nerd-commenter-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (evilnc-default-hotkeys evilnc-comment-or-uncomment-lines
;;;;;;  evilnc-comment-or-uncomment-to-the-line) "evil-nerd-commenter"
;;;;;;  "evil-nerd-commenter.el" (20721 9516))
;;; Generated autoloads from evil-nerd-commenter.el

(autoload 'evilnc-comment-or-uncomment-to-the-line "evil-nerd-commenter" "\
Comment or uncomment from the current line to the LINENUM line

\(fn &optional LINENUM)" t nil)

(autoload 'evilnc-comment-or-uncomment-lines "evil-nerd-commenter" "\
Comment or uncomment lines.
   Case 1: If no region selected, comment/uncomment on current line. if NUM>1, comment/uncomment
   extra N-1 lines from next line
   Case 2: If a region selected, the region is expand to make sure the region contain
   whole lines. Then we comment/uncomment the expanded region. NUM is ignored.

\(fn &optional NUM)" t nil)

(autoload 'evilnc-default-hotkeys "evil-nerd-commenter" "\
Set the hotkeys of evil-nerd-comment

\(fn)" t nil)

;;;***

;;;### (autoloads nil nil ("evil-nerd-commenter-pkg.el") (20721 9516
;;;;;;  503492))

;;;***

(provide 'evil-nerd-commenter-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; evil-nerd-commenter-autoloads.el ends here

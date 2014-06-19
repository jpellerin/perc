;; -*- mode: lisp -*-

(defvar perc-command "perc test %s")
(defvar libdir "lib")
(defvar specdir "spec")
(defvar spec nil)

(defun perc-test(&optional file-name)
  "Runs all the tests in the current buffer"
  (interactive)
  (let* ((fn
          (if file-name
              file-name
            (relname buffer-file-name)))
         (command (format perc-command fn))
         (where (find-project-root)))
    (if (not where)
        (error "Could not find Makefile"))
    (compilation-start
     (concat "cd " where "; " command)
     nil
     (lambda (mode) (concat "*perc*"))))
  )

(defun perc-test-for-module()
  "Runs the spec module for this module"
  (interactive)
  (perc-test
   (if spec
       spec
     (replace-regexp-in-string
      (format "^%s/" libdir) (format "%s/" specdir)
      (replace-regexp-in-string
       ".\\(js\\|coffee\\)$" ".spec.\\1"
       (relname buffer-file-name)))))

)

(defun find-project-root(&optional dirname)
  (let ((dn
         (if dirname
             dirname
           (file-name-directory buffer-file-name))))
    (cond ((project-root dn) (expand-file-name dn))
          ((equal (expand-file-name dn) "/") nil)
          (t (find-project-root (file-name-directory (directory-file-name dn)))))))

(defun project-root(dirname)
  (member "package.json" (directory-files dirname))
)

(defun relname(filename)
  (file-relative-name buffer-file-name (find-project-root))
)

(require 'ansi-color)
(defun fix-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\(◦.*?\\)\\(✓\\|[0-9]+)\\)" nil t)
      (replace-match "\\2") )
    (goto-char (point-min))
    (while (re-search-forward "\\(\\[[0-9]+[a-zA-Z]\\)" nil t) 
      (replace-match "")))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'fix-compilation-buffer)

(add-to-list 'compilation-error-regexp-alist 'perc)
(add-to-list 'compilation-error-regexp-alist-alist
             '(perc "(\\([^:\)]+\\):\\([0-9]+\\):\\([0-9]+\\)" 1 2 3))

;; FIXME
;; at /home/jpellerin/code/gitboxer/gitboxer/boxes/frontend/lib/models/sandbox.coffee:48:43, <js>:78:15

(provide 'perc)

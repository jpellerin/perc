(require 'perc)
(setq perc-command "~/npm/bin/perc test %s")
(add-hook 'js-mode-hook
           (lambda()
             (local-set-key "\C-cM" 'perc-test)
             (local-set-key "\C-cs" 'perc-test-for-module)
))

(require 'coffee)
(require 'flymake-coffee)
(add-hook 'coffee-mode-hook 'flymake-coffee-load)
(add-hook 'coffee-mode-hook
          (lambda()

            ;; CoffeeScript uses two spaces.
            (make-local-variable 'tab-width)
            (set 'tab-width 2)

            (setq coffee-js-mode 'javascript-mode)
            (setq coffee-args-compile '("-c" "--bare"))
            (setq coffee-debug-mode t)
            (setq coffee-command "~/code/coffee-script/bin/coffee")

            (local-set-key "\M-r" 'coffee-compile-file)
            (local-set-key "\C-cM" 'perc-test)
            (local-set-key "\C-cs" 'perc-test-for-module)))

(add-to-list 'auto-mode-alist '("\\.coffee\\'" . coffee-mode))

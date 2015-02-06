(evil-leader/set-key
  "C" 'crito/coffee-compile-region-or-buffer)

(defun crito/coffee-compile-region-or-buffer
  "Compile either a region or buffer of coffee-script into JavaScript."
  (interactive
   (if (use-region-p)
       (coffee-compile-region (region-beginning) (region-end))
     (coffee-compile-buffer))))

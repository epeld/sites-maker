
(defpackage :peldan.string
  (:use :common-lisp)
  (:import-from :alexandria :with-gensyms)
  (:export :strings-bind :string-bind-case :string-var-match :split-by))


(in-package :peldan.string)


(defun split-by (string &optional (char #\Space))
    "Returns a list of substrings of string
divided by ONE space each.
Note: Two consecutive spaces will be seen as
if there were an empty string between them."
    (setq string (string-trim "/" string))
    (loop for i = 0 then (1+ j)
       as j = (position char string :start i)
       collect (subseq string i j)
       while j))

(defvar *error-on-mismatch* nil)

(defun string-var-match (strings-and-vars strings)
  (loop 
     for var in strings-and-vars
     for string in strings
	  
     with filled = (acons '&whole strings nil)
     do (progn (check-type var (or string symbol))
	       (cond ((and (stringp var) 
			   (string= var string))
		      t)
		
		     ((symbolp var)
		      (setq filled (acons var string filled)))
		
		     (t
		      (if *error-on-mismatch* 
			  (error "Mismatch: ~s (~a) ~s (~a)" var (type-of var) string (type-of string))
			  (return nil)))))
	  
	  finally (return filled)))


(defun transpose (list-of-lists)
  (apply #'mapcar #'list list-of-lists))


(defmacro strings-bind (vars-and-strings strings &body body)
  ;; Special case: empty list or otherwise treated as simple match
  (when (or (null vars-and-strings) (eql vars-and-strings 'otherwise))
    (return-from strings-bind
      `(progn ,@body)))
  
  (alexandria:with-gensyms (match)
    (let ((vars (remove-if #'stringp vars-and-strings)))
      `(let ((,match (string-var-match ',vars-and-strings ,strings)))
	   (when ,match
	     (let (,@(transpose (list vars 
					(mapcar (lambda (var)
						  `(cdr (assoc ',var ,match)))
						vars))))
		 ,@body))))))


(defmacro string-bind-case (string &rest forms)
  (with-gensyms (split block-name)
    `(block ,block-name
       (let ((,split (split-by ,string #\/)))
	 (progn ,@(loop for form in forms
		     collect (destructuring-bind (vars-and-strings &rest body) form
			       `(strings-bind ,vars-and-strings ,split (return-from ,block-name (progn ,@body))))))))))


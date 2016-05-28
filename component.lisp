
(defpackage :peldan.component
  (:use :common-lisp)
  (:import-from :cl-who 
		:with-html-output
		:with-html-output-to-string)
  (:import-from :alexandria 
		:with-gensyms))

(in-package :peldan.component)


(defun add-parameter (lambda-list name)
  (append lambda-list (list name)))


(defmacro defcomponent (name lambda html)
  (with-gensyms (stream args)
    `(defun ,name ,(add-parameter lambda stream)
       (the stream ,stream)
       (labels ((component (fn &rest ,args)
		  (apply fn (add-parameter ,args ,stream))))
	 (with-html-output (,stream)
	   ,html)))))


(defmacro render (component &rest args)
  (with-gensyms (var)
    `(with-html-output-to-string (,var)
       (,component ,@args ,var))))


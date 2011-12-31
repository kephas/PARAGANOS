(defpackage :thierry-technologies.com/2011/12/paraganos-system
  (:use :cl :asdf))

(in-package :thierry-technologies.com/2011/12/paraganos-system)

(defsystem "paraganos"
  :version ""
  :depends-on ("lisp-unit" "closer-mop" "cl-utilities")
  :serial t
  :components ((:file "package")
	       (:file "macros")
	       (:file "types")
	       (:file "points")))

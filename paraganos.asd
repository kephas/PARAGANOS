(defpackage :thierry-technologies.com/2011/12/paraganos-system
  (:use :cl :asdf))

(in-package :thierry-technologies.com/2011/12/paraganos-system)

(defsystem "paraganos"
  :version ""
  :depends-on ("lisp-unit" "closer-mop" "cl-utilities" "my-macros")
  :serial t
  :components ((:file "package")
	       (:file "types")
	       (:file "points")))

(in-package :thierry-technologies.com/2011/12/paraganos)

(defmacro cif (var form then &optional else)
  `(let ((,var ,form))
     (if ,var ,then ,else)))

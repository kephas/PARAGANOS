(in-package :thierry-technologies.com/2011/12/paraganos)

(define-test typing
  (assert-true (compatible-types? 'integer 'number))
  (assert-true (compatible-types? '(seq 'integer) '(vector 'number)))
  (assert-false (compatible-types? 'integer 'string))
  (assert-false (compatible-types? '(seq 'integer) 'number))
  (assert-false (compatible-types? '(list (seq 'integer)) '(container number))))

(defun compatible-types? (from to)
  (if (and (listp from) (listp to))
      (compatible-types? (second from) (second to))
      (if (or (listp from) (listp to))
	  nil
	  (subtypep from to))))


(defgeneric src-type (source)
  (:documentation "Return the type of a datum that can be extracted or injected in this
source"))

(defun compatible-sources? (from to)
  (compatible-types? (src-type from) (src-type to)))

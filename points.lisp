(in-package :thierry-technologies.com/2011/12/paraganos)

(define-test source-definition-c18n
  (assert-equal '(foo bar (from foo) baz quux) (canonical-source-definition '(foo bar baz quux)))
  (assert-equal '(foo bar baz (from foo) quux) (canonical-source-definition '(foo bar baz (from foo) quux))))

(defun canonical-source-definition (definition)
  (destructuring-bind (name type &rest tags) definition
    (cons name (cons type (remove-duplicates (cons `(from ,name) tags) :test #'equal)))))


(defgeneric allocate (from to datum &rest rest))

(defun copy-slots (from to)
  (labels ((rec (slots-names)
	     (when slots-names
	       (let ((slot-name (first slots-names)))
		 (setf (slot-value to slot-name)
		       (slot-value from slot-name))
		 (rec (rest slots-names))))))
    (rec (mapcar #'slot-definition-name (class-slots (class-of from))))))

(defun apply-allocation (object from-name to-name)
  (let ((new-object (make-instance (class-of object))))
    (multiple-value-bind (new-from new-to)
	(allocate (slot-value object from-name) (slot-value object to-name))
      (copy-slots object new-object)
      (setf (slot-value new-object from-name) new-from
	    (slot-value new-object to-name) new-to))))

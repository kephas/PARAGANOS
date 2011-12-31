(in-package :thierry-technologies.com/2011/12/paraganos)

(define-test source-definition-c18n
  (assert-equal '(foo bar (from foo) baz quux) (canonical-source-definition '(foo bar baz quux)))
  (assert-equal '(foo bar baz (from foo) quux) (canonical-source-definition '(foo bar baz (from foo) quux))))

(defun canonical-source-definition (definition)
  (destructuring-bind (name type &rest tags) definition
    (cons name (cons type (remove-duplicates (cons `(from ,name) tags) :test #'equal)))))

#|

Core of the mechanism for points allocation

|#

(defgeneric extract (from datum)
  (:documentation "Try to extract /datum/ from /from/ source.

If extraction succeeds, return three values: 1) the resulting source,
2) the extracted data and 3) /nil/ (or no value).

If extraction fails, return three values: 1) the unchanged /from/
source, 2) an unspecified value (e.g. could be /datum/ or /nil/) and
3) /t/ (to indicate a problem occurred."))

(defgeneric inject (to datum)
  (:documentation "Try to inject /datum/ in /to/ source.

If injection succeeds, return two values: 1) the resulting source and
2) /nil/ (or no value).

If injection fails, return two values: 1) the unchanged /to/ source
and 2) /t/ (to indicate a problem occurred)."))


#|

Convenience macros to deal with extraction and injection protocols

|#

(defmacro with-extraction ((new-from-var extract-var from-var datum-var) &body body)
  (with-gensyms (problem?-var)
    `(multiple-value-bind (,new-from-var ,extract-var ,problem?-var)
	 (extract ,from-var ,datum-var)
       (if ,problem?-var
	   ,@body))))

(defmacro with-injection ((new-to-var to-var datum-var) &body body)
  (with-gensyms (problem?-var)
    `(multiple-value-bind (,new-to-var ,problem?-var)
	 (inject ,to-var ,datum-var)
       (if ,problem?-var
	   ,@body))))

#|

Concrete point allocation between two sources

|#

(defun allocate (from to datum)
  (labels ((abort! () (values from to)))
    (if (compatible-sources? from to)
	(with-extraction (new-from extract from datum)
	  (abort!)
	  (with-injection (new-to to extract)
	    (abort!)
	    (values new-from new-to)))
	(abort!))))

#|

Default extraction/injection methods just fail

|#

(defmethod extract (from datum)
  (values from nil t))

(defmethod inject (to datum)
  (values to t))
#|

Allocation for built-in types

|#

(defmethod extract ((from number) (datum number))
  (if (> datum from)
      (values from nil t)
      (values (- from datum) datum)))

(defmethod inject ((from number) (datum number))
  (+ from datum))


(defmethod extract ((from list) datum)
  (cif found (find datum from :test #'eql)
       (values (remove found from :test #'eql) found)
       (values from nil t)))

(defmethod inject ((to list) datum)
  (cons datum to))

#|

Source delegate

|#

(defclass source ()
  ((delegate :initarg :src :reader src-delegate))
  (:documentation "Container used to provide EQ-comparable identity to sources like numbers"))

(defmethod extract ((from source) datum)
  (with-extraction (new-delegate extract (src-delegate from) datum)
    (values from nil t)
    (values (make-instance 'source :src new-delegate) extract)))

(defmethod inject ((to source) datum)
  (with-injection (new-delegate (src-delegate to) datum)
    (values to t)
    (make-instance 'source :src new-delegate)))

#|

Allocation application to an object including sources

|#

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

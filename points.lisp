(in-package :thierry-technologies.com/2011/12/paraganos)

(define-test source-definition-c18n
  (assert-equal '(foo bar (from foo) baz quux) (canonical-source-definition '(foo bar baz quux)))
  (assert-equal '(foo bar baz (from foo) quux) (canonical-source-definition '(foo bar baz (from foo) quux))))

(defun canonical-source-definition (definition)
  (destructuring-bind (name type &rest tags) definition
    (cons name (cons type (remove-duplicates (cons `(from ,name) tags) :test #'equal)))))

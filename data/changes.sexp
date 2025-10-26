(:changes
 (:release "0.12" nil
  (:item
   (:paragraph
    "The" "deprecated" "generic" "functions"
    (:symbol "eclector.reader:call-with-current-package")
    "has" "been" "removed" "." "Clients" "should" "use"
    (:symbol "eclector.base:call-with-state-value") "with" "the"
    (:symbol "cl:*package*") "aspect" ".")))

 (:release "0.11" "2025-06-08"
  (:item
   (:paragraph
    "Major" "incompatible" "change")
   (:paragraph
    "A" (:tt "children") "parameter" "has" "been" "added" "to" "the" "lambda"
    "list" "of" "the" "generic" "function"
    (:symbol "eclector.parse-result:make-skipped-input-result") "so" "that"
    "results" "which" "represent" "skipped" "material" "can" "have" "children"
    "." "For" "example" "," "before" "this" "change" "," "a"
    (:symbol "eclector.parse-result:read") "call" "which" "encountered" "the"
    "expression" (:tt "#+no-such-feature foo bar") "potentially" "constructed"
    "parse" "results" "for" "all" "(" "recursive" ")" (:symbol "read") "calls"
    "," "that" "is" "for" "the" "whole" "expression" "," "for"
    (:tt "no-such-feature") "," "for" (:tt "foo") "and" "for" (:tt "bar") ","
    "but" "the" "parse" "results" "for" (:tt "no-such-feature") "and"
    (:tt "foo") "could" "not" "be" "attached" "to" "a" "parent" "parse"
    "result" "and" "were" "thus" "lost" "." "In" "other" "words" "the" "shape"
    "of" "the" "parse" "result" "tree" "was")
   (:code nil "skipped input result #+no-such-feature foo
expression result    bar")
   (:paragraph
    "With" "this" "change" "," "the" "parse" "results" "in" "question" "can"
    "be" "attached" "to" "the" "parse" "result" "which" "represents" "the"
    "whole" (:tt "#+no-such-feature foo") "expression" "so" "that" "the"
    "entire" "parse" "result" "tree" "has" "the" "following" "shape")
   (:code nil "skipped input result #+no-such-feature foo
  skipped input result no-such-feature
  skipped input result foo
expression result    bar")
   (:paragraph
    "Since" "this" "is" "a" "major" "incompatible" "change" "," "we" "offer"
    "the" "following" "workaround" "for" "clients" "that" "must" "support"
    "Eclector" "versions" "with" "and" "without" "this" "change" ":")
   (:code :common-lisp "(eval-when (:compile-toplevel :load-toplevel :execute)
  (let* ((generic-function #'eclector.parse-result:make-skipped-input-result)
         (lambda-list      (c2mop:generic-function-lambda-list
                            generic-function)))
    (when (= (length lambda-list) 5)
      (pushnew 'skipped-input-children *features*))))
(defmethod eclector.parse-result:make-skipped-input-result
    ((client client)
     (stream t)
     (reason t)
     #+PACKAGE-THIS-CODE-IS-READ-IN::skipped-input-children (children t)
     (source t))
  ...
  #+PACKAGE-THIS-CODE-IS-READ-IN::skipped-input-children (use children)
  ...)")
   (:paragraph
    "The" "above" "code" "pushes" "a" "symbol" "that" "is" "interned" "in" "a"
    "package" "under" "the" "control" "of" "the" "respective" "client" "(" "as"
    "opposed" "to" "the" (:tt "KEYWORD") "package" ")" "onto"
    (:symbol "*features*") "before" "the" "second" "form" "is" "read" "and"
    "uses" "that" "feature" "to" "select" "either" "the" "version" "with" "or"
    "the" "version" "without" "the" (:tt "children") "parameter" "of" "the"
    "method" "definition" "." "See" "Maintaining" "Portable" "Lisp" "Programs"
    "by" "Christophe" "Rhodes" "for" "a" "detailed" "discussion" "of" "this"
    "technique" ".")))

(:release "0.1" nil
 (:item
  (:paragraph
   "Initial" "version"))))

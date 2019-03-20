#lang htdp/isl+

(define-struct db [schema content])
; A DB is a structure: (make-db Schema Content)
 
; A Schema    is a [List-of Spec]
; Spec is a structure: (make-spec Label Predicate)
(define-struct spec [label predicate])
; A Label     is a String
; A Predicate is a [Any -> Boolean]
 
; A (piece of) Content is a [List-of Row]
; A Row is a [List-of Cell]
; A Cell is Any
; constraint cells do not contain functions 
 
; integrity constraint In (make-db sch con), 
; for every row in con,
; (I1) its length is the same as sch's, and
; (I2) its ith Cell satisfies the ith Predicate in sch

#|
+------------------------------+
| Name    |  Age    |  Present |
|---------+---------+----------|
| String  | Integer |  Boolean |
|---------+---------+----------|
| "Alica" |  35     |  #true   |
| "Bob"   |  25     |  #false  |
| "Carol" |  30     |  #true   |
| "Dave"  |  32     |  #false  |
+------------------------------+

+-------------------+
| Name    | String  |
|---------+---------+
| String  | Boolean |
|---------+---------|
| "Alice" | #true   |
| "Bob"   | #false  |
| "Carol" | #true   |
| "Dave"  | #false  |
+-------------------+
|#

;; DB [List-of Label] -> DB
;; retains a column from db if its label is in labels
#;(define (project db labels) (make-db '() '()))

(define school-schema
  `(,(make-spec "Name"    string?)
    ,(make-spec "Age"     integer?)
    ,(make-spec "Present" boolean?)))
 
 
(define school-content
  `(("Alice" 35 #true)
    ("Bob"   25 #false)
    ("Carol" 30 #true)
    ("Dave"  32 #false)))

 
(define school-db
  (make-db school-schema
           school-content))

(define projected-content
  `(("Alice" #true)
    ("Bob"   #false)
    ("Carol" #true)
    ("Dave"  #false)))
 
(define projected-schema
  `(("Name" ,string?) ("Present" ,boolean?)))
 
(define projected-db
  (make-db projected-schema projected-content))

;; --------------------------------------------------

;  Stop! Read this test carefully. What's wrong?
#;
(check-expect (project school-db '("Name" "Present"))
              projected-db)

#;
(define (project db labels)
  (local ((define schema  (db-schema db))
          (define content (db-content db))
          ; Spec -> Boolean
          ; does this spec belong to the new schema
          (define (keep? c) ...))
    ; Row -> Row
    ; retains those columns whose name is in labels
    (define (row-project row) ...)
    (make-db (filter keep? schema)
             (map row-project content))))


;; can't compare functions
;; weakening the test case

(check-expect
 (db-content (project school-db '("Name" "Present")))
 projected-content)


#;; this is clearly called for:
(local ((define schema (db-schema db))
        (define content (db-content db)))
  (make-db ... schema ...
           ... content ...))

(define (project db labels)
  (local ((define schema  (db-schema db))
          (define content (db-content db))
          ;; hoisting  previous labels
          (define orig-labels (map spec-label schema))

          ; Spec -> Boolean
          ; does this column belong to the new schema
          (define (keep? c)
            (member? (spec-label c) labels))
 
          ; Row -> Row
          ; retains those columns whose name is in labels
          (define (row-project row)
            (row-filter row orig-labels))
 
          ; Row [List-of Label] -> Row
          ; retains those cells whose name is in labels
          (define (row-filter row names)
            (foldr (λ (r n result)
                     (if (member? n labels)
                         (cons r result)
                         result))
                   '()
                   row
                   names)))
    (make-db (filter keep? schema)
             (map row-project content))))
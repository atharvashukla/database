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
+--------------------------------+
|Name     |  Age      |  Present |
|---------+-----------+----------|
|String   |  Integer  |  Boolean |
|---------+-----------+----------|
|"Alice"  |  35       |  #true   |
|"Bob"    |  25       |  #false  |
|"Carol"  |  30       |  #true   |
|"Dave"   |  32       |  #false  |
+--------------------------------+

+-----------------------+
|Present  |  Description|
|---------+-------------|
|Boolean  |  String     |
|---------+-------------|
|  #true  |  "presence" |
|  #false |  "absence"  |
+-----------------------+
|#

(define school-schema
  `(,(make-spec "Name"    string?)
    ,(make-spec "Age"     integer?)
    ,(make-spec "Present" boolean?)))
 
(define presence-schema
  `(,(make-spec "Present"     boolean?)
    ,(make-spec "Description" string?)))
 
(define school-content
  `(("Alice" 35 #true)
    ("Bob"   25 #false)
    ("Carol" 30 #true)
    ("Dave"  32 #false)))
 
(define presence-content
  `((#true  "presence")
    (#false "absence")))
 
(define school-db
  (make-db school-schema
           school-content))
 
(define presence-db
  (make-db presence-schema
           presence-content))

(define bad-schema
  `(,(make-spec "Song" string?)
    ,(make-spec "Duration" boolean?))) ; <-

(define bad-db (make-db bad-schema presence-content))

;; --------------------------------------------------


; DB -> Boolean
; do all rows in db satisfy (I1) and (I2)
 
(check-expect (integrity-check school-db) #true)
(check-expect (integrity-check presence-db) #true)
(check-expect (integrity-check bad-db) #false)

;; checks for integrity constraint requirements
;; for every row in  the database, ie.
;; (I1) its length is the same as sch's, and
;; (I2) its ith Cell satisfies the ith Predicate in sch
(define (integrity-check db)
  (local ((define schema  (db-schema db)) ;; Expression Hoisting
          (define content (db-content db))
          (define width   (length schema))
          ;; Row -> Boolean
          ;; does row satisfy (I1) and (I2)
          (define (row-integrity-check row)
            (and (= (length  row) width)
                 (andmap (lambda (s c) [(spec-predicate s) c])
                         schema
                         row))))
    (andmap row-integrity-check (db-content db))))
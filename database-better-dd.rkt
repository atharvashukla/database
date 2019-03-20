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



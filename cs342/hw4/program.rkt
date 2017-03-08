#lang racket
(provide (all-defined-out))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Assignment Provided ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; (synchk prov0) returns false (explanation for 1a)
;; f is applied but there is not enclosing fun f
(define prov0
    '(fun ((f1 (x)) ((gt x 0)
	(* x (apply (f ((- x 1)))))
	1))
    (apply (f1 (x))
)))

;; (synchk prov1) returns false (explanation for 1b)
;; f1 is applied with incorrect number of actual arguments
(define prov1
    '(fun ((f1 (x)) ((gt x 0)
	(* x (apply (f1 ((- x 1)))))
	1))
    (apply (f1 ())
)))

;; (eval prov2 ’((x 3))) returns 6
;; (eval prov2 ’((x 4))) returns 24
(define prov2
    '(fun ((f1 (x)) ((gt x 0)
	(* x (apply (f1 ((- x 1)))))
	1))
    (apply (f1 (x))
)))

;;;;;;;;;;;;;;
;; Programs ;;
;;;;;;;;;;;;;;

;; VALID
;; Returns pi.
;; Results in 4.14159265
(define prog0
    '(fun ((pi ()) 3.14159265) 
	(apply (pi ())
)))

;; VALID
;; Adds one to pi.
;; Results in 4.14159265
(define prog1
    '(fun ((pi ()) 3.14159265) 
	(+ 1 (apply (pi ()))
)))

;; INVALID
;; Tries to add one to pi.
;; But pi is undefined, invalid.
(define prog2
    '(+ 1 (apply (pi ())))
)

;; VALID
;; Adds two, then adds one to z,
;; where z must be provided by the input environment.
;; (eval prog3 '((z 2))) returns 5
(define prog3
    '(fun ((addone (x)) (+ x 1))
	(fun ((addtwo (y)) (+ y 2))
	    (apply (addone (
		(apply (addtwo (z)))
	    )
)))))

;; INVALID
;; Tries to call an undefined 'addthree' function
(define prog4
    '(fun ((addone (x)) (+ x 1))
	(fun ((addtwo (y)) (+ y 2))
	    (apply (addone (
		(apply (addthree (z)))
	    )
)))))

;; VALID
;; Program -> Expr -> Number
(define prog5 525600)

;; VALID
;; Program -> Expr -> Variable
(define prog6 'x)

;; INVALID
;; Similar to prog1, but swapped the ordering of the operands.
(define prog7
    '(+ (apply (pi ())) 1)
)

;; INVALID
;; pi is not defined
(define prog8
    '((not (gt (apply (pi ())) 1))
	1
	0
))

;; VALID
;; same as prog8, but pi is defined
;; evaluates to 0, as !(pi > 1) evaluates to FALSE
(define prog9
    '(fun ((pi ()) 3.14159265) 
	((not (gt (apply (pi ())) 1))
	    1
	    0
)))

;; INVALID
;; Variable assignment expression uses undefined function.
(define prog10
    '(var
	((x (apply (pi ()))))
	(* 2 x)
))

;; INVALID
;; Variable assignment expression is fine now,
;; but proceeding expression is invalid.
(define prog11
    '(var
	((x 2))
	(* x (apply (pi ())))
))

;; VALID
;; Calls function pi to assign pi to x,
;; then returns 2 * PI = 6.2831853
(define prog12
    '(fun ((pi ()) 3.14159265) 
	(var
	    ((x (apply (pi ()))))
	    (* 2 x)
)))

;;;;;;;;;;;;;;;;;;
;; FormalParams ;;
;;;;;;;;;;;;;;;;;;

;; True
(define formalparams0
    '()
)

;; True
(define formalparams1
    '(x y z)
)

;; False
(define formalparams2
    '(x y 3)
)

;; False
(define formalparams3
    '((a b c))
)

;;;;;;;;;;;;;
;; FAssign ;;
;;;;;;;;;;;;;

;; True
;; Returns 1 if x > y, 0 otherwise.
(define fassign0 '(
    (myfunc (x y)) ((gt x y) 1 0)
))

;; True
;; Returns the constant pi.
(define fassign1
    '((pi ()) 3.14159265)
)

;; True
;; Always returns 0, but takes a couple arguments that do nothing.
(define fassign2
    '((myfunc (a b c d e f g h i j k l m n o p q r s t u v w x y z)) 0)
)

;; False
;; fname and formalparams should be together in their own list.
(define fassign3
    '(myfunc (a b c) 0)
)

;; False
;; Invalid formal parameters.
(define fassign4
    '((myfunc (1 2 3)) 0)
)

;; False
;; No corresponding expression.
(define fassign5
    '((myfunc (a b c)))
)

;; False
;; Missing formal parameters.
(define fassign6
    '((myfunc) 0)
)

;; False
;; A list is not a valid function name.
(define fassign7
    '((() ()) 0)
)

;;;;;;;;;;;
;; FExpr ;;
;;;;;;;;;;;

;; True
(define fexpr0
    (list 'fun fassign0 0)
)

;; True
(define fexpr1
    (list 'fun fassign2 1)
)

;; True
(define fexpr2
    ;; Evaluates pi via the pi function.
    (list 'fun fassign1 
	(list 'apply (list 'pi '()))
))

;; True
;; Evaluates to 100 by both adding and subtracting 2 from 100.
(define fexpr3 
    '(fun ((addtwo (x)) (+ x 2))
	(fun ((subtwo (y)) (- y 2))
	    (apply (subtwo (
		(apply (addtwo (100)))
	    )
)))))

;; False
;; fassign5 is invalid
(define fexpr4
    (list 'fun fassign5 0)
)

;; False
;; boring is not an identifier
(define fexpr5
    (list 'boring fassign2 1)
)

;; False
;; Too many items in list
(define fexpr6
    (list 'fun fassign2 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
)

;;;;;;;;;;
;; Args ;;
;;;;;;;;;;

;; True
(define args0
   '()
)

;; True
(define args1
   '(3 2 3 4)
)

;; True
(define args2
   '((+ x (* y z)) (+ 3 4))
)

;; False 
;; Variable assignment needs evaluation expression.
(define args3
   '((var (x)))
)

;; False
;; Conditional 'not' only takes one argument.
(define args4 '(
    (+ 3 4) 
    ((not 3 2) 1 0)
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ApplyF                              ;;
;; (assumes all functions are defined) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; True
(define applyf0
    (list 'apply (list 'myfunc args0))
)

;; False
;; A list is not a valid function name.
(define applyf1
    '(apply ((3) '()))
)

;; True
(define applyf2
    (list 'apply (list 'myfunc args1))
)

;; False
;; args4 is not a valid argument list
(define applyf3
    (list 'apply (list 'myfunc args4))
)

;; False
;; Racket is case sensitive, so I assume
;; our language should be as well.
(define applyf4
    (list 'Apply (list 'myfunc args0))
)

;; False
;; Either way this should  not work.
(define applyf5
    '(execute (order '(66)))
)

;; True
(define applyf6
    (list 'apply (list 'myfunc args2))
)

;; False
;; Duh
(define applyf7
    '()
)

;; False
;; Duh
(define applyf8
    '(apply)
)

;; False
;; Duh
(define applyf9
    '(apply (myfunc))
)

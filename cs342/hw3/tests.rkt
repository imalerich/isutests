#lang racket
(provide (all-defined-out))

;;;;;;;;;;;;;;;;;;;;;;;
;; Provided Programs ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; True
(define prog2
  '(var ((x z) (y (+ x 1)))
	(+ x y)
))

(define prog3
  '(var ((x z) (y (+ x 1)))
	(+ x y) addinggarbage
))

;; Sample Run: Returns 21
;; (eval prog2 '((z 10)))

;; Sample Run: Returns '(Cannot Evaluate)
;; (eval prog2 '()))

;;;;;;;;;;;;;;
;; Evaluate ;;
;;;;;;;;;;;;;;

;; Environment we will use for testing.
(define env '(
    (x 3) (y 4) (z 5)
))

;; Some simple test programs.
(define eval0 '(+ 3 4))

(define eval1 '(+ x y))

(define eval2 '(+ z 1))

(define eval3 '(var ((z 3)) (+ z x)))

;; Invalid var assignment, 
;; but the variable isn't actually used anywhere
;; if do_not_define is not defined, should 
;; return '(Cannot Evaluate).
(define eval4 '(var ((z do_not_define)) 3))

;; Should return 0.
(define eval5 '(var ((x 3)) ((gt x 4) 1 0)))

;; Same as before, but x must be defined 
;; as an input parameter.
;; If x > 3 return 1, else return 0.
(define eval6 '((gt x 3) 1 0))

;; A little simpler test with no variables.
;; Should return 1.
(define eval7 '((gt 3 2) 1 0))

;; (x + y) / (3 * z)
(define eval8 '(
    / (+ x y) (* 3 z)
))

;; Should return '(Cannot Evaluate)
;; as even though garbage is not executed
;; it is still an invalid program.
(define eval9 '(
    (gt 3 2) 0 garbage
))

;; '(Cannot Evaluate)
;; Variable assignment expressions should not be empty.
(define eval10 '(
    var () 3
))

;;;;;;;;;;;
;; CCond ;;
;;;;;;;;;;;

;; All tests of the form bcondX
;; should also pass the ccond? test.
;; As an example (ccond? bcond0) -> True.

;; True
(define ccond0 '(or (gt 3 3) (lt 4 5)))

;; True
(define ccond1 (list 'and ccond0 '(lt 4 5)))

;; True
(define ccond2 (list 'not ccond1))

;; True
(define ccond3 (list 'and ccond2 (list 'or ccond2 (list 'not ccond0))))

;; False
(define ccond4 (list 'and '3 '4))

;; False (only takes one ccond argument)
(define ccond5 (list 'not ccond1 ccond2))

;; False (requires two ccond arguments)
(define ccond6 (list 'and '(lt 3 4)))

;; False (ccond0 is a constant, not a reference)
(define ccond7 '(and ccond0))

;;;;;;;;;;;;;;;;
;; BinaryCond ;;
;;;;;;;;;;;;;;;;

;; True
(define bcond0 '(gt 3 3))

;; True
(define bcond1 '(lt 4 5))

;; True
(define bcond2 '(eq (var ((x 3)) x) 3))

;; False
(define bcond3 '(gt 3 4 3))

;; False
(define bcond4 '(greaterthan 3 4 3))

;; False
(define bcond5 '(gteq 3 4 3))

;;;;;;;;;;;;;;;
;; Variables ;;
;;;;;;;;;;;;;;;

;; True
(define var0 'x)

;; False
(define var1 '(x))

;; False
(define var2 '(3))

;;;;;;;;;;;;;;;
;; Operators ;;
;;;;;;;;;;;;;;;

;; True
(define op0 '+)

;; True
(define op1 '-)

;; True
(define op2 '*)

;; True
(define op3 '/)

;; False
(define op4 '(*))

;; False
(define op5 '(/))

;; False
(define op6 'x)

;;;;;;;;;;;;;;;
;; ArithExpr ;;
;;;;;;;;;;;;;;;

;; True
(define ae0 '(+ 3 2))

;; True
(define ae1 '(- x y))

;; True
(define ae2 '(* 3 z))

;; True
(define ae3 '(/ y x))

;; True
(define ae4 '(/ (+ 2 (* 6 4)) x))

;; False (needs one more argument)
(define ae5 '(/ 2))

;; False (needs one less argument)
(define ae6 '(/ 2 3 4))

;;;;;;;;;;;;;;;
;; VarAssign ;;
;;;;;;;;;;;;;;;

;; True
(define varassignseq0
  '((x 3) (y 2) (z 6))
)

;; True
(define varassignseq1
  '((x 3))
)

;; False
;; VarAssignSeq must have at least
;; one (Variable Expr) within according
;; to the specification.
(define varassignseq2
  '()
)

;; False
(define varassignseq3
  '((x 3 2))
)

;; False
(define varassignseq4
  '((x 3) 4)
)

;;;;;;;;;;;;;;;
;; CCondExpr ;;
;;;;;;;;;;;;;;;

;; True
(define ccondexpr0
    (list ccond0 3 4)
)

;; True
(define ccondexpr1
    (list ccond1 3 4)
)

;; True
(define ccondexpr2
    (list ccond2 3 4)
)

;; True
(define ccondexpr3
    (list ccond3 3 4)
)

;; True
(define ccondexpr4
    (list bcond0 3 4)
)

;; True
(define ccondexpr5
    (list bcond1 3 4)
)

;; False (need one less expr)
(define ccondexpr6
    (list ccond3 3 4 6)
)

;; False (need one more expr)
(define ccondexpr7
    (list ccond3 3)
)

;; False (ccond6 is not a CCond)
(define ccondexpr8
    (list ccond6 3 4)
)

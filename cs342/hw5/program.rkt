#lang racket
(require "<netid>.rkt")
(require rackunit)

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
(check-equal? (synchk prov0) false)

;; (synchk prov1) returns false (explanation for 1b)
;; f1 is applied with incorrect number of actual arguments
(define prov1
    '(fun ((f1 (x)) ((gt x 0)
	(* x (apply (f1 ((- x 1)))))
	1))
    (apply (f1 ())
)))
(check-equal? (synchk prov1) false)

;; (eval prov2 ’((x 3))) returns 6
;; (eval prov2 ’((x 4))) returns 24
(define prov2
    '(fun ((f1 (x)) ((gt x 0)
	(* x (apply (f1 ((- x 1)))))
	1))
    (apply (f1 (x))
)))
;(check-equal? (eval prov2 '((x 3)) '()) 6)
;(check-equal?  (eval prov2 '((x 4)) '()) 24)

;;;;;;;;;;;;;;
;; Programs ;;
;;;;;;;;;;;;;;

;; VALID
;; Returns pi.
;; Results in 3.14159265
(define prog0
    '(fun ((pi ()) 3.14159265) 
	(apply (pi ())
)))
(check-equal? (synchk prog0) true)
(check-equal? (eval prog0 '() '()) (list 3.14159265 '()))

;; VALID
;; Adds one to pi.
;; Results in 4.14159265
(define prog1
    '(fun ((pi ()) 3.14159265) 
	(+ 1 (apply (pi ()))
)))
(check-equal? (synchk prog1) true)
(check-equal? (eval prog1 '() '()) (list 4.14159265 '()))

;; INVALID
;; Tries to add one to pi.
;; But pi is undefined, invalid.
(define prog2
    '(+ 1 (apply (pi ())))
)
(check-equal? (synchk prog2) false)

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
(check-equal? (eval prog3 '((z 2)) '()) (list 5 '()))

;; INVALID
;; Tries to call an undefined 'addthree' function
(define prog4
    '(fun ((addone (x)) (+ x 1))
	(fun ((addtwo (y)) (+ y 2))
	    (apply (addone (
		(apply (addthree (z)))
	    )
)))))
(check-equal? (synchk prog4) false)

;; VALID
;; Program -> Expr -> Number
(define prog5 525600)
(check-equal? (synchk prog5) true)

;; VALID
;; Program -> Expr -> Variable
(define prog6 'x)
(check-equal? (synchk prog6) true)

;; INVALID
;; Similar to prog1, but swapped the ordering of the operands.
(define prog7
    '(+ (apply (pi ())) 1)
)
(check-equal? (synchk prog7) false)

;; INVALID
;; pi is not defined
(define prog8
    '((not (gt (apply (pi ())) 1))
	1
	0
))
(check-equal? (synchk prog8) false)

;; VALID
;; same as prog8, but pi is defined
;; evaluates to 0, as !(pi > 1) evaluates to FALSE
(define prog9
    '(fun ((pi ()) 3.14159265) 
	((not (gt (apply (pi ())) 1))
	    1
	    0
)))
(check-equal? (synchk prog9) true)

;; INVALID
;; Variable assignment expression uses undefined function.
(define prog10
    '(var
	((x (apply (pi ()))))
	(* 2 x)
))
(check-equal? (synchk prog10) false)

;; INVALID
;; Variable assignment expression is fine now,
;; but proceeding expression is invalid.
(define prog11
    '(var
	((x 2))
	(* x (apply (pi ())))
))
(check-equal? (synchk prog11) false)

;; VALID
;; Calls function pi to assign pi to x,
;; then returns 2 * PI = 6.2831853
(define prog12
    '(fun ((pi ()) 3.14159265) 
	(var
	    ((x (apply (pi ()))))
	    (* 2 x)
)))
(check-equal? (synchk prog12) true)

;;;;;;;;;;;;;;;;;;
;; FormalParams ;;
;;;;;;;;;;;;;;;;;;

;; True
(define formalparams0
    '()
)
(check-equal? (formalparams formalparams0 '()) true)

;; True
(define formalparams1
    '(x y z)
)
(check-equal? (formalparams formalparams1 '()) true)

;; False
(define formalparams2
    '(x y 3)
)
(check-equal? (formalparams formalparams2 '()) false)

;; False
(define formalparams3
    '((a b c))
)
(check-equal? (formalparams formalparams3 '()) false)

;;;;;;;;;;;;;
;; FAssign ;;
;;;;;;;;;;;;;

;; True
;; Returns 1 if x > y, 0 otherwise.
(define fassign0 '(
    (myfunc (x y)) ((gt x y) 1 0)
))
(check-equal? (fassign fassign0 '()) true)

;; True
;; Returns the constant pi.
(define fassign1
    '((pi ()) 3.14159265)
)
(check-equal? (fassign fassign1 '()) true)

;; True
;; Always returns 0, but takes a couple arguments that do nothing.
(define fassign2
    '((myfunc (a b c d e f g h i j k l m n o p q r s t u v w x y z)) 0)
)
(check-equal? (fassign fassign2 '()) true)

;; False
;; fname and formalparams should be together in their own list.
(define fassign3
    '(myfunc (a b c) 0)
)
(check-equal? (fassign fassign3 '()) false)

;; False
;; Invalid formal parameters.
(define fassign4
    '((myfunc (1 2 3)) 0)
)
(check-equal? (synchk fassign4) false)

;; False
;; No corresponding expression.
(define fassign5
    '((myfunc (a b c)))
)
(check-equal? (synchk fassign5) false)

;; False
;; Missing formal parameters.
(define fassign6
    '((myfunc) 0)
)
(check-equal? (synchk fassign0) false)

;; False
;; A list is not a valid function name.
(define fassign7
    '((() ()) 0)
)
(check-equal? (synchk fassign0) false)

;;;;;;;;;;;
;; FExpr ;;
;;;;;;;;;;;

;; True
(define fexpr0
    (list 'fun fassign0 0)
)
(check-equal? (synchk fexpr0) true)

;; True
(define fexpr1
    (list 'fun fassign2 1)
)
(check-equal? (synchk fexpr1) true)

;; True
(define fexpr2
    ;; Evaluates pi via the pi function.
    (list 'fun fassign1 
	(list 'apply (list 'pi '()))
))
(check-equal? (synchk fexpr2) true)

;; True
;; Evaluates to 100 by both adding and subtracting 2 from 100.
(define fexpr3 
    '(fun ((addtwo (x)) (+ x 2))
	(fun ((subtwo (y)) (- y 2))
	    (apply (subtwo (
		(apply (addtwo (100)))
	    )
)))))
(check-equal? (synchk fexpr3) true)

;; False
;; fassign5 is invalid
(define fexpr4
    (list 'fun fassign5 0)
)
(check-equal? (synchk fexpr4) false)

;; False
;; boring is not an identifier
(define fexpr5
    (list 'boring fassign2 1)
)
(check-equal? (synchk fexpr5) false)

;; False
;; Too many items in list
(define fexpr6
    (list 'fun fassign2 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
)
(check-equal? (synchk fexpr6) false)

;;;;;;;;;;
;; Args ;;
;;;;;;;;;;

;; True
(define args0
   '()
)
(check-equal? (args args0 '()) true)

;; True
(define args1
   '(3 2 3 4)
)
(check-equal? (args args1 '()) true)

;; True
(define args2
   '((+ x (* y z)) (+ 3 4))
)
(check-equal? (args args2 '()) true)

;; False 
;; Variable assignment needs evaluation expression.
(define args3
   '((var (x)))
)
(check-equal? (args args3 '()) false)

;; False
;; Conditional 'not' only takes one argument.
(define args4 '(
    (+ 3 4) 
    ((not 3 2) 1 0)
))
(check-equal? (synchk args4) false)

;;;;;;;;;;;;;;;;;;;;;;;
;; Synchk Unit Tests ;;
;;;;;;;;;;;;;;;;;;;;;;;
;;formalparams
(check-equal? (formalparams '() '()) #t)
(check-equal? (formalparams '(x y z) '()) #t)
(check-equal? (formalparams '(1 y z) '()) #f)
(check-equal? (formalparams '(1 y z) '()) #f)
;;fassign
(check-equal? (fassign '((test ()) (+ 1 1)) '()) #t)
(check-equal? (fassign '((()) (+ 1 1)) '()) #f)
(check-equal? (fassign '((test (1 2)) (+ 1 1)) '()) #f)
(check-equal? (fassign '((test (x y)) (+ 1 1)) '()) #t)
(check-equal? (fassign '((test (x y)) (+ x y)) '()) #t)
;;fexpr
(check-equal? (fexpr '(fun ((test (x y)) (+ x y)) (+ 1 1)) '()) #t)
(check-equal? (fexpr '(f ((test (x y)) (+ x y)) (+ 1 1)) '()) #f)
;;args
(check-equal? (args '() '()) #t)
(check-equal? (args '(1 2 3) '()) #t)
(check-equal? (args '((+ 1 1) 2 3) '()) #t)
;;pushFuntoList
(check-equal? (pushFuntoList 'test 2 '()) '((test 2)))
;;getNumberOfParams
(check-equal? (getNumberOfParams 'test '((test 2))) 2)
(check-equal? (getNumberOfParams 'test2 '((test 2))) -1)
;;addTolstFromfexpr
(check-equal? (addTolstFromfexpr '(fun ((test (x y)) (+ 1 1))) '()) '((test 2)))
(check-equal? (addTolstFromfexpr '(fun ((test (x)) (+ 1 1))) '()) '((test 1)))
(check-equal? (addTolstFromfexpr '(fun ((test ()) (+ 1 1))) '()) '((test 0)))
;;apply
(check-equal? (applyf '(apply (test (x y))) '()) #f)
(check-equal? (applyf '(apply (test (x y))) '((test 2))) #t)
(check-equal? (applyf '(apply (test (x y))) '((test 1))) #f)
(check-equal? (applyf '(apply (test (x y))) '((test 2))) #t)
(check-equal? (applyf '(apply (test ())) '((test 0))) #t)
;;fexpr
(check-equal? (fexpr '(fun ((test (x y)) (+ x y)) (apply (test (1 2)))) '()) #t)
(check-equal? (fexpr '(fun ((test (x)) (+ x y)) (apply (test (1)))) '()) #t)
;Function params are wrong
(check-equal? (fexpr '(fun ((test (x)) (+ x y)) (apply (test (1 2)))) '()) #f)
(check-equal? (fexpr '(fun ((test (x y)) (+ x y)) (apply (test (1)))) '()) #f)
(check-equal? (fexpr '(fun ((test ()) (+ x y)) (apply (test ()))) '()) #t)
;Function doesn't exist
(check-equal? (fexpr '(fun ((test ()) (+ x y)) (apply (wrong ()))) '()) #f)

;;;;;;;;;;;;;;;;;;;;;
;; Eval Unit Tests ;;
;;;;;;;;;;;;;;;;;;;;;

;;eval
(check-equal? (eval '(fun ((test ()) (+ 1 1)) (apply (test ()))) '() '()) (list 2 '()))
(check-equal? (eval '(fun ((test ()) (+ z 1)) (apply (test ()))) '((z 1)) '()) (list 2 '()))
(check-equal? (eval '(fun ((test (x)) (+ x 1)) (apply (test (1)))) '() '()) (list 2 '()))
(check-equal? (eval '(fun ((test (x y)) (+ x y)) (apply (test (1 1)))) '() '()) (list 2 '()))

(check-equal? (eval '(fun ((f (a b)) (var ((x a) (y b)) (+ x y))) (apply (f (y 2)))) '((y 10)) '()) (list 12 '()))
(check-equal? (eval '(var ((x 1)) (fun ((f (x)) x)(fun ((g ()) (var ((x (+ x 1))) (apply (f (x)))))(apply (g ()))))) '() '()) (list 2 '()))
(check-equal? (eval '(var ((x 1)) (fun ((f ()) x) (fun ((g ()) (var ((x (+ x 1))) (apply (f ())))) (apply (g ()))))) '() '()) (list 1 '()))

(check-equal? (eval '((eq 1 1) 1 0)'() '()) (list 1 null))
(check-equal? (eval '((eq 0 1) 1 0) '() '()) (list 0 null))
(check-equal? (eval '(fun ((f ()) ((eq 1 1) 1 0)) (apply (f ()))) '() '()) (list 1 null))
(check-equal? (eval '(fun ((f ()) ((eq 0 1) 1 0)) (apply (f ()))) '() '()) (list 0 null))
(check-equal? (eval '(fun ((f (n)) ((eq n 1) 1 0)) (apply (f (0)))) '() '()) (list 0 null))

;;Recursion
(check-equal? (eval '(fun ((f (n)) ((eq n 0) 0 ((eq n 1) 1 (+ (apply (f ((- n 1)))) (apply (f ((- n 2)))))))) (apply (f (x)))) '((x 4)) '()) '(3 ()))
(check-equal? (eval '(fun ((f (n a))((eq n 0) a (apply (f ((- n 1) (* n a))))))(fun ((g (n)) (apply (f (n 1))))(apply (g (x))))) '((x 10)) '()) '(3628800 ()))

;SCOPE
(define scope1
  '(var ((a 1))
   (fun ((f ()) a)
   (var ((a 2))
   (apply (f ()))
))))
(check-equal? (eval scope1 '() '()) (list 1 '()))

(define scope2
  '(var ((a 1))
   (fun ((f (a)) a)
   (var ((a 2))
   (apply (f (a)))
))))
(check-equal? (eval scope2 '() '()) (list 2 '()))

;Pointers
(define heap
  '((0 1) (1 2) (2 1) (3 free) (4 5)))

(check-equal? (eval (+ 1 1) '() '()) '(2 ()))
(check-equal? (eval '(+ (wref 1 1) (deref 1)) '() heap) (list 2 '((0 1) (1 1) (2 1) (3 free) (4 5))))

(check-equal? (evalPointer '(deref 1) '() heap) '(2 ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(ref 1) '() heap) '(1 ((0 1) (1 2) (2 1) (3 1) (4 5))))
(check-equal? (evalPointer '(free 0) '() heap) '(0 ((0 free) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(wref 0 2) '() heap) '(2 ((0 2) (1 2) (2 1) (3 free) (4 5))))

(check-equal? (evalvarassign '((x 1)) '(+ x 1) '() heap) '(2 ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (eval '(var ((x 1)) (+ x 1)) '() heap) '(2 ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (eval '(var ((x (wref 1 1))) (+ x (deref 1))) '() heap) '(2 ((0 1) (1 1) (2 1) (3 free) (4 5))))

(check-equal? (evalPointer '(wref 1 1) '() heap) (list 1 '((0 1) (1 1) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(wref 3 2) '() heap) (list '(exception fma) heap))
(check-equal? (evalPointer '(free 1) '() heap) (list 1 '((0 1) (1 free) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(free 3) '() heap) (list '(exception fma) heap))
(check-equal? (evalPointer '(free 5) '() heap) (list '(exception ooma) heap))
(check-equal? (evalPointer '(ref 2) '() heap) (list 2 '((0 1) (1 2) (2 1) (3 2) (4 5))))
(check-equal? (evalPointer '(ref 2) '() '((1 1))) (list '(exception ooma) '((1 1))))

(check-equal? (eval (+ 1 1) '() '()) '(2 ()))
(check-equal? (eval '(+ (wref 1 1) (deref 1)) '() heap) '(2 ((0 1) (1 1) (2 1) (3 free) (4 5))))

(check-equal? (evalPointer '(deref 1) '() heap) '(2 ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(ref 1) '() heap) '(1 ((0 1) (1 2) (2 1) (3 1) (4 5))))
(check-equal? (evalPointer '(free 0) '() heap) '(0 ((0 free) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(wref 0 2) '() heap) '(2 ((0 2) (1 2) (2 1) (3 free) (4 5))))

(check-equal? (evalvarassign '((x 1)) '(+ x 1) '() heap) '(2  ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (eval '(var ((x 1)) (+ x 1)) '() heap) '(2  ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (eval '(var ((x (wref 1 1))) (+ x (deref 1))) '() heap) '(2 ((0 1) (1 1) (2 1) (3 free) (4 5)))) ;;Semantics of varassign are correct if this test passes


(check-equal? (eval '((gt (wref 1 5) 1) (deref 1) 2) '() heap) (list 5 '((0 1) (1 5) (2 1) (3 free) (4 5)))) ;;Semantics of BCond are correct if this test passes
(check-equal? (eval '((lt (wref 1 5) 1) 1 (deref 1)) '() heap) (list 5 '((0 1) (1 5) (2 1) (3 free) (4 5))))
(check-equal? (eval '((eq (wref 1 5) 5) 1 (deref 1)) '() heap) (list 1 '((0 1) (1 5) (2 1) (3 free) (4 5))))
(check-equal? (eval '((eq (wref 1 5) 4) 1 (deref 1)) '() heap) (list 5 '((0 1) (1 5) (2 1) (3 free) (4 5))))

(check-equal? (evalcond '(or (gt (wref 1 5) 6) (lt (deref 1) 1)) '() heap) '(#f ((0 1) (1 5) (2 1) (3 free) (4 5)))) ;;Or CCond semantics
(check-equal? (evalcond '(and (gt (wref 1 5) 4) (lt (deref 1) 6)) '() heap) '(#t ((0 1) (1 5) (2 1) (3 free) (4 5))))
(check-equal? (evalcond '(not (gt (wref 1 5) 6)) '() heap) '(#t ((0 1) (1 5) (2 1) (3 free) (4 5))))


;Pointer exceptions
(check-equal? (readfromlocation 3 heap) '(exception fma))
(check-equal? (readfromlocation 5 heap) '(exception ooma))
(check-equal? (writetolocation 5 1 heap) '(exception ooma))
(check-equal? (evalPointer '(deref 3) '() heap) '((exception fma) ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(deref 5) '() heap) '((exception ooma) ((0 1) (1 2) (2 1) (3 free) (4 5))))
(define heap2
  '((0 1) (1 2) (2 1) (3 1) (4 5)))
(check-equal? (evalPointer '(ref 1) '() heap2) '((exception ooma) ((0 1) (1 2) (2 1) (3 1) (4 5))))
(check-equal? (evalPointer '(wref 5 1) '() heap) '((exception ooma) ((0 1) (1 2) (2 1) (3 free) (4 5))))
(check-equal? (evalPointer '(deref 3) '() heap) (list '(exception fma) heap))
(check-equal? (evalPointer '(deref 5) '() heap) (list '(exception ooma) heap))
(check-equal? (evalPointer '(wref 3 1) '() heap) (list '(exception fma) heap))
(check-equal? (evalPointer '(wref 5 1) '() heap) (list '(exception ooma) heap))
(check-equal? (evalPointer '(free 3) '() heap) (list '(exception fma) heap))
(check-equal? (evalPointer '(free 5) '() heap) (list '(exception ooma) heap))
(check-equal? (evalPointer '(ref 1) '() heap2) (list '(exception ooma) heap2))

;;arith exceptions
(check-equal? (eval '(+ (deref 5) 1) '() heap) (list '(exception ooma) heap))
(check-equal? (eval '(- (deref 5) 1) '() heap) (list '(exception ooma) heap))
(check-equal? (eval '(* (deref 5) 1) '() heap) (list '(exception ooma) heap))
;;ccond exceptions
(check-equal? (evalcond '(gt (deref 5) 1) '() heap) (list '(exception ooma) heap))
(check-equal? (evalcond '(lt (deref 5) 1) '() heap) (list '(exception ooma) heap))
(check-equal? (evalcond '(eq (deref 5) 1) '() heap) (list '(exception ooma) heap))
(check-equal? (evalcond '(and (gt (deref 5) 1) (gt (deref 5) 1)) '() heap) (list '(exception ooma) heap))
(check-equal? (evalcond '(or (gt (deref 5) 1) (gt (deref 5) 1)) '() heap) (list '(exception ooma) heap))
(check-equal? (evalcond '(not (gt (deref 5) 1)) '() heap) (list '(exception ooma) heap))
(check-equal? (evalcond '(gt (deref 5) 1) '() heap) (list '(exception ooma) heap))
(check-equal? (evalcond '(gt (deref 3) 1) '() heap) (list '(exception fma) heap))
(check-equal? (evalcond '(gt (deref 1) 1) '() heap) (list #t heap))
;;if exceptions
(check-equal? (eval '((gt (deref 5) 1) 1 0) '() heap) (list '(exception ooma) heap))
(check-equal? (eval '((gt (deref 3) 1) 1 0) '() heap) (list '(exception fma) heap))

;;;;;;;;;;;
;; More Tests ;;
;;;;;;;;;;;

;; Simple 'ref' test.
;; Modifies the input heap, setting the value
;; of the first free location to 10.
;; Examples:
;; 	(eval test1 '() '()) -> OOM
;;	(eval test1 '() '((1 free))) -> '(1 ((1 10)))
(define test1
    '(ref (* 5 2))
)

;; Simple 'free' test.
;; Frees memory at location 1 (will return a value of 1).
;; Examples:
;;	(eval test2 '() '()) -> OOMA
;;	(eval test2 '() '((1 free))) -> FMA
;;	(eval test2 '() '((1 32))) -> '(1 ((1 free)))
(define test2
    '(free 1)
)

;; Simple 'deref' test.
;; Dereferences the value at location 4.
;; Examples:
;;	(eval test3 '() '()) -> OOMA
;;	(eval test3 '() '((4 free))) -> FMA
;;	(eval test3 '() '((4 32))) -> '(32 ((4 32)))
(define test3
    '(deref 4)
)

;; Simple 'wref' test.
;; (wref addr value)
;; Writes the value 27 to location 2.
;; Examples:
;;	(eval test4 '() '()) -> OOMA
;;	(eval test4 '() '((2 free))) -> FMA
;;	(eval test4 '() '((2 1))) -> '(27 ((2 27)))
(define test4
    '(wref 2 (* 3 (* 3 3)))
)

;; Allocates a value on the heap and stores 12.
;; Returns a result of the format (x ((x 12)))
;; where x is the address of the first free location in memory.
;; Examples:
;;	(eval test5 '() '()) -> OOM
;;	(eval test5 '() '((16 free) (1 free))) -> '(16 ((16 12) (1 free)))
(define test5
    '(var ((x (ref 12))) x)
)

;; Here is the C code for test5.
;;	int * x = malloc(sizeof(int));
;; 	*x = 12;
;; 	int * y = x;
;; 	*y = 128;
;; 	print(*x)
;; Note needs at least one free heap location.
;; Returns: '(128 ((addr 128))
;; If no heap is given: OOM Exception
;; Examples:
;;	(eval test6 '() '()) -> OOM
;;	(eval test6 '() '((1 free))) -> (128 ((1 128)))
(define test6
    '(var ((x (ref 12)))
	(var ((y x))
	    (var ((tmp (wref y 128)))
		(deref x)
))))

;; Adds the two input values to the heap by decrementing the first by one each iteration
;; and incrementing the second each iteration.
;; Example:
;;	(eval test7 '() '())			-> OOMA
;;	(eval test7 '() '((1 1) (2 1)))		-> '(2 '((1 0) (2 2)))
;;	(eval test7 '() '((1 2) (2 3)))		-> '(5 '((1 0) (2 5)))
;;	(eval test7 '() '((1 10) (2 6)))	-> '(16 '((1 0) (2 16)))
(define test7
    ;; add(* x, * y)
    ;; Recursively adds the value pointed to by x, to the value pointed to by y.
    '(fun ((add (x y)) 
	((lt (wref x (- (deref x) 1)) 1) 
	    (wref y (+ 1 (deref y))) ;; Base case, return y,
	    (wref y (+ 1 (apply (add (x y))))))) ;; and add one to 1 recursively.
	(apply (add (1 2)))
))

;; Adds two increments of x together.
;; Note as x is initially 13, 
;; after one increment it is 14
;; and after the second it is 15
;; thus the result is 14 + 15 = 29.
;; Examples:
;;	(eval test8 '() '()) -> OOM
;;	(eval test8 '() '((1 free))) -> '(29 ((1 15)))
(define test8
    ;; Increments the value pointed to by x.
    '(fun ((incp (x)) (wref x (+ (deref x) 1)))
	(var ((x (ref 13)))
	    ;; Add two increments of x together.
	    (+ 
	      (apply (incp (x)))
	      (apply (incp (x)))
))))

;; Simple test for to make sure you can catch exceptions within operations.
;; Example:
;;	(eval test9 '() '()) -> OOMA
;;	(eval test9 '() '((1 2))) -> OOMA
;;	(eval test9 '() '((2 1))) -> OOMA
;;	(eval test9 '() '((1 2) (2 3))) -> '(5 ((1 2) (2 3)))
(define test9
    '(+ (deref 1) (deref 2))
)

;; Simple test for to make sure you can catch exceptions within conditionals
;; Example:
;;	(eval test10 '() '()) -> OOMA
;;	(eval test10 '() '((1 2))) -> OOMA
;;	(eval test10 '() '((2 1))) -> OOMA
;;	(eval test10 '() '((1 1) (2 2))) -> '(0 ((1 1) (2 2)))
(define test10
    '((gt (deref 1) (deref 2)) 1 0)
)

;;;;;;;;;;;;;;;;;;
;; HW5 Provided ;;
;;;;;;;;;;;;;;;;;;

;; (eval prov1 '() '((1 free))) -> FMA
;; (eval prov1 '() '((1 3))) -> '(4 '((1 3)))
(define prov1
    '(var ((x (deref 1))) (+ x 1))
)

;; (eval prov2 '() '((1 free))) -> OOMA
;; (eval prov2 '() '((1 free) (2 64))) -> '(64 ((1 32) (2 64)))
(define prov2
    '(var ((x (ref 32)))
	(var ((y (+ x 1)))
	    (deref y)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        Old Function Samples         ;;
;; (these of course should still work) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (eval prov_old2 ’((x 3)) '()) returns '(6 ())
;; (eval prov_old2 ’((x 4)) '()) returns '(24 ())
(define prov_old2
    '(fun ((f1 (x)) ((gt x 0)
	(* x (apply (f1 ((- x 1)))))
	1))
    (apply (f1 (x))
)))

;; (eval prov_old3 '((y 10)) '()) = '(12 ())
(define prov_old3
  '(fun ((f (a b)) (var ((x a) (y b)) (+ x y))) (apply (f (y 2))
)))

;; (eval prov_old4 '() '()) = '(2 ())
(define prov_old4
    '(var ((x 1))
	(fun ((f (x)) x)
	    (fun ((g ()) (var ((x (+ x 1))) (apply (f (x)))))
		(apply (g ()))
))))

;; (eval prov_old5 '() '()) = '(1 ())
(define prov_old5
    '(var ((x 1))
	(fun ((f ()) x)
	    (fun ((g ()) (var ((x (+ x 1))) (apply (f ()))))
		(apply (g ()))
))))

;; (eval prov_old6 '((x 10)) '()) = '(55 ())
(define prov_old6
    '(fun ((f (n))
	((eq n 0) 0 ((eq n 1) 1 (+ (apply (f ((- n 1)))) (apply (f ((- n 2))))))))
	    (apply (f (x)))
))

;; (eval prov_old7 '((x 10)) '()) = '(3628800 ())
(define prov_old7
    '(fun ((f (n a))
	((eq n 0) a (apply (f ((- n 1) (* n a))))))
	    (fun ((g (n)) (apply (f (n 1))))
		(apply (g (x)))
)))

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

;; VALID
;; Adds two, then adds one to z,
;; where z must be provided by the input environment.
;; (eval prog3 '((z 2))) returns 5
(define prog3
    '(fun ((addone (x)) (+ x 1))
	(fun ((addtwo (y)) (+ y 2))
	    (apply (addone (
		(apply (addtwo (z)))
))))))

;; VALID
;; Program -> Expr -> Number
(define prog5 525600)

;; VALID
;; Program -> Expr -> Variable
(define prog6 'x)

;; VALID
;; same as prog8, but pi is defined
;; evaluates to 0, as !(pi > 1) evaluates to FALSE
(define prog9
    '(fun ((pi ()) 3.14159265) 
	((not (gt (apply (pi ())) 1))
	    1
	    0
)))

;; VALID
;; Calls function pi to assign pi to x,
;; then returns 2 * PI = 6.2831853
(define prog12
    '(fun ((pi ()) 3.14159265) 
	(var
	    ((x (apply (pi ()))))
	    (* 2 x)
)))


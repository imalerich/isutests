#lang racket
(provide (all-defined-out))

;;;;;;;;;;;
;; Tests ;;
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

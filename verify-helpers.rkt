#lang racket/base

(require (for-syntax racket/base))

(provide verify-val!
         verify-arg!
         true?)

(define-syntax (lixt-rec stx)
 (syntax-case stx (_)
   [(lixt-rec v q _) #'(cons v q)]
   [(list-rec v q a) #'(cons a q)]
   [(lixt-rec v q _ b ...) #'(lixt-rec v (cons v q) b ...)]
   [(lixt-rec v q a b ...) #'(lixt-rec v (cons a q) b ...)]))

(define-syntax-rule (lixt v a ...)
  (reverse (lixt-rec v '() a ...)))

(define-syntax (verify-val! stx)
  (syntax-case stx ()
    [(_ p v m) #'(if (p v) v (error m))]
    [(_ p v m a ...) #'(if (p v) v (error (apply format m (lixt v a ...))))]))

(define-syntax-rule (verify-arg! predicate name value)
  (if (predicate value)
      value
      (raise-argument-error name (symbol->string (quote predicate)) value)))

(define (true? v) (not (not v)))


(module+ test
  (require rackunit)

  (check-false (true? #f))
  (check-true (true? (= 1 1)))

  (check-equal? (lixt-rec 1 '() 2) '(2))
  (check-equal? (lixt-rec 1 '() _) '(1))

  (check-equal? (verify-val! odd? 13 "Number is not odd") 13)

  (check-exn #rx"Number is not odd"
             (λ () (verify-val! odd? 12 "Number is not odd")))
  (check-exn #rx"Number 12 is not odd"
             (λ () (verify-val! odd? 12 "Number ~s is not odd" 12)))
  (check-exn #rx"Number 12 is not odd"
             (λ () (verify-val! odd? 12 "Number ~s is not odd" _)))
  (check-exn #rx"Number 12 is not odd, like 7"
             (λ () (verify-val! odd? 12 "Number ~s is not odd, like ~s" _ 7)))
  (check-exn #rx"Number 12 is not odd, like 7 or 13"
             (λ () (verify-val! odd? 12 "Number ~s is not odd, like ~s or ~s" _ 7 13)))
  (check-exn #rx"7 is odd, but 12 \\(12\\) is not, but 13 and 17 are"
             (λ () (verify-val! odd? 12 "~s is odd, but ~s (~s) is not, but ~s and ~s are" 7 _ _ 13 17)))

  (check-equal? (verify-arg! odd? 'test 13) 13)

  (check-exn #px"checked-string->int: contract violation\\s+expected: string\\?\\s+given: 12"
             (λ () (verify-arg! string? 'checked-string->int 12)))
)

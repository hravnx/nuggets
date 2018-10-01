#lang racket

(provide match-single)

(define (match-single regex text [start-pos 0] [end-pos #f])
  (define m
    (cond [(list? start-pos) (apply regexp-match regex text start-pos)]
          [(pair? start-pos) (regexp-match regex text (car start-pos) (cdr start-pos))]
          [else (regexp-match regex text start-pos end-pos)]))
  (if m (second m) m))

(module+ test
  (require rackunit)

  (check-equal? (match-single "abc(.*)abc" "abctestabc") "test")
  (check-false (match-single "abc(.*)abc" "ab"))

)

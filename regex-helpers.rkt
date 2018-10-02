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

  (define PATTERN "abc(.*)abc")
  (define TEXT "abctestabc")

  (check-equal? (match-single PATTERN TEXT '(0 10)) "test")
  (check-false (match-single PATTERN TEXT '(1 #f)))

  (check-equal? (match-single PATTERN TEXT '(0 . 10)) "test")
  (check-false (match-single PATTERN TEXT '(1 . #f)))

  (check-equal? (match-single PATTERN TEXT) "test")
  (check-false (match-single PATTERN "ab"))

)

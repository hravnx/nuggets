#lang racket

(provide fetch dead-link?)

(require net/url
         threading
         nuggets/verify-helpers
         nuggets/regex-helpers)

(define GET-PROC (make-parameter get-pure-port))
(define HEAD-PROC (make-parameter head-impure-port))

(define (http-request url handler)
  (call/input-url (string->url url) handler port->string))

(define (fetch url)
  (http-request url (GET-PROC)))

(define (get-headers url)
  (http-request url (HEAD-PROC)))

(define (checked-string->int s)
  (begin
    (verify-arg! string? 'checked-string->int s)
    (verify-val! true? (string->number s) "String ~s is not a number" s)))

(define (get-request-result-code header-text)
  (~>> header-text
       (match-single #px"^HTTP/\\d\\.\\d (\\d+) ")
       checked-string->int))

(define (dead-link? url)
  (~>> url
       get-headers
       get-request-result-code
       (= 404)))

(module+ test
  (require rackunit)

  (define (returns s)
    (λ (u) (open-input-string s)))

  (parameterize ([GET-PROC (returns "Hello world")])
    (check-equal? (fetch "https://google.com") "Hello world"))

  (parameterize ([HEAD-PROC (returns "HTTP/1.1 200 OK")])
    (check-false (dead-link? "https://google.com"))
    (check-equal? (get-headers "https://google.com") "HTTP/1.1 200 OK"))

  (parameterize ([HEAD-PROC (returns "HTTP/1.1 404 Not Found")])
    (check-true (dead-link? "https://google.com")))

  (check-equal? (get-request-result-code "HTTP/1.1 200 OK") 200)
  (check-equal? (get-request-result-code "HTTP/1.1 404 Not found") 404)
  (check-equal? (get-request-result-code "HTTP/1.1 500 Internal Server Error") 500)

  (check-exn #rx"Hmm" (λ () (verify-val! odd? 12 "Hmm")))
  (check-exn #rx"Hmm 12" (λ () (verify-val! odd? 12 "Hmm ~s" _)))
  (check-exn #rx"Hmm 13 12 15" (λ () (verify-val! odd? 12 "Hmm ~s ~s ~s" 13 _ 15)))

  (check-equal? (checked-string->int "42") 42)
  (check-exn #rx"checked-string->int: contract violation" (λ () (checked-string->int 42)))
  (check-exn #rx"String \"x\" is not a number" (λ () (checked-string->int "x")))
 )

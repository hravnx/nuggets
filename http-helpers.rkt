#lang racket

(provide fetch dead-link?)

(require net/url
         threading
         nuggets/regex-helpers)

(define (http-request url handler)
  (call/input-url (string->url url) handler port->string))

(define (fetch url) (http-request url get-pure-port))

(define (get-headers url) (http-request url head-impure-port))

(define (checked-string->number ctx s)
  (let ([n (cond [(string? s) (string->number s)]
                 [else (error (format "Non-string ~s in ~s" s ctx))])])
    (if n
        n
        (error (format "String ~s is not a number in ~s" s ctx)))))

(define (get-request-result-code header-text)
  (~>> header-text
       (match-single #px"^HTTP/\\d\\.\\d (\\d+) ")
       (checked-string->number header-text)))

(define (dead-link? url)
  (~>> url
       get-headers
       get-request-result-code
       (= 404)))

(module+ test
  (require rackunit)

  (check-equal? (get-request-result-code "HTTP/1.1 200 OK") 200)
  (check-equal? (get-request-result-code "HTTP/1.1 404 Not found") 404)
  (check-equal? (get-request-result-code "HTTP/1.1 500 Internal Server Error") 500)

  (check-equal? (checked-string->number "" "42") 42)
  (check-exn #rx"String \"B\" is not a number in \"A\"" (λ () (checked-string->number "A" "B")))
  (check-exn #rx"Non-string \\(\\) in \"A\"" (λ () (checked-string->number "A" '())))
)

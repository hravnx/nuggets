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
  (cond [(string? s) (string->number s)]
        [else (error (format "Bad string ~s in ~s" s ctx))]))

(define (get-request-result-code header-text)
  (~>> header-text
       (match-single #px"^HTTP/\\d\\.\\d (\\d+) ")
       (checked-string->number header-text)))

(define (dead-link? url)
  (~>> url
       get-headers
       get-request-result-code
       (= 404)))


#(define-macro (syntaxvector type)
  (let ((type? (if (pair? type) (car type) type))
	(default (and (pair? type) (cadr type))))
   `(define-syntax-function ly:music-function? (parser location size) (index?)
     (let* ((v (make-vector size ,default))
	    (fun
	     (define-syntax-function ,type (parser location index) (index?)
	      (vector-ref v index))))
      (ly:make-music-function
       (ly:music-function-signature fun)
       (make-procedure-with-setter (ly:music-function-extract fun)
	(lambda (parser location index value)
	 (vector-set! v index value))))))))


musicvector =
#(syntaxvector (ly:music? (make-music 'Music)))

zup = \musicvector #2

\zup0 = { c d e f }
\zup1 = { g a b c' }

{ \clef "bass" \zup0 \zup1 \zup1 \zup0 }

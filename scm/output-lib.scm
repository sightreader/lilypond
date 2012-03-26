;;;; This file is part of LilyPond, the GNU music typesetter.
;;;;
;;;; Copyright (C) 1998--2012 Jan Nieuwenhuizen <janneke@gnu.org>
;;;; Han-Wen Nienhuys <hanwen@xs4all.nl>
;;;;
;;;; LilyPond is free software: you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation, either version 3 of the License, or
;;;; (at your option) any later version.
;;;;
;;;; LilyPond is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;; GNU General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU General Public License
;;;; along with LilyPond.  If not, see <http://www.gnu.org/licenses/>.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general

(define-public (grob::has-interface grob iface)
  (memq iface (ly:grob-interfaces grob)))

(define-public (grob::is-live? grob)
  (pair? (ly:grob-basic-properties grob)))

(define-public (grob::x-parent-width grob)
  (ly:grob-property (ly:grob-parent grob X) 'X-extent))

(define-public (make-stencil-boxer thickness padding callback)
  "Return function that adds a box around the grob passed as argument."
  (lambda (grob)
    (box-stencil (callback grob) thickness padding)))

(define-public (make-stencil-circler thickness padding callback)
  "Return function that adds a circle around the grob passed as argument."
  (lambda (grob)
    (circle-stencil (callback grob) thickness padding)))

(define-public (print-circled-text-callback grob)
  (grob-interpret-markup grob (make-circle-markup
			       (ly:grob-property grob 'text))))

(define-public (event-cause grob)
  (let ((cause (ly:grob-property  grob 'cause)))

    (cond
     ((ly:stream-event? cause) cause)
     ((ly:grob? cause) (event-cause cause))
     (else #f))))

(define-public (grob-interpret-markup grob text)
  (let* ((layout (ly:grob-layout grob))
	 (defs (ly:output-def-lookup layout 'text-font-defaults))
	 (props (ly:grob-alist-chain grob defs)))

    (ly:text-interface::interpret-markup layout props text)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; beam slope

;; calculates each slope of a broken beam individually
(define-public (beam::place-broken-parts-individually grob)
  (ly:beam::quanting grob '(+inf.0 . -inf.0) #f))

;; calculates the slope of a beam as a single unit,
;; even if it is broken.  this assures that the beam
;; will pick up where it left off after a line break
(define-public (beam::align-with-broken-parts grob)
  (ly:beam::quanting grob '(+inf.0 . -inf.0) #t))

;; uses the broken beam style from edition peters combines the
;; values of place-broken-parts-individually and align-with-broken-parts above,
;; favoring place-broken-parts-individually when the beam naturally has a steeper
;; incline and align-with-broken-parts when the beam is flat
(define-public (beam::slope-like-broken-parts grob)
  (define (slope y x)
    (/ (- (cdr y) (car y)) (- (cdr x) (car x))))
  (let* ((quant1 (ly:beam::quanting grob '(+inf.0 . -inf.0) #t))
         (original (ly:grob-original grob))
         (siblings (if (ly:grob? original)
                       (ly:spanner-broken-into original)
                       '())))
    (if (null? siblings)
        quant1
        (let* ((quant2 (ly:beam::quanting grob '(+inf.0 . -inf.0) #f))
               (x-span (ly:grob-property grob 'X-positions))
               (slope1 (slope quant1 x-span))
               (slope2 (slope quant2 x-span))
               (quant2 (if (not (= (sign slope1) (sign slope2)))
                           '(0 . 0)
                           quant2))
               (factor (/ (atan (abs slope1)) PI-OVER-TWO))
               (base (cons-map
                       (lambda (x)
                         (+ (* (x quant1) (- 1 factor))
                            (* (x quant2) factor)))
                       (cons car cdr))))
          (ly:beam::quanting grob base #f)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cross-staff stuff

(define-public (script-or-side-position-cross-staff g)
  (or
   (ly:script-interface::calc-cross-staff g)
   (ly:side-position-interface::calc-cross-staff g)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; note heads

(define-public (stem::calc-duration-log grob)
  (ly:duration-log
   (ly:event-property (event-cause grob) 'duration)))

(define-public (stem::length grob)
  (let* ((ss (ly:staff-symbol-staff-space grob))
         (beg (ly:grob-property grob 'stem-begin-position))
         (beam (ly:grob-object grob 'beam)))
    (if (null? beam)
        (abs (- (ly:stem::calc-stem-end-position grob) beg))
        (begin
          (ly:programming-error
            "stem::length called but will not be used for beamed stem.")
          0.0))))

(define-public (stem::pure-length grob beg end)
  (let* ((ss (ly:staff-symbol-staff-space grob))
         (beg (ly:grob-pure-property grob 'stem-begin-position 0 1000)))
    (abs (- (ly:stem::pure-calc-stem-end-position grob 0 2147483646) beg))))

(define (stem-stub::do-calculations grob)
  (and (ly:grob-property (ly:grob-parent grob X) 'cross-staff)
       (not (ly:grob-property (ly:grob-parent grob X) 'transparent))))

(define-public (stem-stub::pure-height grob beg end)
  (if (stem-stub::do-calculations grob)
      '(0 . 0)
      '(+inf.0 . -inf.0)))

(define-public (stem-stub::width grob)
  (if (stem-stub::do-calculations grob)
      (grob::x-parent-width grob)
      '(+inf.0 . -inf.0)))

(define-public (stem-stub::extra-spacing-height grob)
  (if (stem-stub::do-calculations grob)
      (let* ((dad (ly:grob-parent grob X))
             (refp (ly:grob-common-refpoint grob dad Y))
             (stem_ph (ly:grob-pure-height dad refp 0 1000000))
             (my_ph (ly:grob-pure-height grob refp 0 1000000))
             ;; only account for distance if stem is on different staff than stub
             (dist (if (grob::has-interface refp 'hara-kiri-group-spanner-interface)
                       0
                       (- (car my_ph) (car stem_ph)))))
        (if (interval-empty? (interval-intersection stem_ph my_ph)) #f (coord-translate stem_ph dist)))
      #f))

;; FIXME: NEED TO FIND A BETTER WAY TO HANDLE KIEVAN NOTATION
(define-public (note-head::calc-duration-log grob)
  (let ((style (ly:grob-property grob 'style)))
    (if (and (symbol? style) (string-match "kievan*" (symbol->string style)))
      (min 3
        (ly:duration-log
	(ly:event-property (event-cause grob) 'duration)))
      (min 2
	(ly:duration-log
	(ly:event-property (event-cause grob) 'duration))))))

(define-public (dots::calc-dot-count grob)
  (ly:duration-dot-count
   (ly:event-property (event-cause grob) 'duration)))

(define-public (dots::calc-staff-position grob)
  (let* ((head (ly:grob-parent grob Y))
	 (log (ly:grob-property head 'duration-log)))

    (cond
     ((or (not (grob::has-interface head 'rest-interface))
	  (not (integer? log))) 0)
     ((= log 7) 4)
     ((> log 4) 3)
     ((= log 0) -1)
     ((= log 1) 1)
     ((= log -1) 1)
     (else 0))))

;; Kept separate from note-head::calc-glyph-name to allow use by
;; markup commands \note and \note-by-number
(define-public (select-head-glyph style log)
  "Select a note head glyph string based on note head style @var{style}
and duration-log @var{log}."
  (case style
    ;; "default" style is directly handled in note-head.cc as a
    ;; special case (HW says, mainly for performance reasons).
    ;; Therefore, style "default" does not appear in this case
    ;; statement.  -- jr
    ((xcircle) "2xcircle")
    ((harmonic) "0harmonic")
    ((harmonic-black) "2harmonic")
    ((harmonic-mixed) (if (<= log 1) "0harmonic"
			  "2harmonic"))
    ((baroque)
     ;; Oops, I actually would not call this "baroque", but, for
     ;; backwards compatibility to 1.4, this is supposed to take
     ;; brevis, longa and maxima from the neo-mensural font and all
     ;; other note heads from the default font.  -- jr
     (if (< log 0)
	 (string-append (number->string log) "neomensural")
	 (number->string log)))
    ((altdefault)
     ;; Like default, but brevis is drawn with double vertical lines
     (if (= log -1)
	 (string-append (number->string log) "double")
	 (number->string log)))
    ((mensural)
     (string-append (number->string log) (symbol->string style)))
    ((petrucci)
     (if (< log 0)
	 (string-append (number->string log) "mensural")
	 (string-append (number->string log) (symbol->string style))))
    ((blackpetrucci)
     (if (< log 0)
	 (string-append (number->string log) "blackmensural")
	 (string-append (number->string log) (symbol->string style))))
    ((semipetrucci)
     (if (< log 0)
	 (string-append (number->string log) "semimensural")
	 (string-append (number->string log) "petrucci")))
    ((neomensural)
     (string-append (number->string log) (symbol->string style)))
    ((kievan)
     (string-append (number->string log) "kievan"))
    (else
     (if (string-match "vaticana*|hufnagel*|medicaea*" (symbol->string style))
	 (symbol->string style)
	 (string-append (number->string (max 0 log))
			(symbol->string style))))))

(define-public (note-head::calc-glyph-name grob)
  (let* ((style (ly:grob-property grob 'style))
	 (log (if (string-match "kievan*" (symbol->string style))
		  (min 3 (ly:grob-property grob 'duration-log))
		  (min 2 (ly:grob-property grob 'duration-log)))))
    (select-head-glyph style log)))

(define-public (note-head::brew-ez-stencil grob)
  (let* ((log (ly:grob-property grob 'duration-log))
	 (pitch (ly:event-property (event-cause grob) 'pitch))
	 (pitch-index (ly:pitch-notename pitch))
	 (note-names (ly:grob-property grob 'note-names))
	 (pitch-string (if (and (vector? note-names)
				(> (vector-length note-names) pitch-index))
			   (vector-ref note-names pitch-index)
			   (string
			    (integer->char
			     (+ (modulo (+ pitch-index 2) 7)
				(char->integer #\A))))))
	 (staff-space (ly:staff-symbol-staff-space grob))
	 (line-thickness (ly:staff-symbol-line-thickness grob))
	 (stem (ly:grob-object grob 'stem))
	 (stem-thickness (* (if (ly:grob? stem)
				(ly:grob-property stem 'thickness)
				1.3)
			    line-thickness))
	 (radius (/ (+ staff-space line-thickness) 2))
	 (letter (markup #:center-align #:vcenter pitch-string))
	 (filled-circle (markup #:draw-circle radius 0 #t)))

    (ly:stencil-translate-axis
     (grob-interpret-markup
      grob
      (if (>= log 2)
	  (make-combine-markup
	   filled-circle
	   (make-with-color-markup white letter))
	  (make-combine-markup
	   (make-combine-markup
	    filled-circle
	    (make-with-color-markup white (make-draw-circle-markup
					   (- radius stem-thickness) 0 #t)))
	   letter)))
     radius X)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clipping

(define-public (make-rhythmic-location bar-num num den)
  (cons
   bar-num (ly:make-moment num den)))

(define-public (rhythmic-location? a)
  (and (pair? a)
       (integer? (car a))
       (ly:moment? (cdr a))))

(define-public (make-graceless-rhythmic-location loc)
  (make-rhythmic-location
   (car loc)
   (ly:moment-main-numerator (rhythmic-location-measure-position loc))
   (ly:moment-main-denominator (rhythmic-location-measure-position loc))))

(define-public rhythmic-location-measure-position cdr)
(define-public rhythmic-location-bar-number car)

(define-public (rhythmic-location<? a b)
  (cond
   ((< (car a) (car b)) #t)
   ((> (car a) (car b)) #f)
   (else
    (ly:moment<? (cdr a) (cdr b)))))

(define-public (rhythmic-location<=? a b)
  (not (rhythmic-location<? b a)))
(define-public (rhythmic-location>=? a b)
  (rhythmic-location<? a b))
(define-public (rhythmic-location>? a b)
  (rhythmic-location<? b a))

(define-public (rhythmic-location=? a b)
  (and (rhythmic-location<=? a b)
       (rhythmic-location<=? b a)))

(define-public (rhythmic-location->file-string a)
  (ly:format "~a.~a.~a"
	     (car a)
	     (ly:moment-main-numerator (cdr a))
	     (ly:moment-main-denominator (cdr a))))

(define-public (rhythmic-location->string a)
  (ly:format "bar ~a ~a"
	     (car a)
	     (ly:moment->string (cdr a))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; break visibility

(define-public all-visible             #(#t #t #t))
(define-public begin-of-line-invisible #(#t #t #f))
(define-public center-invisible        #(#t #f #t))
(define-public end-of-line-invisible   #(#f #t #t))
(define-public begin-of-line-visible   #(#f #f #t))
(define-public center-visible          #(#f #t #f))
(define-public end-of-line-visible     #(#t #f #f))
(define-public all-invisible           #(#f #f #f))
(define-public (inherit-x-parent-visibility grob)
  (let ((parent (ly:grob-parent grob X)))
    (ly:grob-property parent 'break-visibility all-invisible)))
(define-public (inherit-y-parent-visibility grob)
  (let ((parent (ly:grob-parent grob X)))
    (ly:grob-property parent 'break-visibility)))


(define-public spanbar-begin-of-line-invisible #(#t #f #f))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bar lines.

;;
;; How should a  bar line behave at a break?
(define bar-glyph-alist
  '((":|:" . (":|" . "|:"))
    (":|.|:" . (":|" . "|:"))
    (":|.:" . (":|" . "|:"))
    ("||:" . ("||" . "|:"))
    ("dashed" . ("dashed" . '()))
    ("|" . ("|" . ()))
    ("||:" . ("||" . "|:"))
    ("|s" . (() . "|"))
    ("|:" . ("|" . "|:"))
    ("|." . ("|." . ()))

    ;; hmm... should we end with a bar line here?
    (".|" . ("|" . ".|"))
    (":|" . (":|" . ()))
    ("||" . ("||" . ()))
    (".|." . (".|." . ()))
    ("|.|" . ("|.|" . ()))
    ("" . ("" . ""))
    (":" . (":" . ""))
    ("." . ("." . ()))
    ("'" . ("'" . ()))
    ("empty" . (() . ()))
    ("brace" . (() . "brace"))
    ("bracket" . (() . "bracket"))

    ;; segno bar lines
    ("S" . ("||" . "S"))
    ("|S" . ("|" . "S"))
    ("S|" . ("S" . ()))
    (":|S" . (":|" . "S"))
    (":|S." . (":|S" . ()))
    ("S|:" . ("S" . "|:"))
    (".S|:" . ("|" . "S|:"))
    (":|S|:" . (":|" . "S|:"))
    (":|S.|:" . (":|S" . "|:"))

    ;; ancient bar lines
    ("kievan" . ("kievan" . ""))))

(define-public (bar-line::calc-glyph-name grob)
  (let* ((glyph (ly:grob-property grob 'glyph))
	 (dir (ly:item-break-dir grob))
	 (result (assoc-get glyph bar-glyph-alist))
	 (glyph-name (if (= dir CENTER)
			 glyph
		         (if (and result
				  (string? (index-cell result dir)))
			     (index-cell result dir)
			     #f))))
    glyph-name))

(define-public (bar-line::calc-break-visibility grob)
  (let* ((glyph (ly:grob-property grob 'glyph))
	 (result (assoc-get glyph bar-glyph-alist)))

    (if result
	(vector (string? (car result)) #t (string? (cdr result)))
	all-invisible)))

(define-public (shift-right-at-line-begin g)
  "Shift an item to the right, but only at the start of the line."
  (if (and (ly:item? g)
	   (equal? (ly:item-break-dir g) RIGHT))
      (ly:grob-translate-axis! g 3.5 X)))

(define-public (pure-from-neighbor-interface::extra-spacing-height-at-beginning-of-line grob)
  (if (= 1 (ly:item-break-dir grob))
      (pure-from-neighbor-interface::extra-spacing-height grob)
      (cons -0.1 0.1)))

(define-public (pure-from-neighbor-interface::extra-spacing-height grob)
  (let* ((height (ly:grob-pure-height grob grob 0 10000000))
         (from-neighbors (interval-union
                            height
                            (ly:axis-group-interface::pure-height
                              grob
                              0
                              10000000))))
    (coord-operation - from-neighbors height)))

(define-public (pure-from-neighbor-interface::account-for-span-bar grob)
  (let* ((esh (pure-from-neighbor-interface::extra-spacing-height grob))
         (hsb (ly:grob-property grob 'has-span-bar))
         (ii (interval-intersection esh (cons -1.01 1.01))))
    (if (pair? hsb)
        (cons (car (if (and (car hsb)
                       (ly:grob-property grob 'allow-span-bar))
                       esh ii))
              (cdr (if (cdr hsb) esh ii)))
        ii)))

(define-public (pure-from-neighbor-interface::extra-spacing-height-including-staff grob)
  (let ((esh (pure-from-neighbor-interface::extra-spacing-height grob))
        (to-staff (coord-operation -
                                   (interval-widen
                                     '(0 . 0)
                                     (ly:staff-symbol-staff-radius grob))
                                   (ly:grob::stencil-height grob))))
    (interval-union esh to-staff)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tuplets

(define-public (tuplet-number::calc-direction grob)
  (ly:tuplet-bracket::calc-direction (ly:grob-object grob 'bracket)))

(define-public (tuplet-number::calc-denominator-text grob)
  (number->string (ly:event-property (event-cause grob) 'denominator)))

(define-public (tuplet-number::calc-fraction-text grob)
  (let ((ev (event-cause grob)))

    (format #f "~a:~a"
	    (ly:event-property ev 'denominator)
	    (ly:event-property ev 'numerator))))

;; a formatter function, which is simply a wrapper around an existing
;; tuplet formatter function. It takes the value returned by the given
;; function and appends a note of given length.
(define-public ((tuplet-number::append-note-wrapper function note) grob)
  (let ((txt (if function (function grob) #f)))

    (if txt
	(markup txt #:fontsize -5 #:note note UP)
	(markup #:fontsize -5 #:note note UP))))

;; Print a tuplet denominator with a different number than the one derived from
;; the actual tuplet fraction
(define-public ((tuplet-number::non-default-tuplet-denominator-text denominator)
		grob)
  (number->string (if denominator
		      denominator
		      (ly:event-property (event-cause grob) 'denominator))))

;; Print a tuplet fraction with different numbers than the ones derived from
;; the actual tuplet fraction
(define-public ((tuplet-number::non-default-tuplet-fraction-text
		 denominator numerator) grob)
  (let* ((ev (event-cause grob))
         (den (if denominator denominator (ly:event-property ev 'denominator)))
         (num (if numerator numerator (ly:event-property ev 'numerator))))

    (format #f "~a:~a" den num)))

;; Print a tuplet fraction with note durations appended to the numerator and the
;; denominator
(define-public ((tuplet-number::fraction-with-notes
		 denominatornote numeratornote) grob)
  (let* ((ev (event-cause grob))
         (denominator (ly:event-property ev 'denominator))
         (numerator (ly:event-property ev 'numerator)))

    ((tuplet-number::non-default-fraction-with-notes
      denominator denominatornote numerator numeratornote) grob)))

;; Print a tuplet fraction with note durations appended to the numerator and the
;; denominator
(define-public ((tuplet-number::non-default-fraction-with-notes
		 denominator denominatornote numerator numeratornote) grob)
  (let* ((ev (event-cause grob))
         (den (if denominator denominator (ly:event-property ev 'denominator)))
         (num (if numerator numerator (ly:event-property ev 'numerator))))

    (make-concat-markup (list
			 (make-simple-markup (format #f "~a" den))
			 (markup #:fontsize -5 #:note denominatornote UP)
			 (make-simple-markup " : ")
			 (make-simple-markup (format #f "~a" num))
			 (markup #:fontsize -5 #:note numeratornote UP)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color

(define-public (color? x)
  (and (list? x)
       (= 3 (length x))
       (apply eq? #t (map number? x))
       (apply eq? #t (map (lambda (y) (<= 0 y 1)) x))))

(define-public (rgb-color r g b) (list r g b))

; predefined colors
(define-public black       '(0.0 0.0 0.0))
(define-public white       '(1.0 1.0 1.0))
(define-public red         '(1.0 0.0 0.0))
(define-public green       '(0.0 1.0 0.0))
(define-public blue        '(0.0 0.0 1.0))
(define-public cyan        '(0.0 1.0 1.0))
(define-public magenta     '(1.0 0.0 1.0))
(define-public yellow      '(1.0 1.0 0.0))

(define-public grey        '(0.5 0.5 0.5))
(define-public darkred     '(0.5 0.0 0.0))
(define-public darkgreen   '(0.0 0.5 0.0))
(define-public darkblue    '(0.0 0.0 0.5))
(define-public darkcyan    '(0.0 0.5 0.5))
(define-public darkmagenta '(0.5 0.0 0.5))
(define-public darkyellow  '(0.5 0.5 0.0))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key signature

(define-public (key-signature-interface::alteration-position step alter
							     c0-position)
  ;; TODO: memoize - this is mostly constant.

  ;; fes, ges, as and bes typeset in lower octave
  (define FLAT_TOP_PITCH 2)

  ;; ais and bis typeset in lower octave
  (define SHARP_TOP_PITCH 4)

  (if (pair? step)
      (+ (cdr step) (* (car step) 7) c0-position)
      (let* ((from-bottom-pos (modulo (+ 4 49 c0-position) 7))
	     (p step)
	     (c0 (- from-bottom-pos 4)))

	(if
	 (or (and (< alter 0)
		  (or (> p FLAT_TOP_PITCH) (> (+ p c0) 4)) (> (+ p c0) 1))
	     (and (> alter 0)
		  (or (> p SHARP_TOP_PITCH) (> (+ p c0) 5)) (> (+ p c0) 2)))

	 ;; Typeset below c_position
	 (set! p (- p 7)))

	;; Provide for the four cases in which there's a glitch
	;; it's a hack, but probably not worth
	;; the effort of finding a nicer solution.
	;; --dl.
	(cond
	 ((and (= c0 2) (= p 3) (> alter 0))
	  (set! p (- p 7)))
	 ((and (= c0 -3) (= p -1) (> alter 0))
	  (set! p (+ p 7)))
	 ((and (= c0 -4) (= p -1) (< alter 0))
	  (set! p (+ p 7)))
	 ((and (= c0 -2) (= p -3) (< alter 0))
	  (set! p (+ p 7))))

	(+ c0 p))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; annotations

(define-public (numbered-footnotes int)
  (markup #:tiny (number->string (+ 1 int))))

(define-public (symbol-footnotes int)
  (define (helper symbols out idx n)
    (if (< n 1)
        out
        (helper symbols
                (string-append out (list-ref symbols idx))
                idx
                (- n 1))))
  (markup #:tiny (helper '("*" "†" "‡" "§" "¶")
                          ""
                          (remainder int 5)
                          (+ 1 (quotient int 5)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; accidentals

(define-public (accidental-interface::calc-alteration grob)
  (ly:pitch-alteration (ly:event-property (event-cause grob) 'pitch)))

(define-public cancellation-glyph-name-alist
  '((0 . "accidentals.natural")))

(define-public standard-alteration-glyph-name-alist
  '(
    ;; ordered for optimal performance.
    (0 . "accidentals.natural")
    (-1/2 . "accidentals.flat")
    (1/2 . "accidentals.sharp")

    (1 . "accidentals.doublesharp")
    (-1 . "accidentals.flatflat")

    (3/4 . "accidentals.sharp.slashslash.stemstemstem")
    (1/4 . "accidentals.sharp.slashslash.stem")
    (-1/4 . "accidentals.mirroredflat")
    (-3/4 . "accidentals.mirroredflat.flat")))

;; FIXME: standard vs default, alteration-FOO vs FOO-alteration
(define-public alteration-default-glyph-name-alist
  standard-alteration-glyph-name-alist)

(define-public makam-alteration-glyph-name-alist
  '((1 . "accidentals.doublesharp")
    (8/9 . "accidentals.sharp.slashslashslash.stemstem")
    (5/9 . "accidentals.sharp.slashslashslash.stem")
    (4/9 . "accidentals.sharp")
    (1/9 . "accidentals.sharp.slashslash.stem")
    (0 . "accidentals.natural")
    (-1/9 . "accidentals.mirroredflat")
    (-4/9 . "accidentals.flat.slash")
    (-5/9 . "accidentals.flat")
    (-8/9 . "accidentals.flat.slashslash")
    (-1 . "accidentals.flatflat")))

(define-public alteration-hufnagel-glyph-name-alist
  '((-1/2 . "accidentals.hufnagelM1")
    (0 . "accidentals.vaticana0")
    (1/2 . "accidentals.mensural1")))

(define-public alteration-medicaea-glyph-name-alist
  '((-1/2 . "accidentals.medicaeaM1")
    (0 . "accidentals.vaticana0")
    (1/2 . "accidentals.mensural1")))

(define-public alteration-vaticana-glyph-name-alist
  '((-1/2 . "accidentals.vaticanaM1")
    (0 . "accidentals.vaticana0")
    (1/2 . "accidentals.mensural1")))

(define-public alteration-mensural-glyph-name-alist
  '((-1/2 . "accidentals.mensuralM1")
    (0 . "accidentals.vaticana0")
    (1/2 . "accidentals.mensural1")))

(define-public alteration-kievan-glyph-name-alist
 '((-1/2 . "accidentals.kievanM1")
   (1/2 . "accidentals.kievan1")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Pitch Trill Heads
;; * Parentheses

(define-public (parentheses-item::calc-parenthesis-stencils grob)
  (let* ((font (ly:grob-default-font grob))
	 (lp (ly:font-get-glyph font "accidentals.leftparen"))
	 (rp (ly:font-get-glyph font "accidentals.rightparen")))

    (list lp rp)))

(define-public (parentheses-item::calc-angled-bracket-stencils grob)
  (let* ((parent (ly:grob-parent grob Y))
         (y-extent (ly:grob-extent parent parent Y))
         (half-thickness 0.05) ; should it be a property?
         (width 0.5) ; should it be a property?
         (angularity 1.5)  ; makes angle brackets
         (white-padding 0.1) ; should it be a property?
	 (lp (ly:stencil-aligned-to
                 (ly:stencil-aligned-to
                   (make-parenthesis-stencil y-extent
                                             half-thickness
                                             (- width)
                                             angularity)
                   Y CENTER)
                 X RIGHT))
         (lp-x-extent
           (interval-widen (ly:stencil-extent lp X) white-padding))
	 (rp (ly:stencil-aligned-to
                 (ly:stencil-aligned-to
                   (make-parenthesis-stencil y-extent
                                             half-thickness
                                             width
                                             angularity)
                   Y CENTER)
                 X LEFT))
          (rp-x-extent
            (interval-widen (ly:stencil-extent rp X) white-padding)))
    (set! lp (ly:make-stencil (ly:stencil-expr lp)
                              lp-x-extent
                              (ly:stencil-extent lp Y)))
    (set! rp (ly:make-stencil (ly:stencil-expr rp)
                              rp-x-extent
                              (ly:stencil-extent rp Y)))
    (list (stencil-whiteout lp)
          (stencil-whiteout rp))))

(define (parenthesize-elements grob . rest)
  (let* ((refp (if (null? rest)
		   grob
		   (car rest)))
	 (elts (ly:grob-object grob 'elements))
	 (x-ext (ly:relative-group-extent elts refp X))
	 (stencils (ly:grob-property grob 'stencils))
	 (lp (car stencils))
	 (rp (cadr stencils))
	 (padding (ly:grob-property grob 'padding 0.1)))

    (ly:stencil-add
     (ly:stencil-translate-axis lp (- (car x-ext) padding) X)
     (ly:stencil-translate-axis rp (+ (cdr x-ext) padding) X))))


(define-public (parentheses-item::print me)
  (let* ((elts (ly:grob-object me 'elements))
	 (y-ref (ly:grob-common-refpoint-of-array me elts Y))
	 (x-ref (ly:grob-common-refpoint-of-array me elts X))
	 (stencil (parenthesize-elements me x-ref))
	 (elt-y-ext (ly:relative-group-extent elts y-ref Y))
	 (y-center (interval-center elt-y-ext)))

    (ly:stencil-translate
     stencil
     (cons
      (- (ly:grob-relative-coordinate me x-ref X))
      (- y-center (ly:grob-relative-coordinate me y-ref Y))))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(define-public (chain-grob-member-functions grob value . funcs)
  (for-each
   (lambda (func)
     (set! value (func grob value)))
   funcs)

  value)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; falls/doits

(define-public (bend::print spanner)
  (define (close  a b)
    (< (abs (- a b)) 0.01))

  (let* ((delta-y (* 0.5 (ly:grob-property spanner 'delta-position)))
	 (left-span (ly:spanner-bound spanner LEFT))
	 (dots (if (and (grob::has-interface left-span 'note-head-interface)
			(ly:grob? (ly:grob-object left-span 'dot)))
		   (ly:grob-object left-span 'dot) #f))

	 (right-span (ly:spanner-bound spanner RIGHT))
	 (thickness (* (ly:grob-property spanner 'thickness)
		       (ly:output-def-lookup (ly:grob-layout spanner)
					     'line-thickness)))
	 (padding (ly:grob-property spanner 'padding 0.5))
	 (common (ly:grob-common-refpoint right-span
					  (ly:grob-common-refpoint spanner
								   left-span X)
					  X))
	 (common-y (ly:grob-common-refpoint spanner left-span Y))
	 (minimum-length (ly:grob-property spanner 'minimum-length 0.5))

	 (left-x (+ padding
		    (max
		     (interval-end (ly:grob-robust-relative-extent
				    left-span common X))
		     (if
		      (and dots
			   (close
			    (ly:grob-relative-coordinate dots common-y Y)
			    (ly:grob-relative-coordinate spanner common-y Y)))
		      (interval-end
		       (ly:grob-robust-relative-extent dots common X))
		      ;; TODO: use real infinity constant.
		      -10000))))
	 (right-x (max (- (interval-start
			   (ly:grob-robust-relative-extent right-span common X))
			  padding)
		       (+ left-x minimum-length)))
	 (self-x (ly:grob-relative-coordinate spanner common X))
	 (dx (- right-x left-x))
	 (exp (list 'path thickness
		    `(quote
		      (rmoveto
		       ,(- left-x self-x) 0

		       rcurveto
		       ,(/ dx 3)
		       0
		       ,dx ,(* 0.66 delta-y)
		       ,dx ,delta-y)))))

    (ly:make-stencil
     exp
     (cons (- left-x self-x) (- right-x self-x))
     (cons (min 0 delta-y)
	   (max 0 delta-y)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; grace spacing

(define-public (grace-spacing::calc-shortest-duration grob)
  (let* ((cols (ly:grob-object grob 'columns))
	 (get-difference
	  (lambda (idx)
	    (ly:moment-sub (ly:grob-property
			    (ly:grob-array-ref cols (1+ idx)) 'when)
			   (ly:grob-property
			    (ly:grob-array-ref cols idx) 'when))))

	 (moment-min (lambda (x y)
		       (cond
			((and x y)
			 (if (ly:moment<? x y)
			     x
			     y))
			(x x)
			(y y)))))

    (fold moment-min #f (map get-difference
			     (iota (1- (ly:grob-array-length cols)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fingering

(define-public (fingering::calc-text grob)
  (let* ((event (event-cause grob))
	 (digit (ly:event-property event 'digit)))

    (number->string digit 10)))

(define-public (string-number::calc-text grob)
  (let ((digit (ly:event-property (event-cause grob) 'string-number)))

    (number->string digit 10)))

(define-public (stroke-finger::calc-text grob)
  (let* ((digit (ly:event-property (event-cause grob) 'digit))
	 (text (ly:event-property (event-cause grob) 'text)))

    (if (string? text)
	text
	(vector-ref (ly:grob-property grob 'digit-names)
		    (1- (max (min 5 digit) 1))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dynamics

(define-public (hairpin::calc-grow-direction grob)
  (if (eq? (ly:event-property (event-cause grob) 'class) 'decrescendo-event)
      START
      STOP))

(define-public (dynamic-text-spanner::before-line-breaking grob)
  "Monitor left bound of @code{DynamicTextSpanner} for absolute dynamics.
If found, ensure @code{DynamicText} does not collide with spanner text by
changing @code{'attach-dir} and @code{'padding}.  Reads the
@code{'right-padding} property of @code{DynamicText} to fine tune space
between the two text elements."
  (let ((left-bound (ly:spanner-bound grob LEFT)))
    (if (grob::has-interface left-bound 'dynamic-text-interface)
	(let* ((details (ly:grob-property grob 'bound-details))
	       (left-details (ly:assoc-get 'left details))
	       (my-padding (ly:assoc-get 'padding left-details))
	       (script-padding (ly:grob-property left-bound 'right-padding 0)))

	  (and (number? my-padding)
	       (ly:grob-set-nested-property! grob
					     '(bound-details left attach-dir)
					     RIGHT)
	       (ly:grob-set-nested-property! grob
					     '(bound-details left padding)
					     (+ my-padding script-padding)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lyrics

(define-public (lyric-text::print grob)
  "Allow interpretation of tildes as lyric tieing marks."

  (let ((text (ly:grob-property grob 'text)))

    (grob-interpret-markup grob (if (string? text)
				    (make-tied-lyric-markup text)
				    text))))

(define-public ((grob::calc-property-by-copy prop) grob)
  (ly:event-property (event-cause grob) prop))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fret boards

(define-public (fret-board::calc-stencil grob)
  (grob-interpret-markup
   grob
   (make-fret-diagram-verbose-markup
    (ly:grob-property grob 'dot-placement-list))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; scripts

(define-public (script-interface::calc-x-offset grob)
  (ly:grob-property grob 'positioning-done)
  (let* ((shift (ly:grob-property grob 'toward-stem-shift 0.0))
	 (note-head-location
	  (ly:self-alignment-interface::centered-on-x-parent grob))
	 (note-head-grob (ly:grob-parent grob X))
	 (stem-grob (ly:grob-object note-head-grob 'stem)))

    (+ note-head-location
       ;; If the property 'toward-stem-shift is defined and the script
       ;; has the same direction as the stem, move the script accordingly.
       ;; Since scripts can also be over skips, we need to check whether
       ;; the grob has a stem at all.
       (if (ly:grob? stem-grob)
	   (let ((dir1 (ly:grob-property grob 'direction))
		 (dir2 (ly:grob-property stem-grob 'direction)))
	     (if (equal? dir1 dir2)
		 (let* ((common-refp (ly:grob-common-refpoint grob stem-grob X))
			(stem-location
			 (ly:grob-relative-coordinate stem-grob common-refp X)))
		   (* shift (- stem-location note-head-location)))
		 0.0))
	   0.0))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; instrument names

(define-public (system-start-text::print grob)
  (let* ((left-bound (ly:spanner-bound grob LEFT))
	 (left-mom (ly:grob-property left-bound 'when))
	 (name (if (moment<=? left-mom ZERO-MOMENT)
		   (ly:grob-property grob 'long-text)
		   (ly:grob-property grob 'text))))

    (if (and (markup? name)
	     (!= (ly:item-break-dir left-bound) CENTER))

	(grob-interpret-markup grob name)
	(ly:grob-suicide! grob))))

(define-public (system-start-text::calc-x-offset grob)
  (let* ((left-bound (ly:spanner-bound grob LEFT))
	 (left-mom (ly:grob-property left-bound 'when))
	 (layout (ly:grob-layout grob))
	 (indent (ly:output-def-lookup layout
				       (if (moment<=? left-mom ZERO-MOMENT)
					   'indent
					   'short-indent)
				       0.0))
	 (system (ly:grob-system grob))
	 (my-extent (ly:grob-extent grob system X))
	 (elements (ly:grob-object system 'elements))
	 (common (ly:grob-common-refpoint-of-array system elements X))
	 (total-ext empty-interval)
	 (align-x (ly:grob-property grob 'self-alignment-X 0))
	 (padding (min 0 (- (interval-length my-extent) indent)))
	 (right-padding (- padding
			   (/ (* padding (1+ align-x)) 2))))

    ;; compensate for the variation in delimiter extents by
    ;; calculating an X-offset correction based on united extents
    ;; of all delimiters in this system
    (let unite-delims ((l (ly:grob-array-length elements)))
      (if (> l 0)
	  (let ((elt (ly:grob-array-ref elements (1- l))))

	    (if (grob::has-interface elt 'system-start-delimiter-interface)
		(let ((dims (ly:grob-extent elt common X)))
		  (if (interval-sane? dims)
		      (set! total-ext (interval-union total-ext dims)))))
	    (unite-delims (1- l)))))

    (+
     (ly:side-position-interface::x-aligned-side grob)
     right-padding
     (- (interval-length total-ext)))))

(define-public (system-start-text::calc-y-offset grob)

  (define (live-elements-list me)
    (let ((elements (ly:grob-object me 'elements)))

      (filter! grob::is-live?
               (ly:grob-array->list elements))))

  (let* ((left-bound (ly:spanner-bound grob LEFT))
	 (live-elts (live-elements-list grob))
	 (system (ly:grob-system grob))
	 (extent empty-interval))

    (if (and (pair? live-elts)
	     (interval-sane? (ly:grob-extent grob system Y)))
	(let get-extent ((lst live-elts))
	  (if (pair? lst)
	      (let ((axis-group (car lst)))

		(if (and (ly:spanner? axis-group)
			 (equal? (ly:spanner-bound axis-group LEFT)
				 left-bound))
		    (set! extent (add-point extent
					    (ly:grob-relative-coordinate
					     axis-group system Y))))
		(get-extent (cdr lst)))))
	;; no live axis group(s) for this instrument name -> remove from system
	(ly:grob-suicide! grob))

    (+
     (ly:self-alignment-interface::y-aligned-on-self grob)
     (interval-center extent))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ambitus

(define-public (ambitus::print grob)
  (let ((heads (ly:grob-object grob 'note-heads)))

    (if (and (ly:grob-array? heads)
	     (= (ly:grob-array-length heads) 2))
	(let* ((common (ly:grob-common-refpoint-of-array grob heads Y))
	       (head-down (ly:grob-array-ref heads 0))
	       (head-up (ly:grob-array-ref heads 1))
	       (gap (ly:grob-property grob 'gap 0.35))
	       (point-min (+ (interval-end (ly:grob-extent head-down common Y))
			     gap))
	       (point-max (- (interval-start (ly:grob-extent head-up common Y))
			     gap)))

	  (if (< point-min point-max)
	      (let* ((layout (ly:grob-layout grob))
		     (line-thick (ly:output-def-lookup layout 'line-thickness))
		     (blot (ly:output-def-lookup layout 'blot-diameter))
		     (grob-thick (ly:grob-property grob 'thickness 2))
		     (width (* line-thick grob-thick))
		     (x-ext (symmetric-interval (/ width 2)))
		     (y-ext (cons point-min point-max))
		     (line (ly:round-filled-box x-ext y-ext blot))
		     (y-coord (ly:grob-relative-coordinate grob common Y)))

		(ly:stencil-translate-axis line (- y-coord) Y))
	      empty-stencil))
	(begin
	  (ly:grob-suicide! grob)
	  (list)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  laissez-vibrer tie
;;
;;  needed so we can make laissez-vibrer a pure print
;;
(define-public (laissez-vibrer::print grob)
 (ly:tie::print grob))


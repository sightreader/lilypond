;;;; This file is part of LilyPond, the GNU music typesetter.
;;;;
;;;; Copyright (C) 2004--2015 Han-Wen Nienhuys <hanwen@xs4all.nl>
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

;; TODO:
;;
;; lookup-font should be written in  C.
;;

;; We have a tree, where each level of the tree is a qualifier
;; (eg. encoding, family, shape, series etc.)  this defines the levels
;; in the tree.  The first one is encoding, so we can directly select
;; between text or music in the first step of the selection.
(define default-qualifier-order
  '(font-encoding font-family font-shape font-series))

(define-class <Font-tree-element>
  ())

(define-class <Font-tree-leaf> (<Font-tree-element>)
  (default-size #:init-keyword #:default-size)
  (size-vector  #:init-keyword #:size-vector))

(define-class <Font-tree-node> (<Font-tree-element>)
  (qualifier #:init-keyword #:qualifier  #:accessor font-qualifier)
  (default #:init-keyword #:default #:accessor font-default)
  (children #:init-keyword #:children #:accessor font-children))

(define (make-font-tree-leaf size size-font-vector)
  (make <Font-tree-leaf> #:default-size size #:size-vector size-font-vector))

(define (make-font-tree-node
         qualifier default)
  (make <Font-tree-node>
    #:qualifier qualifier
    #:default default
    #:children (make-hash-table 11)))

(define-method (display (leaf <Font-tree-leaf>) port)
  (for-each (lambda (x) (display x port))
            (list
             "#<Font-size-family:\n"
             (slot-ref leaf 'default-size)
             (slot-ref leaf 'size-vector)
             "#>"
             )))

(define-method (display (node <Font-tree-node>) port)
  (for-each
   (lambda (x)
     (display x port))
   (list
    "Font_node {\nqual: "
    (font-qualifier node)
    "(def: "
    (font-default node)
    ") {\n"))
  (for-each
   (lambda (x)
     (display "\n")
     (display (car x) port)
     (display "=" port)
     (display (cdr x) port))
   (hash-table->alist (font-children node)))
  (display "} }\n"))


(define-method (add-font (node <Font-tree-node>) fprops size-family)
  (define (assoc-delete key alist)
    (assoc-remove! (list-copy alist) key))

  (define (make-node fprops size-family)
    (if (null? fprops)
        (make-font-tree-leaf (car size-family) (cdr size-family))
        (let* ((qual (next-qualifier default-qualifier-order fprops)))
          (make-font-tree-node qual
                               (assoc-get qual fprops)))))

  (define (next-qualifier order props)
    (cond
     ((and (null? props) (null? order))
      #f)
     ((null? props) (car order))
     ((null? order) (caar props))
     (else
      (if (assoc-get (car order) props)
          (car order)
          (next-qualifier (cdr order) props)))))

  (let* ((q (font-qualifier node))
         (d (font-default node))
         (v (assoc-get q fprops d))
         (new-fprops (assoc-delete q fprops))
         (child (hashq-ref (slot-ref node 'children)
                           v #f)))
    (if (not child)
        (begin
          (set! child (make-node new-fprops size-family))
          (hashq-set! (slot-ref node 'children) v child)))
    (if (pair? new-fprops)
        (add-font child new-fprops size-family))))

(define-method (add-font (node <Font-tree-leaf>) fprops size-family)
  (throw "must add to node, not leaf"))

(define-method (g-lookup-font (node <Font-tree-node>) alist-chain)
  (let* ((qual (font-qualifier node))
         (def (font-default node))
         (val (chain-assoc-get qual alist-chain def))
         (desired-child (hashq-ref (font-children node) val)))

    (if desired-child
        (g-lookup-font desired-child alist-chain)
        (g-lookup-font (hashq-ref (font-children node) def) alist-chain))))

(define-method (g-lookup-font (node <Font-tree-leaf>) alist-chain)
  node)

;; two step call is handy for debugging.
(define (lookup-font node alist-chain)
  (g-lookup-font node alist-chain))

;; TODO - we could actually construct this by loading all OTFs and
;; inspecting their design size fields.
(define-public feta-design-size-mapping
  '((11 . 11.22)
    (13 . 12.60)
    (14 . 14.14)
    (16 . 15.87)
    (18 . 17.82)
    (20 . 20)
    (23 . 22.45)
    (26 . 25.20)))

(define-public pango-default-fonts
  '((roman      . "Century Schoolbook L")
    (sans       . "Nimbus Sans L")
    (typewriter . "Nimbus Mono L")))

;; Each size family is a vector of fonts, loaded with a delay.  The
;; vector should be sorted according to ascending design size.
(define-public (add-music-fonts node family name brace design-size-alist factor)
  "Set up a music font with or without optical variants.

Arguments:
@itemize
@item
@var{node} is the font tree to modify.

@item
@var{family} is the family name of the music font.

@item
@var{name} is the basename for the music font.
@file{@var{name}-<designsize>.otf} should be the music font,

@item
@var{brace} is the basename for the brace font.
@file{@var{brace}-brace.otf} should have piano braces.

@item
@var{design-size-alist} is a list of @code{(rounded . designsize)}.
@code{rounded} is a suffix for font filenames, while @code{designsize}
should be the actual design size.  The latter is used for text fonts
loaded through pango/@/fontconfig.  For single-sized fonts (i.e. the
new alternative fonts that don't have optical variants) pass
@code{'((20 . 20))}, as the function uses the length of this arguemnt
to discern the proper font name handling.

@item
@var{factor} is a size factor relative to the default size that is being
used.  This is used to select the proper design size for the text fonts.
@end itemize"
  (let
   ;; Determine behaviour from the given design size alist:
   ;; single-sized fonts pass '((20 . 20))
   ((has-optical-sizes (> (length design-size-alist) 1)))
   (for-each
    (lambda (x)
      (add-font node
                (list (cons 'font-encoding (car x))
                      (cons 'font-family family))
                (cons (* factor (cadr x))
                      (caddr x))))

    `((fetaText ,(ly:pt 20.0)
                ,(list->vector
                  (map
                   (lambda (size-tup)
                     (let
                      (;; filter path from font name if given
                       ;; (ly:system-font-load seems to need the path
                       ;;  while selecting the fetaText font does not
                       ;;  work with it).
                       (font-name
                        (substring name
                          (+ 1 (or (string-rindex name #\/) -1))))
                       ;; only pass size-tuplet-string for opticals fonts
                       (size-str
                        (if has-optical-sizes
                            (format "-~a" (car size-tup)) ""))
                       (point-size (ly:pt (cdr size-tup))))
                      (cons point-size
                        (format "~a~a ~a" font-name size-str point-size))))
                   design-size-alist
                   )))
      (fetaMusic ,(ly:pt 20.0)
                 ,(list->vector
                   (map (lambda (size-tup)
                          (delay (ly:system-font-load
                                  (let
                                   ((size-str
                                     (if has-optical-sizes
                                         (format "-~a" (car size-tup))
                                         "")))
                                  (format #f "~a~a" name size-str)))))
                        design-size-alist
                        )))
      (fetaBraces ,(ly:pt 20.0)
                  #(,(delay (ly:system-font-load
                             (format #f "~a-brace" brace)))))
      ))))


(define-public (font-exists font-name)
  "Return the full path to the given font if it is visible for font-config.
We can't check against the file name, and the fallback font
isn't stable enough."
  (let ((font-file (ly:font-config-get-font-file font-name)))
    (if (string=? (string-downcase font-name)
          (string-downcase (ly:ttf-ps-name font-file)))
        font-file
        #f)))

(define-public (font-path name)
  "Return the path to the font that is given by its font name.
If this font isn't found by fontconfig #f is returned."
  (let ((font-file (font-exists name)))
    (if font-file
      (substring font-file
        0
        (or (+ 1 (string-rindex font-file #\/) )
            (string-length font-file)))
      #f)))

(define-public setNotationFont
  (define-void-function (parser location options font-name)
    ((ly:context-mod?) string?)
    "Set up a music font with or without optical sizes,
optionally set or don't set text fonts.

@var{options} is a an optional set of key=value pairs.  Known
options are: 

@itemize
@item @var{brace} Set the brace font to the given name.  If this
is @var{none} the default Emmentaler will be used.

@item @var{text-fonts = none} will suppress the setting of any text
fonts.  This has to be done later using @code{add-pango-fonts},
which can be useful when defining music fonts in a stylesheet
without imposing text fonts.

@item @var{roman} Set the font family for roman style.

@item @var{sans} Set the font family for sans serif style.

@item @var{typewriter} Set the font family for typewriter style.


@end itemize

The function can load fonts that have optical variants or that
have not.  In any case only the name of the font has to be
provided, which is read case insensitive.
"
    (let*
     ;; Font name is lowercase
     ((name (string-downcase font-name))

      ;; create an alist with options if they are given.
      ;; if the argument is not given or no options are defined
      ;; we have an empty list.
      (options
       (if options
           (map
            (lambda (o)
              (cons (cadr o) (caddr o)))
            (ly:get-context-mods options))
           '()))

      ;; if text-fonts = none is given
      ;; we don't set any text fonts at all
      (text-fonts
       (let ((tf-opt (assoc-ref options 'text-fonts)))
         (if (and tf-opt
                  (string=? tf-opt "none"))
             #f #t)))

      ;; Default text fonts
      (roman (or (assoc-ref options 'roman)
                 (assoc-ref pango-default-fonts 'roman)))
      (sans (or (assoc-ref options 'sans)
                (assoc-ref pango-default-fonts 'sans)))
      (typewriter (or (assoc-ref options 'typewriter)
                      (assoc-ref pango-default-fonts 'typewriter)))


      (brace-option (assoc-ref options 'brace))
      (brace
       (if (not brace-option)
           name
           (string-downcase brace-option)))

      ;; Determine if the font has optical sizes or not.
      ;; (We only check for the presence of one -20 font.
      ;;  If this should lead to errors they indicate a real
      ;;  issue with the installation, so we don't catch them.)
      (opticals-path (font-path (string-append name "-20")))
      (fixed-path (font-path name))
      ;; Only one path may be set after this.
      ;; If both should be successful we take the opticals first.
      (use-path (or opticals-path fixed-path))

      ;; Find the location of the brace font
      (brace-path (font-path (string-append brace "-brace")))

      ;; use 'real' or 'dummy' design-size mapping
      ;; for the opticals or fixed-size fonts
      (design-size-alist
       (if opticals-path feta-design-size-mapping '((20 . 20))))

      ;; Create font tree object and the \paper context
      (fonts (create-empty-font-tree))
      (paper (ly:parser-lookup parser '$defaultpaper))
      (staff-height (ly:output-def-lookup paper 'staff-height))
      (pt (ly:output-def-lookup paper 'pt))
      (factor (/ staff-height pt 20))
      )

     ;; Handle non-present fonts
     (if (not use-path)
         (begin
          (ly:input-warning location
            (format "Font \"~a\" not found. Fall back to Emmentaler" name))
          ;; set opticals-path because that will select the
          ;; actual font loading routine
          (set! opticals-path #t)
          ;; set music font fallback
          (set! use-path (font-path "emmentaler-20"))
          (set! name "emmentaler-20")))
     (if (not brace-path)
         (begin
          (ly:input-warning location
            (format "Brace font \"~a\" not found. Fall back to Emmentaler" brace))
          (set! brace-path (font-path "emmentaler-20"))
          (set! brace "emmentaler")))

     ;; finally add the determined music font to the font tree
     (add-music-fonts fonts 'feta
       (string-append use-path name)
       (string-append brace-path brace)
       design-size-alist factor)

     ;; If not suppressed through the text-fonts = none option
     ;; set the text fonts too
     (if text-fonts
         (let ((factor (/ staff-height pt 20)))
           (add-pango-fonts fonts 'roman roman factor)
           (add-pango-fonts fonts 'sans sans factor)
           (add-pango-fonts fonts 'typewriter typewriter factor)))

     ;; finally set the fonts in the output definition
     (ly:output-def-set-variable! paper 'fonts fonts))))



(define-public (add-pango-fonts node lily-family family factor)
  ;; Synchronized with the `text-font-size' variable in
  ;; layout-set-absolute-staff-size-in-module (see paper.scm).
  (define text-font-size (ly:pt (* factor 11.0)))

  (define (add-node shape series)
    (add-font node
              `((font-family . ,lily-family)
                (font-shape . ,shape)
                (font-series . ,series)
                (font-encoding . latin1) ;; ugh.
                )
              `(,text-font-size
                . #(,(cons
                      (ly:pt 12)
                      (ly:make-pango-description-string
                       `(((font-family . ,family)
                          (font-series . ,series)
                          (font-shape . ,shape)))
                       (ly:pt 12)))))))

  (add-node 'upright 'normal)
  (add-node 'caps 'normal)
  (add-node 'upright 'bold)
  (add-node 'italic 'normal)
  (add-node 'italic 'bold))


; TODO
; Currently this only *adds* a pango font to the font tree
; when the family has not been set already, which is only
; when \setNotationFont has been used with the "text-fonts = none" option.
;
; There should be a version of add-pango-fonts that
; adds *or replaces* a font node in the tree.
;
(define-public setTextFont
  (define-void-function (parser location family name)
    (symbol? string?)
    "Set any text font if setting of text fonts has been
explicitly omitted in \\setNotationFont.
Arguments:
@itemize

@item
@var{family} is the family name of the text font (roman, sans, typewriter).

@item
@var{name} is the name for the text font.
@end itemize"
    (let*
     ((paper (ly:parser-lookup parser '$defaultpaper))
      (fonts (ly:output-def-lookup paper 'fonts))
      (staff-height (ly:output-def-lookup paper 'staff-height))
      (pt (ly:output-def-lookup paper 'pt))
      (font-exists (font-path (string-downcase name)))
      )
     (if (not font-exists)
         (let ((fallback (assoc-ref pango-default-fonts family)))
                 (ly:input-warning location
                   (format "Requested text font \"~a\" not found. Fall back to \"~a\"."
                     name fallback))
                 (set! name fallback)))
     (add-pango-fonts fonts family name (/ staff-height pt 20))
     (ly:output-def-set-variable! paper 'fonts fonts))
         )
     )

; This function allows the user to change the specific fonts, leaving others
; to the default values. This way, "make-pango-font-tree"'s syntax doesn't
; have to change from the user's perspective.
;
; Usage:
;   \paper {
;     #(define fonts
;       (set-global-fonts
;        #:music "gonville"  ; (the main notation font)
;        #:roman "FreeSerif" ; (the main/serif text font)
;       ))
;   }
;
; Leaving out "#:brace", "#:sans", and "#:typewriter" leave them at
; "emmentaler", "sans-serif", and "monospace", respectively. All fonts are
; still accesible through the usual scheme symbols: 'feta, 'roman, 'sans, and
; 'typewriter.
(define*-public (set-global-fonts #:key
  (music "emmentaler")
  (brace "emmentaler")
  (roman (assoc-ref pango-default-fonts 'roman))
  (sans (assoc-ref pango-default-fonts 'sans))
  (typewriter (assoc-ref pango-default-fonts 'typewriter))
  (factor 1))
  (let ((n (make-font-tree-node 'font-encoding 'fetaMusic)))
    (add-music-fonts n 'feta music brace feta-design-size-mapping factor)
    (add-pango-fonts n 'roman roman factor)
    (add-pango-fonts n 'sans sans factor)
    (add-pango-fonts n 'typewriter typewriter factor)
    n))

;; *****************************************************************************
(define*-public (create-empty-font-tree)
  (let ((n (make-font-tree-node 'font-encoding 'fetaMusic)))
    n))
;; *****************************************************************************

(define-public (make-pango-font-tree roman-str sans-str typewrite-str factor)
  (let ((n (make-font-tree-node 'font-encoding 'fetaMusic)))
    (add-music-fonts n 'feta "emmentaler" "emmentaler" feta-design-size-mapping factor)
    (add-pango-fonts n 'roman roman-str factor)
    (add-pango-fonts n 'sans sans-str factor)
    (add-pango-fonts n 'typewriter typewrite-str factor)
    n))

(define-public (make-century-schoolbook-tree factor)
  (make-pango-font-tree
   (assoc-ref pango-default-fonts 'roman)
   (assoc-ref pango-default-fonts 'sans)
   (assoc-ref pango-default-fonts 'typewriter)
   factor))

(define-public all-text-font-encodings
  '(latin1))

(define-public all-music-font-encodings
  '(fetaBraces
    fetaMusic
    fetaText))

(define-public (magstep s)
  (exp (* (/ s 6) (log 2))))

(define-public (magnification->font-size m)
  (* 6 (/ (log m) (log 2))))

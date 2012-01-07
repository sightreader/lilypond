%% DO NOT EDIT this file manually; it is automatically
%% generated from LSR http://lsr.dsi.unimi.it
%% Make any changes in LSR itself, or in Documentation/snippets/new/ ,
%% and then run scripts/auxiliar/makelsr.py
%%
%% This file is in the public domain.
\version "2.14.0"

\header {
  lsrtags = "pitches"

%% Translation of GIT committish: 8b93de6ce951b7b14bc7818f31019524295b990f
doctitlees = "Transportar música con el menor número de alteraciones"
texidoces = "
Este ejemplo utiliza código de Scheme para forzar las
modificaciones enarmónicas de las notas, y así tener el menor
número de alteraciones accidentales. En este caso se aplican las
siguientes reglas:

@itemize
@item
Se quitan las dobles alteraciones

@item
Si sostenido -> Do

@item
Mi sistenido -> Fa

@item
Do bemol -> Si

@item
Fa bemol -> Mi

@end itemize

De esta forma se selecciona el mayor número de notas enarmónicas
naturales.

"


%% Translation of GIT committish: 0a868be38a775ecb1ef935b079000cebbc64de40
  doctitlede = "Noten mit minimaler Anzahl an Versetzungszeichen transponieren."
  texidocde = "Dieses Beispiel benutzt Scheme-Code, um enharmonische
Verwechslungen für Noten zu erzwingen, damit nur eine minimale Anzahl
an Versetzungszeichen ausgegeben wird.  In diesem Fall gelten die
folgenden Regeln:

@itemize
@item
Doppelte Versetzungszeichen sollen entfernt werden

@item
His -> C

@item
Eis -> F

@item
Ces -> B

@item
Fes -> E

@end itemize

Auf diese Art werden am meisten natürliche Tonhöhen als enharmonische
Variante gewählt.
"


%% Translation of GIT committish: d9d1da30361a0bcaea1ae058eb1bc8dd3a5b2e4c
  texidocfr = "
Cet exemple, grâce à un peu de code Scheme, donne la priorité aux
enharmoniques  afin de limiter le nombre d'altérations supplémentaires.
La règle appliquable est :

@itemize
@item
Les altérations doubles sont supprimées

@item
Si dièse -> Do

@item
Mi dièse -> Fa

@item
Do bémol -> Si

@item
Fa bémol -> Mi

@end itemize

Cette façon de procéder aboutit à plus d'enharmoniques naturelles.

"

  doctitlefr = "Transposition et réduction du nombre d'altérations accidentelles"

  texidoc = "
This example uses some Scheme code to enforce enharmonic modifications
for notes in order to have the minimum number of accidentals.  In this
case, the following rules apply:

Double accidentals should be removed


B sharp -> C


E sharp -> F


C flat -> B


F flat -> E


In this manner, the most natural enharmonic notes are chosen.

"
  doctitle = "Transposing pitches with minimum accidentals (\"Smart\" transpose)"
} % begin verbatim

#(define (naturalize-pitch p)
   (let ((o (ly:pitch-octave p))
         (a (* 4 (ly:pitch-alteration p)))
         ;; alteration, a, in quarter tone steps,
         ;; for historical reasons
         (n (ly:pitch-notename p)))
     (cond
      ((and (> a 1) (or (eq? n 6) (eq? n 2)))
       (set! a (- a 2))
       (set! n (+ n 1)))
      ((and (< a -1) (or (eq? n 0) (eq? n 3)))
       (set! a (+ a 2))
       (set! n (- n 1))))
     (cond
      ((> a 2) (set! a (- a 4)) (set! n (+ n 1)))
      ((< a -2) (set! a (+ a 4)) (set! n (- n 1))))
     (if (< n 0) (begin (set! o (- o 1)) (set! n (+ n 7))))
     (if (> n 6) (begin (set! o (+ o 1)) (set! n (- n 7))))
     (ly:make-pitch o n (/ a 4))))

#(define (naturalize music)
   (let ((es (ly:music-property music 'elements))
         (e (ly:music-property music 'element))
         (p (ly:music-property music 'pitch)))
     (if (pair? es)
         (ly:music-set-property!
          music 'elements
          (map (lambda (x) (naturalize x)) es)))
     (if (ly:music? e)
         (ly:music-set-property!
          music 'element
          (naturalize e)))
     (if (ly:pitch? p)
         (begin
           (set! p (naturalize-pitch p))
           (ly:music-set-property! music 'pitch p)))
     music))

naturalizeMusic =
#(define-music-function (parser location m)
   (ly:music?)
   (naturalize m))

music = \relative c' { c4 d e g }

\score {
  \new Staff {
    \transpose c ais { \music }
    \naturalizeMusic \transpose c ais { \music }
    \transpose c deses { \music }
    \naturalizeMusic \transpose c deses { \music }
  }
  \layout { }
}


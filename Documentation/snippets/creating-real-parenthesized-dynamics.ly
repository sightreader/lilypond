%% DO NOT EDIT this file manually; it is automatically
%% generated from LSR http://lsr.di.unimi.it
%% Make any changes in LSR itself, or in Documentation/snippets/new/ ,
%% and then run scripts/auxiliar/makelsr.py
%%
%% This file is in the public domain.
\version "2.20.0"

\header {
  lsrtags = "expressive-marks, text, workaround"

  texidoc = "
Although the easiest way to add parentheses to a dynamic mark is to use
a @code{\\markup} block, this method has a downside: the created
objects will behave like text markups, and not like dynamics.

However, it is possible to create a similar object using the equivalent
Scheme code (as described in the Notation Reference), combined with the
@code{make-dynamic-script} function. This way, the markup will be
regarded as a dynamic, and therefore will remain compatible with
commands such as @code{\\dynamicUp} or @code{\\dynamicDown}.



"
  doctitle = "Creating \"real\" parenthesized dynamics"
} % begin verbatim

paren =
#(define-event-function (dyn) (ly:event?)
   (make-dynamic-script
    #{ \markup \concat {
         \normal-text \italic \fontsize #2 (
	 \pad-x #0.2 #(ly:music-property dyn 'text)
	 \normal-text \italic \fontsize #2 )
       }
    #}))

\relative c'' {
  c4\paren\f c c \dynamicUp c\paren\p
}

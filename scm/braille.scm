;;;; This file is part of LilyPond, the GNU music typesetter.
;;;;
;;;; Copyright (C) 2016 Ralph Little
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
;;
(define-public (write-embossings embossings basename . rest)
  (let ((embossing-ext (ly:get-option 'braille-extension)))
    (let
        loop
      ((perfs embossings)
       (count (if (null? rest) 0 (car rest))))
      (if (pair? perfs)
          (let ((perf (car perfs)))
            (ly:embossing-write
             perf
             (if (> count 0)
                 (format #f "~a-~a.~a" basename count embossing-ext)
                 (format #f "~a.~a" basename midi-ext))
             (embossing-name-from-header (ly:embossing-header perf)))
            (loop (cdr perfs) (1+ count)))))))

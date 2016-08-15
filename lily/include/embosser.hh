/*
  This file is part of LilyPond, the GNU music typesetter.

  Copyright (C) 2016 Ralph Little

  LilyPond is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  LilyPond is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with LilyPond.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef EMBOSSER_HH
#define EMBOSSER_HH

#include "grob-info.hh"
#include "translator.hh"

/* Convert a music definition into a Braille representation.  */
class Embosser : public Translator
{
public:
  DECLARE_CLASSNAME (Embosser);
  friend class Embosser_group;
  Embosser_group *get_daddy_embosser () const;

};

#endif /* EMBOSSER_HH */


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

#include "context.hh"
#include "embosser-group.hh"
#include "warn.hh"

Embosser_group *
Embosser::get_daddy_embosser () const
{
  return dynamic_cast<Embosser_group *> (get_daddy_translator ());
}




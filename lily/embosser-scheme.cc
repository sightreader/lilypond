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

#include "embosser-output.hh"

LY_DEFINE (ly_embossing_write, "ly:embossing-write",
	   2, 0, 0, (SCM embossing, SCM filename),
	   "Write @var{embossing} to @var{filename}.")
{
  LY_ASSERT_SMOB (Embosser_output, embossing, 1);
  LY_ASSERT_TYPE (scm_is_string, filename, 2);

  unsmob<Embosser_output> (embossing)->write_output (ly_scm2string (filename));
  return SCM_UNSPECIFIED;
}


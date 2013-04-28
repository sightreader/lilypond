/*
  This file is part of LilyPond, the GNU music typesetter.

  Copyright (C) 1997--2012 Han-Wen Nienhuys <hanwen@xs4all.nl>

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

#include "stencil.hh"

#include "main.hh"
#include "font-metric.hh"
#include "input.hh"
#include "string-convert.hh"
#include "warn.hh"

#include "ly-smobs.icc"

Stencil::Stencil ()
{
  expr_ = SCM_EOL;
  set_empty (true);
}

Stencil::Stencil (Box b, SCM func)
{
  expr_ = func;
  dim_ = b;
}

int
Stencil::print_smob (SCM, SCM port, scm_print_state *)
{
  scm_puts ("#<Stencil ", port);
  scm_puts (" >", port);
  return 1;
}

SCM
Stencil::mark_smob (SCM smob)
{
  Stencil *s = (Stencil *) SCM_CELL_WORD_1 (smob);
  return s->expr_;
}

IMPLEMENT_SIMPLE_SMOBS (Stencil);
IMPLEMENT_TYPE_P (Stencil, "ly:stencil?");
IMPLEMENT_DEFAULT_EQUAL_P (Stencil);

Interval
Stencil::extent (Axis a) const
{
  return dim_[a];
}

bool
Stencil::is_empty () const
{
  return (expr_ == SCM_EOL
          || dim_.is_empty ());
}

bool
Stencil::is_empty (Axis a) const
{
  return dim_.is_empty (a);
}

SCM
Stencil::expr () const
{
  return expr_;
}

Box
Stencil::extent_box () const
{
  return dim_;
}

void
Stencil::rotate (Real a, Offset off)
{
  rotate_degrees (a * 180 / M_PI, off);
}

/*
  Rotate this stencil around the point ABSOLUTE_OFF.

 */
void
Stencil::rotate_degrees_absolute (Real a, Offset absolute_off)
{
  const Real x = absolute_off[X_AXIS];
  const Real y = absolute_off[Y_AXIS];

  /*
   * Build scheme expression (processed in stencil-interpret.cc)
   */
  /* TODO: by hanwenn 2008/09/10 14:38:56:
   * in effect, this copies the underlying expression.  It might be a
   * little bit nicer to mirror this in the api, ie. make a
   *         Stencil::rotated()
   * and have Stencil::rotate be an abbrev of
   *         *this = rotated()
   */

  expr_ = scm_list_n (ly_symbol2scm ("rotate-stencil"),
                      scm_list_2 (scm_from_double (a),
                                  scm_cons (scm_from_double (x), scm_from_double (y))),
                      expr_, SCM_UNDEFINED);

  /*
   * Calculate the new bounding box
   */
  Box shifted_box = extent_box ();
  shifted_box.translate (-absolute_off);

  vector<Offset> pts;
  pts.push_back (Offset (shifted_box.x ().at (LEFT), shifted_box.y ().at (DOWN)));
  pts.push_back (Offset (shifted_box.x ().at (RIGHT), shifted_box.y ().at (DOWN)));
  pts.push_back (Offset (shifted_box.x ().at (RIGHT), shifted_box.y ().at (UP)));
  pts.push_back (Offset (shifted_box.x ().at (LEFT), shifted_box.y ().at (UP)));

  const Offset rot = complex_exp (Offset (0, a * M_PI / 180.0));
  dim_.set_empty ();
  for (vsize i = 0; i < pts.size (); i++)
    dim_.add_point (pts[i] * rot + absolute_off);
}

/*
  Rotate this stencil around the point RELATIVE_OFF.

  RELATIVE_OFF is measured in terms of the extent of the stencil, so
  -1 = LEFT/DOWN edge, 1 = RIGHT/UP edge.
 */
void
Stencil::rotate_degrees (Real a, Offset relative_off)
{
  /*
   * Calculate the center of rotation
   */
  const Real x = extent (X_AXIS).linear_combination (relative_off[X_AXIS]);
  const Real y = extent (Y_AXIS).linear_combination (relative_off[Y_AXIS]);
  rotate_degrees_absolute (a, Offset (x, y));
}

void
Stencil::translate (Offset o)
{
  Axis a = X_AXIS;
  while (a < NO_AXES)
    {
      if (isinf (o[a])
          || isnan (o[a])

          // ugh, hardcoded.
          || fabs (o[a]) > 1e6)
        {
          programming_error (String_convert::form_string ("Improbable offset for stencil: %f staff space", o[a])
                             + "\n"
                             + "Setting to zero.");
          o[a] = 0.0;
          if (strict_infinity_checking)
            scm_misc_error (__FUNCTION__, "Improbable offset.", SCM_EOL);
        }
      incr (a);
    }

  expr_ = scm_list_n (ly_symbol2scm ("translate-stencil"),
                      ly_offset2scm (o),
                      expr_, SCM_UNDEFINED);
  if (!is_empty ())
    dim_.translate (o);
}

void
Stencil::translate_axis (Real x, Axis a)
{
  Offset o (0, 0);
  o[a] = x;
  translate (o);
}

void
Stencil::scale (Real x, Real y)
{
  expr_ = scm_list_3 (ly_symbol2scm ("scale-stencil"),
                      scm_list_2 (scm_from_double (x),
                                  scm_from_double (y)),
                      expr_);
  dim_[X_AXIS] *= x;
  dim_[Y_AXIS] *= y;
}

void
Stencil::add_stencil (Stencil const &s)
{
  expr_ = scm_list_3 (ly_symbol2scm ("combine-stencil"), s.expr_, expr_);
  dim_.unite (s.dim_);
}

void
Stencil::set_empty (bool e)
{
  if (e)
    {
      dim_[X_AXIS].set_empty ();
      dim_[Y_AXIS].set_empty ();
    }
  else
    {
      dim_[X_AXIS] = Interval (0, 0);
      dim_[Y_AXIS] = Interval (0, 0);
    }
}

void
Stencil::align_to (Axis a, Real x)
{
  if (is_empty (a))
    return;

  Interval i (extent (a));
  translate_axis (-i.linear_combination (x), a);
}

/*  See scheme Function.  */

// The model for Stencil::add_at_edge is (when adding at the right
// edge) to place the reference point of the result right by the
// addition of the "right advancement" of the left stencil and the
// "left advancement" of the right stencil.  The resulting stencil
// inherits the "left advancement" from the left stencil, and the
// "right advancement" from the right stencil.
//
// Ideally, the resulting dimensions would be the union of the
// respective ranges of the original stencils.  However, the absence
// of explicit advancements in the stencil description means that
// spacing changes have to be effected by tampering with the
// dimensions, resulting in an unreliable bounding box when spacing
// without actual content is involved.
//
// The left advancement is defined as
// max (0, -extent (X_AXIS) [LEFT])
// and the right advancement is defined as
// max (0, extent (X_AXIS) [RIGHT])
//
// Spacing changes and translation will work unreliably when
// advancements and extents are decoupled because of this limiting
// behavior.
//
// Any stencil that is empty in the orthogonal axis is spacing.
// Spacing is not subjected to the max (0) rule and can thus be
// negative.

void
Stencil::add_at_edge (Axis a, Direction d, Stencil const &s, Real padding,
                      bool overdraw)
{
  // Material that is empty in the axis of reference can't be sensibly
  // combined.  It does, however, affect the orthogonal stencil
  // dimension, like with \line { \vspace #1 }

  if (s.is_empty (a))
    {
      dim_.unite (s.extent_box ());
      return;
    }
  if (is_empty (a))
    {
      // Don't just *this = s since this stomps over memory management
      expr_ = s.expr ();
      dim_.unite (s.extent_box ());
      return;
    }

  Interval first_extent = extent (a);
  Interval next_extent = s.extent (a);

  bool first_is_spacing = is_empty (other_axis (a));
  bool next_is_spacing = s.is_empty (other_axis (a));

  if (next_is_spacing)
    {
      dim_[a][d] += d * next_extent.delta ();
      return;
    }

  if (first_is_spacing)
    {
      expr_ = s.expr ();
      dim_ = s.extent_box ();
      translate_axis (d * first_extent.delta (), a);
      dim_[a][-d] -= d * first_extent.delta ();
      return;
    }

  Real offset = d * padding;

  // symmetry of composition would ask for
  // if (d * first_extent [d] > 0)
  // as a precondition.  However, for "add_at_edge" there is
  // reasonable expectation that any previous translation of the
  // original stencil does not cause a difference in the arrangement
  // of the result.

  offset += first_extent [d];

  // We still shift the closer edge of the added stencil to the
  // right/up if it would end up negative when adding to the
  // right/top (and it has backward spacing or descenders), or to the
  // left/down if it would end up positive when adding to the
  // left/bottom (which should put typical stencils on a reasonable
  // position).

  if (d * next_extent [-d] < 0)
    offset -= next_extent [-d];

  Stencil toadd (s);
  toadd.translate_axis (offset, a);

  // We don't use add_stencil here because its drawing order is not
  // really working well for all applications
  if (overdraw)
    expr_ = scm_list_3 (ly_symbol2scm ("combine-stencil"), expr_, toadd.expr_);
  else
    expr_ = scm_list_3 (ly_symbol2scm ("combine-stencil"), toadd.expr_, expr_);
  dim_.unite (toadd.dim_);
}

Stencil
Stencil::in_color (Real r, Real g, Real b) const
{
  Stencil new_stencil (extent_box (),
                       scm_list_3 (ly_symbol2scm ("color"),
                                   scm_list_3 (scm_from_double (r),
                                               scm_from_double (g),
                                               scm_from_double (b)),
                                   expr ()));
  return new_stencil;
}

/* convenience */
Stencil
Stencil::translated (Offset z) const
{
  Stencil s (*this);
  s.translate (z);
  return s;
}

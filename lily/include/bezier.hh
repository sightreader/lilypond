/*
  bezier.hh -- declare Bezier and Bezier_bow

  (c) 1998 Jan Nieuwenhuizen <jan@digicash.com>
*/

#ifndef BEZIER_HH
#define BEZIER_HH

#ifndef STANDALONE
#include "lily-proto.hh"
#endif

#include "real.hh"
#include "curve.hh"

/**
  Simple bezier curve
 */
class Bezier
{
public:
  Bezier (int steps_i);

  /**
  Calculate bezier curve into Offset (x,y) array.
  */
  void calc ();

  void set (Array<Offset> points);

  /**
  Return y that goes with x by interpolation.
  */
  Real y (Real x);

  Curve curve_;
  Curve control_;
};

/**
  Implement bow specific bezier curve
 */
class Bezier_bow : public Bezier
{
public:
  Bezier_bow (Paper_def* paper_l);

  /**
   Calculate bezier curve for bow from bow parameters.
   */
  void blow_fit ();
  Real calc_f (Real height);
  void calc ();
  void calc_controls ();
  void calc_default (Real h);
  void calc_return (Real begin_alpha, Real end_alpha);
  bool check_fit_bo ();
  Real check_fit_f ();
  void set (Array<Offset> points, int dir);
  void transform ();
  void transform_controls_back ();

  Paper_def* paper_l_;
  Curve encompass_;
  int dir_;
  Real alpha_;
  Offset origin_;
  Curve return_;
};


#endif // BEZIER_HH


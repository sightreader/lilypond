/*
  column-x-positions.hh -- part of GNU LilyPond

  (c)  1997--1999 Han-Wen Nienhuys <hanwen@cs.uu.nl>
*/

#ifndef COLUMN_X_POSITIONS_HH
#define COLUMN_X_POSITIONS_HH

#include "parray.hh"
#include "lily-proto.hh"

typedef Link_array<Paper_column>  Line_of_cols;

struct Column_x_positions {
  Line_spacer * spacer_l_;
  Line_of_cols cols_;
  Array<Real> config_;
  
  Real energy_f_;
  bool satisfies_constraints_b_;

  void OK() const;
  ~Column_x_positions();
  void solve_line();
  void approximate_solve_line();
  /** generate a solution with no regard to idealspacings or
    constraints.  should always work */
  void stupid_solution();
  void set_stupid_solution (Vector);
  Column_x_positions();
  void add_paper_column (Paper_column*c);
  void print() const;
};


#endif // COLUMN_X_POSITIONS_HH


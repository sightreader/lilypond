/*
  paper-def.hh -- declare Paper_def

  source file of the GNU LilyPond music typesetter

  (c) 1996--2000 Han-Wen Nienhuys <hanwen@cs.uu.nl>
*/


#ifndef PAPER_DEF_HH
#define PAPER_DEF_HH


#include "lily-proto.hh"
#include "lily-guile.hh"
#include "real.hh"

#include "moment.hh"
#include "array.hh"
#include "interval.hh"
#include "music-output-def.hh"
#include "protected-scm.hh"

/** 

  Symbols, dimensions and constants pertaining to visual output.

  This struct takes care of all kinds of symbols, dimensions and
  constants. Most of them are related to the point-size of the fonts,
  so therefore, the lookup table for symbols is also in here.

  TODO: 
  
  add support for multiple fontsizes 

  remove all utility funcs 
  

  add support for other len->wid conversions.


  Interesting variables:
  
  /// The distance between lines
  interline
  
*/
class Paper_def : public Music_output_def 
{
  Protected_scm lookup_alist_;
protected:
  VIRTUAL_COPY_CONS(Music_output_def);

public:    
  virtual ~Paper_def ();
  static int default_count_i_;
  /*
    JUNKME
   */
  Real get_realvar (SCM symbol) const;
  Real get_var (String id) const;
  SCM get_scmvar (String id)const; 
  void reinit ();
  Paper_def ();
  void set_lookup (int, SCM lookup_smob);
  Paper_def (Paper_def const&);

  Interval line_dimensions_int (int) const;
  void print () const;
  Lookup const * lookup_l (int sz) const;	// TODO naming
  virtual int get_next_default_count () const;
  static void reset_default_count();
  void output_settings (Paper_outputter*) const;
  Paper_stream* paper_stream_p () const;
  String base_output_str () const;

  // urg
  friend int yyparse (void*);
};

#endif // Paper_def_HH

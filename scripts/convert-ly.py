#!@PYTHON@
#
# convert-ly.py -- convertor for lilypond versions
# 
# source file of the GNU LilyPond music typesetter
# 
# (c) 1998--2001

# TODO
#   use -f and -t for -s output

# NEWS
# 0.2
#  - rewrite in python

program_name = 'convert-ly'
version = '@TOPLEVEL_VERSION@'

import os
import sys
import __main__
import getopt
import  string
import re
import time

# Did we ever have \mudela-version?  I doubt it.
# lilypond_version_re_str = '\\\\version *\"(.*)\"'
lilypond_version_re_str = '\\\\(mudela-)?version *\"(.*)\"'
lilypond_version_re = re.compile (lilypond_version_re_str)

def program_id ():
	return '%s (GNU LilyPond) %s' %(program_name,  version);

def identify ():
	sys.stderr.write (program_id () + '\n')

def usage ():
	sys.stdout.write (
		r"""Usage: %s [OPTION]... [FILE]... 
Try to convert to newer lilypond-versions.  The version number of the
input is guessed by default from \version directive

Options:
  -a, --assume-old       apply all conversions to unversioned files
  -h, --help             print this help
  -e, --edit             in place edit
  -f, --from=VERSION     start from version
  -s, --show-rules       print all rules.
  -t, --to=VERSION       target version
      --version          print program version

Report bugs to bugs-gnu-music@gnu.org

""" % program_name)
	
	
	sys.exit (0)

def print_version ():
	
	sys.stdout.write (r"""%s

This is free software.  It is covered by the GNU General Public
License, and you are welcome to change it and/or distribute copies of
it under certain conditions.  invoke as `%s --warranty' for more
information.

""" % (program_id() , program_name))
	
def gulp_file(f):
	try:
		i = open(f)
		i.seek (0, 2)
		n = i.tell ()
		i.seek (0,0)
	except:
		print 'can\'t open file: ' + f + '\n'
		return ''
	s = i.read (n)
	if len (s) <= 0:
		print 'gulped empty file: ' + f + '\n'
	i.close ()
	return s

def str_to_tuple (s):
	return tuple (map (string.atoi, string.split (s,'.')))

def tup_to_str (t):
	return string.join (map (lambda x: '%s' % x, list (t)), '.')

def version_cmp (t1, t2):
	for x in [0,1,2]:
		if t1[x] - t2[x]:
			return t1[x] - t2[x]
	return 0

def guess_lilypond_version (filename):
	s = gulp_file (filename)
	m = lilypond_version_re.search (s)
	if m:
		return m.group (2)
	else:
		return ''

class FatalConversionError:
	pass

conversions = []

def show_rules (file):
	for x in conversions:
		file.write  ('%s: %s\n' % (tup_to_str (x[0]), x[2]))

############################
		
if 1:
	def conv(str):
		if re.search ('\\\\multi', str):
			sys.stderr.write ('\nNot smart enough to convert \\multi')
		return str
	
	conversions.append (((0,1,9), conv, '\\header { key = concat + with + operator }'))

if 1:					# need new a namespace
	def conv (str):
		if re.search ('\\\\octave', str):
			sys.stderr.write ('\nNot smart enough to convert \\octave')
		#	raise FatalConversionError()
		
		return str

	conversions.append ((
		((0,1,19), conv, 'deprecated \\octave; can\'t convert automatically')))


if 1:					# need new a namespace
	def conv (str):
		str = re.sub ('\\\\textstyle([^;]+);',
					 '\\\\property Lyrics . textstyle = \\1', str)
		# harmful to current .lys
		# str = re.sub ('\\\\key([^;]+);', '\\\\accidentals \\1;', str)
			
		return str

	conversions.append ((
		((0,1,20), conv, 'deprecated \\textstyle, new \key syntax')))


if 1:
	def conv (str):
		str = re.sub ('\\\\musical_pitch', '\\\\musicalpitch',str)
		str = re.sub ('\\\\meter', '\\\\time',str)
			
		return str

	conversions.append ((
		((0,1,21), conv, '\\musical_pitch -> \\musicalpitch, '+
		 '\\meter -> \\time')))

if 1:
	def conv (str):
		return str

	conversions.append ((
		((1,0,0), conv, '0.1.21 -> 1.0.0 ')))


if 1:
	def conv (str):
		str = re.sub ('\\\\accidentals', '\\\\keysignature',str)
		str = re.sub ('specialaccidentals *= *1', 'keyoctaviation = 0',str)
		str = re.sub ('specialaccidentals *= *0', 'keyoctaviation = 1',str)
			
		return str

	conversions.append ((
		((1,0,1), conv, '\\accidentals -> \\keysignature, ' +
		 'specialaccidentals -> keyoctaviation')))

if 1:
	def conv(str):
		if re.search ('\\\\header', str):
			sys.stderr.write ('\nNot smart enough to convert to new \\header format')
		return str
	
	conversions.append (((1,0,2), conv, '\\header { key = concat + with + operator }'))

if 1:
	def conv(str):
		str =  re.sub ('\\\\melodic([^a-zA-Z])', '\\\\notes\\1',str)
		return str
	
	conversions.append (((1,0,3), conv, '\\melodic -> \\notes'))

if 1:
	def conv(str):
		str =  re.sub ('default_paper *=', '',str)
		str =  re.sub ('default_midi *=', '',str)
		return str
	
	conversions.append (((1,0,4), conv, 'default_{paper,midi}'))

if 1:
	def conv(str):
		str =  re.sub ('ChoireStaff', 'ChoirStaff',str)
		str =  re.sub ('\\\\output', 'output = ',str)
			
		return str
	
	conversions.append (((1,0,5), conv, 'ChoireStaff -> ChoirStaff'))

if 1:
	def conv(str):
		if re.search ('[a-zA-Z]+ = *\\translator',str):
			sys.stderr.write ('\nNot smart enough to change \\translator syntax')
		#	raise FatalConversionError()
		return str
	
	conversions.append (((1,0,6), conv, 'foo = \\translator {\\type .. } ->\\translator {\\type ..; foo; }'))


if 1:
	def conv(str):
		str =  re.sub ('\\\\lyrics*', '\\\\lyrics',str)
			
		return str
	
	conversions.append (((1,0,7), conv, '\\lyric -> \\lyrics'))

if 1:
	def conv(str):
		str =  re.sub ('\\\\\\[/3+', '\\\\times 2/3 { ',str)
		str =  re.sub ('\\[/3+', '\\\\times 2/3 { [',str)
		str =  re.sub ('\\\\\\[([0-9/]+)', '\\\\times \\1 {',str)
		str =  re.sub ('\\[([0-9/]+)', '\\\\times \\1 { [',str)
		str =  re.sub ('\\\\\\]([0-9/]+)', '}', str)
		str =  re.sub ('\\\\\\]', '}',str)
		str =  re.sub ('\\]([0-9/]+)', '] }', str)
		return str
	
	conversions.append (((1,0,10), conv, '[2/3 ]1/1 -> \\times 2/3 '))

if 1:
	def conv(str):
		return str
	conversions.append (((1,0,12), conv, 'Chord syntax stuff'))


if 1:
	def conv(str):
		
		
		str =  re.sub ('<([^>~]+)~([^>]*)>','<\\1 \\2> ~', str)
			
		return str
	
	conversions.append (((1,0,13), conv, '<a ~ b> c -> <a b> ~ c'))

if 1:
	def conv(str):
		str =  re.sub ('<\\[','[<', str)
		str =  re.sub ('\\]>','>]', str)
			
		return str
	
	conversions.append (((1,0,14), conv, '<[a b> <a b]>c -> [<a b> <a b>]'))


if 1:
	def conv(str):
		str =  re.sub ('\\\\type([^\n]*engraver)','\\\\TYPE\\1', str)
		str =  re.sub ('\\\\type([^\n]*performer)','\\\\TYPE\\1', str)
		str =  re.sub ('\\\\type','\\\\context', str)
		str =  re.sub ('\\\\TYPE','\\\\type', str)
		str =  re.sub ('textstyle','textStyle', str)
			
		return str
	
	conversions.append (((1,0,16), conv, '\\type -> \\context, textstyle -> textStyle'))


if 1:
	def conv(str):
		if re.search ('\\\\repeat',str):
			sys.stderr.write ('\nNot smart enough to convert \\repeat')
		#	raise FatalConversionError()
		return str
	
	conversions.append (((1,0,18), conv,
                '\\repeat NUM Music Alternative -> \\repeat FOLDSTR Music Alternative'))

if 1:
	def conv(str):
		str =  re.sub ('SkipBars','skipBars', str)
		str =  re.sub ('fontsize','fontSize', str)
		str =  re.sub ('midi_instrument','midiInstrument', str)			
			
		return str

	conversions.append (((1,0,19), conv,
                'fontsize -> fontSize, midi_instrument -> midiInstrument, SkipBars -> skipBars'))


if 1:
	def conv(str):
		str =  re.sub ('tieydirection','tieVerticalDirection', str)
		str =  re.sub ('slurydirection','slurVerticalDirection', str)
		str =  re.sub ('ydirection','verticalDirection', str)			
			
		return str

	conversions.append (((1,0,20), conv,
                '{,tie,slur}ydirection -> {v,tieV,slurV}erticalDirection'))


if 1:
	def conv(str):
		str =  re.sub ('hshift','horizontalNoteShift', str)
			
		return str

	conversions.append (((1,0,21), conv,
                'hshift -> horizontalNoteShift'))


if 1:
	def conv(str):
		str =  re.sub ('\\\\grouping[^;]*;','', str)
			
		return str

	conversions.append (((1,1,52), conv,
                'deprecate \\grouping'))


if 1:
	def conv(str):
		str =  re.sub ('\\\\wheel','\\\\coda', str)
			
		return str

	conversions.append (((1,1,55), conv,
                '\\wheel -> \\coda'))

if 1:
	def conv(str):
		str =  re.sub ('keyoctaviation','keyOctaviation', str)
		str =  re.sub ('slurdash','slurDash', str)
			
		return str

	conversions.append (((1,1,65), conv,
                'slurdash -> slurDash, keyoctaviation -> keyOctaviation'))

if 1:
	def conv(str):
		str =  re.sub ('\\\\repeat *\"?semi\"?','\\\\repeat "volta"', str)
			
		return str

	conversions.append (((1,1,66), conv,
                'semi -> volta'))


if 1:
	def conv(str):
		str =  re.sub ('\"?beamAuto\"? *= *\"?0?\"?','noAutoBeaming = "1"', str)
			
		return str

	conversions.append (((1,1,67), conv,
                'beamAuto -> noAutoBeaming'))

if 1:
	def conv(str):
		str =  re.sub ('automaticMelismas', 'automaticMelismata', str)
			
		return str

	conversions.append (((1,2,0), conv,
                'automaticMelismas -> automaticMelismata'))

if 1:
	def conv(str):
		str =  re.sub ('dynamicDir\\b', 'dynamicDirection', str)
			
		return str

	conversions.append (((1,2,1), conv,
                'dynamicDir -> dynamicDirection'))

if 1:
	def conv(str):
		str =  re.sub ('\\\\cadenza *0 *;', '\\\\cadenzaOff', str)
		str =  re.sub ('\\\\cadenza *1 *;', '\\\\cadenzaOn', str)		
			
		return str

	conversions.append (((1,3,4), conv,
                '\\cadenza -> \cadenza{On|Off}'))

if 1:
	def conv (str):
		str = re.sub ('"?beamAuto([^"=]+)"? *= *"([0-9]+)/([0-9]+)" *;*',
			      'beamAuto\\1 = #(make-moment \\2 \\3)',
			      str)
		return str

	conversions.append (((1,3,5), conv, 'beamAuto moment properties'))

if 1:
	def conv (str):
		str = re.sub ('stemStyle',
			      'flagStyle',
			      str)
		return str

	conversions.append (((1,3,17), conv, 'stemStyle -> flagStyle'))

if 1:
	def conv (str):
		str = re.sub ('staffLineLeading',
			      'staffSpace',
			      str)
		return str

	conversions.append (((1,3,18), conv, 'staffLineLeading -> staffSpace'))


if 1:
	def conv(str):
		if re.search ('\\\\repetitions',str):
			sys.stderr.write ('\nNot smart enough to convert \\repetitions')
		#	raise FatalConversionError()
		return str
	
	conversions.append (((1,3,23), conv,
                '\\\\repetitions feature dropped'))


if 1:
	def conv (str):
		str = re.sub ('textEmptyDimension *= *##t',
			      'textNonEmpty = ##f',
			      str)
		str = re.sub ('textEmptyDimension *= *##f',
			      'textNonEmpty = ##t',
			      str)
		return str

	conversions.append (((1,3,35), conv, 'textEmptyDimension -> textNonEmpty'))

if 1:
	def conv (str):
		str = re.sub ("([a-z]+)[ \t]*=[ \t]*\\\\musicalpitch *{([- 0-9]+)} *\n",
			      "(\\1 . (\\2))\n", str)
		str = re.sub ("\\\\musicalpitch *{([0-9 -]+)}",
			      "\\\\musicalpitch #'(\\1)", str)
		if re.search ('\\\\notenames',str):
			sys.stderr.write ('\nNot smart enough to convert to new \\notenames format')
		return str

	conversions.append (((1,3,38), conv, '\musicalpitch { a b c } -> #\'(a b c)'))

if 1:
	def conv (str):
		def replace (match):
			return '\\key %s;' % string.lower (match.group (1))
		
		str = re.sub ("\\\\key ([^;]+);",  replace, str)
		return str
	
	conversions.append (((1,3,39), conv, '\\key A ;  ->\\key a;'))

if 1:
	def conv (str):
		if re.search ('\\[:',str):
			sys.stderr.write ('\nNot smart enough to convert to new tremolo format')
		return str

	conversions.append (((1,3,41), conv,
                '[:16 c4 d4 ] -> \\repeat "tremolo" 2 { c16 d16 }'))

if 1:
	def conv (str):
		str = re.sub ('Staff_margin_engraver' , 'Instrument_name_engraver', str)
		return str

	conversions.append (((1,3,42), conv,
                'Staff_margin_engraver deprecated, use Instrument_name_engraver'))

if 1:
	def conv (str):
		str = re.sub ('note[hH]eadStyle\\s*=\\s*"?(\\w+)"?' , "noteHeadStyle = #'\\1", str)
		return str

	conversions.append (((1,3,49), conv,
                'noteHeadStyle value: string -> symbol'))

if 1:
	def conv (str):
		if re.search ('\\\\keysignature', str):
			sys.stderr.write ('\nNot smart enough to convert to new tremolo format')
		return str


	conversions.append (((1,3,58), conv,
                'noteHeadStyle value: string -> symbol'))

if 1:
	def conv (str):
		str = re.sub (r"""\\key *([a-z]+) *;""", r"""\\key \1 \major;""",str);
		return str
	conversions.append (((1,3,59), conv,
                '\key X ; -> \key X major; ')) 

if 1:
	def conv (str):
		str = re.sub (r'latexheaders *= *"\\\\input ',
			      'latexheaders = "',
			      str)
		return str
	conversions.append (((1,3,68), conv, 'latexheaders = "\\input global" -> latexheaders = "global"'))




# TODO: lots of other syntax change should be done here as well
if 1:
	def conv (str):
		str = re.sub ('basicCollisionProperties', 'NoteCollision', str)
		str = re.sub ('basicVoltaSpannerProperties' , "VoltaBracket", str)
		str = re.sub ('basicKeyProperties' , "KeySignature", str)

		str = re.sub ('basicClefItemProperties' ,"Clef", str)


		str = re.sub ('basicLocalKeyProperties' ,"Accidentals", str)
		str = re.sub ('basicMarkProperties' ,"Accidentals", str)
		str = re.sub ('basic([A-Za-z_]+)Properties', '\\1', str)

		str = re.sub ('Repeat_engraver' ,'Volta_engraver', str)
		return str
	
	conversions.append (((1,3,92), conv, 'basicXXXProperties -> XXX, Repeat_engraver -> Volta_engraver'))

if 1:
	def conv (str):
		# Ugh, but meaning of \stemup changed too
		# maybe we should do \stemup -> \stemUp\slurUp\tieUp ?
		str = re.sub ('\\\\stemup', '\\\\stemUp', str)
		str = re.sub ('\\\\stemdown', '\\\\stemDown', str)
		str = re.sub ('\\\\stemboth', '\\\\stemBoth', str)
		
		str = re.sub ('\\\\slurup', '\\\\slurUp', str)
		str = re.sub ('\\\\slurboth', '\\\\slurBoth', str)
		str = re.sub ('\\\\slurdown', '\\\\slurDown', str)
		str = re.sub ('\\\\slurdotted', '\\\\slurDotted', str)
		str = re.sub ('\\\\slurnormal', '\\\\slurNoDots', str)		
		
		str = re.sub ('\\\\shiftoff', '\\\\shiftOff', str)
		str = re.sub ('\\\\shifton', '\\\\shiftOn', str)
		str = re.sub ('\\\\shiftonn', '\\\\shiftOnn', str)
		str = re.sub ('\\\\shiftonnn', '\\\\shiftOnnn', str)

		str = re.sub ('\\\\onevoice', '\\\\oneVoice', str)
		str = re.sub ('\\\\voiceone', '\\\\voiceOne', str)
		str = re.sub ('\\\\voicetwo', '\\\\voiceTwo', str)
		str = re.sub ('\\\\voicethree', '\\\\voiceThree', str)
		str = re.sub ('\\\\voicefour', '\\\\voiceFour', str)

		# I don't know exactly when these happened...
		# ugh, we loose context setting here...
		str = re.sub ('\\\\property *[^ ]*verticalDirection[^=]*= *#?"?(1|(\\\\up))"?', '\\\\stemUp\\\\slurUp\\\\tieUp', str)
		str = re.sub ('\\\\property *[^ ]*verticalDirection[^=]*= *#?"?((-1)|(\\\\down))"?', '\\\\stemDown\\\\slurDown\\\\tieDown', str)
		str = re.sub ('\\\\property *[^ ]*verticalDirection[^=]*= *#?"?(0|(\\\\center))"?', '\\\\stemBoth\\\\slurBoth\\\\tieBoth', str)

		str = re.sub ('verticalDirection[^=]*= *#?"?(1|(\\\\up))"?', 'Stem \\\\override #\'direction = #0\nSlur \\\\override #\'direction = #0\n Tie \\\\override #\'direction = #1', str)
		str = re.sub ('verticalDirection[^=]*= *#?"?((-1)|(\\\\down))"?', 'Stem \\\\override #\'direction = #0\nSlur \\\\override #\'direction = #0\n Tie \\\\override #\'direction = #-1', str)
		str = re.sub ('verticalDirection[^=]*= *#?"?(0|(\\\\center))"?', 'Stem \\\\override #\'direction = #0\nSlur \\\\override #\'direction = #0\n Tie \\\\override #\'direction = #0', str)
		
		str = re.sub ('\\\\property *[^ .]*[.]?([a-z]+)VerticalDirection[^=]*= *#?"?(1|(\\\\up))"?', '\\\\\\1Up', str)
		str = re.sub ('\\\\property *[^ .]*[.]?([a-z]+)VerticalDirection[^=]*= *#?"?((-1)|(\\\\down))"?', '\\\\\\1Down', str)
		str = re.sub ('\\\\property *[^ .]*[.]?([a-z]+)VerticalDirection[^=]*= *#?"?(0|(\\\\center))"?', '\\\\\\1Both', str)

		# (lacks capitalisation slur -> Slur)
		str = re.sub ('([a-z]+)VerticalDirection[^=]*= *#?"?(1|(\\\\up))"?', '\\1 \\\\override #\'direction = #1', str)
		str = re.sub ('([a-z]+)VerticalDirection[^=]*= *#?"?((-1)|(\\\\down))"?', '\\1 \\override #\'direction = #-1', str)
		str = re.sub ('([a-z]+)VerticalDirection[^=]*= *#?"?(0|(\\\\center))"?', '\\1 \\\\override #\'direction = #0', str)

		## dynamic..
		str = re.sub ('\\\\property *[^ .]*[.]?dynamicDirection[^=]*= *#?"?(1|(\\\\up))"?', '\\\\dynamicUp', str)
		str = re.sub ('\\\\property *[^ .]*[.]?dyn[^=]*= *#?"?((-1)|(\\\\down))"?', '\\\\dynamicDown', str)
		str = re.sub ('\\\\property *[^ .]*[.]?dyn[^=]*= *#?"?(0|(\\\\center))"?', '\\\\dynamicBoth', str)

		str = re.sub ('\\\\property *[^ .]*[.]?([a-z]+)Dash[^=]*= *#?"?(0|(""))"?', '\\\\\\1NoDots', str)
		str = re.sub ('\\\\property *[^ .]*[.]?([a-z]+)Dash[^=]*= *#?"?([1-9]+)"?', '\\\\\\1Dotted', str)

		str = re.sub ('\\\\property *[^ .]*[.]?noAutoBeaming[^=]*= *#?"?(0|(""))"?', '\\\\autoBeamOn', str)
		str = re.sub ('\\\\property *[^ .]*[.]?noAutoBeaming[^=]*= *#?"?([1-9]+)"?', '\\\\autoBeamOff', str)



		return str
	
	conversions.append (((1,3,93), conv,
                'property definiton case (eg. onevoice -> oneVoice)'))


if 1:
	def conv (str):
		str = re.sub ('ChordNames*', 'ChordNames', str)
		if re.search ('\\\\textscript "[^"]* *"[^"]*"', str):
			sys.stderr.write ('\nNot smart enough to convert to new \\textscript markup text')

		str = re.sub ('\\textscript +("[^"]*")', '\\textscript #\\1', str)

		return str
	
	conversions.append (((1,3,97), conv, 'ChordName -> ChordNames'))


# TODO: add lots of these
	
if 1:
	def conv (str):
		str = re.sub ('\\\\property *"?Voice"? *[.] *"?textStyle"? *= *"([^"]*)"', '\\\\property Voice.TextScript \\\\set #\'font-style = #\'\\1', str)
		str = re.sub ('\\\\property *"?Lyrics"? *[.] *"?textStyle"? *= *"([^"]*)"', '\\\\property Lyrics.LyricText \\\\set #\'font-style = #\'\\1', str)

		str = re.sub ('\\\\property *"?([^.]+)"? *[.] *"?timeSignatureStyle"? *= *"([^"]*)"', '\\\\property \\1.TimeSignature \\\\override #\'style = #\'\\2', str) 

		str = re.sub ('"?timeSignatureStyle"? *= *#?""', 'TimeSignature \\\\override #\'style = ##f', str)
		
		str = re.sub ('"?timeSignatureStyle"? *= *#?"([^"]*)"', 'TimeSignature \\\\override #\'style = #\'\\1', str)
		
		str = re.sub ('#\'style *= #*"([^"])"', '#\'style = #\'\\1', str)
		
		str = re.sub ('\\\\property *"?([^.]+)"? *[.] *"?horizontalNoteShift"? *= *"?#?([-0-9]+)"?', '\\\\property \\1.NoteColumn \\\\override #\'horizontal-shift = #\\2', str) 

		# ugh
		str = re.sub ('\\\\property *"?([^.]+)"? *[.] *"?flagStyle"? *= *""', '\\\\property \\1.Stem \\\\override #\'flag-style = ##f', str)
		
		str = re.sub ('\\\\property *"?([^.]+)"? *[.] *"?flagStyle"? *= *"([^"]*)"', '\\\\property \\1.Stem \\\\override #\'flag-style = #\'\\2', str) 
		return str
	
	conversions.append (((1,3,98), conv, 'CONTEXT.textStyle -> GROB.#font-style '))

if 1:
	def conv (str):
		str = re.sub ('"?beamAutoEnd_([0-9]*)"? *= *(#\\([^)]*\\))', 'autoBeamSettings \\push #\'(end 1 \\1 * *) = \\2', str)
		str = re.sub ('"?beamAutoBegin_([0-9]*)"? *= *(#\\([^)]*\))', 'autoBeamSettings \\push #\'(begin 1 \\1 * *) = \\2', str)
		str = re.sub ('"?beamAutoEnd"? *= *(#\\([^)]*\\))', 'autoBeamSettings \\push #\'(end * * * *) = \\1', str)
		str = re.sub ('"?beamAutoBegin"? *= *(#\\([^)]*\\))', 'autoBeamSettings \\push #\'(begin * * * *) = \\1', str)


		return str
	
	conversions.append (((1,3,102), conv, 'beamAutoEnd -> autoBeamSettings \\push (end * * * *)'))


if 1:
	def conv (str):
		str = re.sub ('\\\\push', '\\\\override', str)
		str = re.sub ('\\\\pop', '\\\\revert', str)

		return str
	
	conversions.append (((1,3,111), conv, '\\push -> \\override, \\pop -> \\revert'))

if 1:
	def conv (str):
		str = re.sub ('LyricVoice', 'LyricsVoice', str)
		# old fix
		str = re.sub ('Chord[Nn]ames*.Chord[Nn]ames*', 'ChordNames.ChordName', str)
		str = re.sub ('Chord[Nn]ames([ \t\n]+\\\\override)', 'ChordName\\1', str)
		return str
	
	conversions.append (((1,3,113), conv, 'LyricVoice -> LyricsVoice'))

def regularize_id (str):
	s = ''
	lastx = ''
	for x in str:
		if x == '_':
			lastx = x
			continue
		elif x in string.digits:
			x = chr(ord (x) - ord ('0')  +ord ('A'))
		elif x not in string.letters:
			x = 'x'
		elif x in string.lowercase and lastx == '_':
			x = string.upper (x)
		s = s + x
		lastx = x
	return s

if 1:
	def conv (str):
		
		def regularize_dollar_reference (match):
			return regularize_id (match.group (1))
		def regularize_assignment (match):
			return '\n' + regularize_id (match.group (1)) + ' = '
		str = re.sub ('\$([^\t\n ]+)', regularize_dollar_reference, str)
		str = re.sub ('\n([^ \t\n]+) = ', regularize_assignment, str)
		return str
	
	conversions.append (((1,3,117), conv, 'identifier names: $!foo_bar_123 -> xfooBarABC'))


if 1:
	def conv (str):
		def regularize_paper (match):
			return regularize_id (match.group (1))
		
		str = re.sub ('(paper_[a-z]+)', regularize_paper, str)
		str = re.sub ('sustainup', 'sustainUp', str)
		str = re.sub ('nobreak', 'noBreak', str)
		str = re.sub ('sustaindown', 'sustainDown', str)
		str = re.sub ('sostenutoup', 'sostenutoUp', str)
		str = re.sub ('sostenutodown', 'sostenutoDown', str)
		str = re.sub ('unachorda', 'unaChorda', str)
		str = re.sub ('trechorde', 'treChorde', str)
	
		return str
	
	conversions.append (((1,3,120), conv, 'paper_xxx -> paperXxxx, pedalup -> pedalUp.'))

if 1:
	def conv (str):
		str = re.sub ('drarnChords', 'chordChanges', str)
		str = re.sub ('\\musicalpitch', '\\pitch', str)
		return str
	
	conversions.append (((1,3,122), conv, 'drarnChords -> chordChanges, \\musicalpitch -> \\pitch'))

if 1:
	def conv (str):
		str = re.sub ('ly-([sg])et-elt-property', 'ly-\\1et-grob-property', str)
		return str
	
	conversions.append (((1,3,136), conv, 'ly-X-elt-property -> ly-X-grob-property'))

if 1:
	def conv (str):
		str = re.sub ('point-and-click +#t', 'point-and-click line-column-location', str)
		return str
	
	conversions.append (((1,3,138), conv, 'point-and-click argument changed to procedure.'))

if 1:
	def conv (str):
		str = re.sub ('followThread', 'followVoice', str)
		str = re.sub ('Thread.FollowThread', 'Voice.VoiceFollower', str)
		str = re.sub ('FollowThread', 'VoiceFollower', str)
		return str
	
	conversions.append (((1,3,138), conv, 'followThread -> followVoice.'))

if 1:
	def conv (str):
		str = re.sub ('font-point-size', 'font-design-size', str)
		return str
	
	conversions.append (((1,3,139), conv, 'font-point-size -> font-design-size.'))

if 1:
	def conv (str):
		str = re.sub ('([a-zA-Z]*)NoDots', '\\1Solid', str)
		return str
	
	conversions.append (((1,3,141), conv, 'xNoDots -> xSolid'))

if 1:
	def conv (str):
		str = re.sub ('([Cc])horda', '\\1orda', str)
		return str
	
	conversions.append (((1,3,144), conv, 'Chorda -> Corda'))


if 1:
	def conv (str):
		str = re.sub ('([A-Za-z]+)MinimumVerticalExtent', 'MinimumV@rticalExtent', str)
		str = re.sub ('([A-Za-z]+)ExtraVerticalExtent', 'ExtraV@rticalExtent', str)
		str = re.sub ('([A-Za-z]+)VerticalExtent', 'VerticalExtent', str)
		str = re.sub ('ExtraV@rticalExtent', 'ExtraVerticalExtent', str)
		str = re.sub ('MinimumV@rticalExtent', 'MinimumVerticalExtent', str)		
		return str

	conversions.append (((1,3,145), conv,
	'ContextNameXxxxVerticalExtent -> XxxxVerticalExtent'))

################################
#	END OF CONVERSIONS	
################################

def get_conversions (from_version, to_version):
	def version_b (v, f = from_version, t = to_version):
		return version_cmp (v[0], f) > 0 and version_cmp (v[0], t) <= 0
	return filter (version_b, conversions)


def latest_version ():
	return conversions[-1][0]

def do_conversion (infile, from_version, outfile, to_version):
	conv_list = get_conversions (from_version, to_version)

	sys.stderr.write ('Applying conversions: ')
	str = infile.read ()
	last_conversion = ()
	try:
		for x in conv_list:
			sys.stderr.write (tup_to_str (x[0])  + ', ')
			str = x[1] (str)
			last_conversion = x[0]

	except FatalConversionError:
		sys.stderr.write ('Error while converting; I won\'t convert any further')

	if last_conversion:
		sys.stderr.write ('\n')
		new_ver =  '\\version \"%s\"' % tup_to_str (last_conversion)
		# JUNKME?
		# ugh: this all really doesn't help
		# esp. as current conversion rules are soo incomplete
		if re.search (lilypond_version_re_str, str):
			str = re.sub (lilypond_version_re_str,'\\'+new_ver , str)
		#else:
		#	str = new_ver + '\n' + str

		outfile.write(str)

	return last_conversion
	
class UnknownVersion:
	pass

def do_one_file (infile_name):
	sys.stderr.write ('Processing `%s\' ... '% infile_name)
	outfile_name = ''
	if __main__.edit:
		outfile_name = infile_name + '.NEW'
	elif __main__.outfile_name:
		outfile_name = __main__.outfile_name

	if __main__.from_version:
		from_version = __main__.from_version
	else:
		guess = guess_lilypond_version (infile_name)
		if not guess:
			raise UnknownVersion()
		from_version = str_to_tuple (guess)

	if __main__.to_version:
		to_version = __main__.to_version
	else:
		to_version = latest_version ()


	if infile_name:
		infile = open (infile_name,'r')
	else:
		infile = sys.stdin

	if outfile_name:
		outfile =  open (outfile_name, 'w')
	else:
		outfile = sys.stdout

	touched = do_conversion (infile, from_version, outfile, to_version)

	if infile_name:
		infile.close ()

	if outfile_name:
		outfile.close ()

	if __main__.edit and touched:
		try:
			os.remove(infile_name + '~')
		except:
			pass
		os.rename (infile_name, infile_name + '~')
		os.rename (infile_name + '.NEW', infile_name)

	sys.stderr.write ('\n')
	sys.stderr.flush ()

edit = 0
assume_old = 0
to_version = ()
from_version = ()
outfile_name = ''

(options, files) = getopt.getopt (
	sys.argv[1:], 'ao:f:t:seh', ['assume-old', 'version', 'output', 'show-rules', 'help', 'edit', 'from=', 'to='])

for opt in options:
	o = opt[0]
	a = opt[1]
	if o== '--help' or o == '-h':
		usage ()
		sys.exit (0)
	if o == '--version' or o == '-v':
		print_version ()
		sys.exit (0)
	elif o== '--from' or o=='-f':
		from_version = str_to_tuple (a)
	elif o== '--to' or o=='-t':
		to_version = str_to_tuple (a)
	elif o== '--edit' or o == '-e':
		edit = 1
	elif o== '--show-rules' or o == '-s':
		show_rules (sys.stdout)
		sys.exit(0)
	elif o == '--output' or o == '-o':
		outfile_name = a
	elif o == '--assume-old' or o == '-a':
		assume_old = 1
	else:
		print o
		raise getopt.error

identify ()
for f in files:
	if f == '-':
		f = ''
	try:
		do_one_file (f)
	except UnknownVersion:
		sys.stderr.write ('\n')
		sys.stderr.write ("%s: can't determine version for %s" % (program_name, f))
		sys.stderr.write ('\n')
		if assume_old:
			fv = from_version
			from_version = (0,0,0)
			do_one_file (f)
			from_version = fv
		else:
			sys.stderr.write ("%s: skipping: %s " % (program_name,  f))
		pass
sys.stderr.write ('\n')

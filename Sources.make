# -*- Makefile-*-
# sourcefiles to be shipped. Also for dependencies

hdr=   bar.hh beam.hh boxes.hh break.hh clef.hh clefitem.hh\
	colhpos.hh command.hh complexwalker.hh complexstaff.hh\
	const.hh debug.hh dimen.hh directionalspanner.hh\
	getcommand.hh glob.hh  grouping.hh idealspacing.hh\
	identifier.hh identparent.hh inputcommand.hh inputcommands.hh\
	inputmusic.hh inputscore.hh inputstaff.hh item.hh key.hh keyitem.hh\
	keyword.hh leastsquares.hh lexer.hh linespace.hh linepstaff.hh\
	localkeyitem.hh lookup.hh \
	lyriccolumn.hh  lyricitem.hh lyricstaff.hh lyricwalker.hh\
	main.hh melodicstaff.hh meter.hh misc.hh\
	molecule.hh moment.hh notehead.hh notename.hh offset.hh paper.hh\
	parseconstruct.hh pcol.hh proto.hh pscore.hh pstaff.hh qlp.hh\
	qlpsolve.hh register.hh request.hh rest.hh rhythmstaff.hh\
	sccol.hh score.hh\
	scoreline.hh script.hh scriptdef.hh simplestaff.hh simplewalker.hh\
	slur.hh source.hh sourcefile.hh spanner.hh staff.hh staffcommands.hh\
	staffelem.hh staffline.hh\
	stcol.hh stem.hh staffwalker.hh symbol.hh symtable.hh\
	tex.hh textdef.hh\
	textitem.hh textspanner.hh timedescription.hh tstream.hh voice.hh\
	voicegroup.hh

mycc=bar.cc beam.cc boxes.cc break.cc calcideal.cc clef.cc\
	clefitem.cc colhpos.cc command.cc complexstaff.cc complexwalker.cc \
	 complexprint.cc debug.cc dimen.cc\
	directionalspanner.cc\
	getcommands.cc grouping.cc groupregs.cc idealspacing.cc identifier.cc\
	inputcommand.cc inputcommands.cc inputmusic.cc inputscore.cc\
	inputstaff.cc item.cc key.cc keyitem.cc keyword.cc\
	leastsquares.cc lexerinit.cc linespace.cc linepstaff.cc\
	localkeyitem.cc lookup.cc\
	lyriccolumn.cc lyricitem.cc lyricstaff.cc lyricwalker.cc\
	main.cc melodicstaff.cc meter.cc\
	misc.cc molecule.cc mylexer.cc note.cc notehead.cc notename.cc\
	paper.cc pcol.cc pscore.cc pstaff.cc qlp.cc qlpsolve.cc\
	register.cc request.cc rest.cc rhythmstaff.cc sccol.cc score.cc\
	scoreline.cc scores.cc script.cc scriptdef.cc simpleprint.cc\
	simplestaff.cc simplewalker.cc slur.cc source.cc sourcefile.cc\
	spanner.cc staff.cc\
	staffcommands.cc staffelem.cc staffline.cc stcol.cc stem.cc\
	staffwalker.cc symbol.cc symtable.cc  tex.cc texbeam.cc\
	texslur.cc textdef.cc textitem.cc textspanner.cc\
	timedescription.cc tstream.cc voice.cc voiceregs.cc voicegroup.cc\
	warn.cc windhoos-suck-suck-suck-thank-you-cygnus.cc wordwrap.cc\
	template1.cc template2.cc template3.cc template4.cc\
	template5.cc template6.cc version.cc

# a bit of a hack to keep exec size under control.
stablecc=request.cc bar.cc boxes.cc break.cc  clef.cc getcommands.cc grouping.cc\
	item.cc keyword.cc leastsquares.cc \
	linepstaff.cc linespace.cc lookup.cc molecule.cc meter.cc\
	paper.cc parser.cc lexer.cc pstaff.cc qlp.cc qlpsolve.cc\
	template1.cc template2.cc template3.cc template4.cc\
	template5.cc template6.cc version.cc tstream.cc  tex.cc\
	voice.cc wordwrap.cc spanner.cc 

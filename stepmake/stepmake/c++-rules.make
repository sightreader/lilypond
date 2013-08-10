.SUFFIXES: .cc .dep .hh .ll .o .so .yy

$(outdir)/%.o: %.cc
	@ $(call FANCY_PRINT_CXX,$<)
	@ $(DO_O_DEP) $(CXX) -c $(ALL_CXXFLAGS) -o $@ $<

$(outdir)/%.o: $(outdir)/%.cc
	@ $(call FANCY_PRINT_CXX,$<)
	@ $(DO_O_DEP) $(CXX) -c $(ALL_CXXFLAGS) -o $@ $<

$(outdir)/%.lo: %.cc
	@ $(call FANCY_PRINT_CXX,$<)
	@ $(DO_LO_DEP) $(CXX) -c $(ALL_CXXFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.lo: $(outdir)/%.cc
	@ $(call FANCY_PRINT_CXX,$<)
	@ $(DO_LO_DEP) $(CXX) -c $(ALL_CXXFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.cc: %.yy
	@ $(call FANCY_PRINT_GENERATION_WITH,$(BISON),$<)
	@ $(BISON) -o $@  $<

$(outdir)/%.hh: %.yy
	@ $(call FANCY_PRINT_GENERATION_WITH,$(BISON),$<)
	@ $(BISON) -o $(subst .hh,-tmp.cc,$@) -d  $<
	@ rm $(subst .hh,-tmp.cc,$@)
	@ mv $(subst .hh,-tmp.hh,$@) $@

$(outdir)/%.cc: %.ll
	@ $(call FANCY_PRINT_GENERATION_WITH,$(FLEX),$<)
	@ $(FLEX) -Cfe -p -p -o$@ $<

$(outdir)/%-rc.o: $(outdir)/%.rc
	@ $(call FANCY_PRINT_COMPILATION_WITH,$(WINDRES),$<)
	@ $(WINDRES) $(WINDRES_FLAGS) -o$@ $<
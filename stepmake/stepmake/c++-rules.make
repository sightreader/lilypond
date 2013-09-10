.SUFFIXES: .cc .dep .hh .ll .o .so .yy

$(outdir)/%.o: %.cc
	@ $(call PRINT_SMART_DESC,$(CXX))
	@ $(DO_O_DEP) $(CXX) -c $(ALL_CXXFLAGS) -o $@ $<

$(outdir)/%.o: $(outdir)/%.cc
	@ $(call PRINT_SMART_DESC,$(CXX))
	@ $(DO_O_DEP) $(CXX) -c $(ALL_CXXFLAGS) -o $@ $<

$(outdir)/%.lo: %.cc
	@ $(call PRINT_SMART_DESC,$(CXX))
	@ $(DO_LO_DEP) $(CXX) -c $(ALL_CXXFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.lo: $(outdir)/%.cc
	@ $(call PRINT_SMART_DESC,$(CXX))
	@ $(DO_LO_DEP) $(CXX) -c $(ALL_CXXFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.cc: %.yy
	@ $(call PRINT_SMART_DESC,$(BISON))
	@ $(BISON) -o $@  $<

$(outdir)/%.hh: %.yy
	@ $(call PRINT_SMART_DESC,$(BISON))
	@ $(BISON) -o $(subst .hh,-tmp.cc,$@) -d  $<
	@ rm $(subst .hh,-tmp.cc,$@)
	@ mv $(subst .hh,-tmp.hh,$@) $@

$(outdir)/%.cc: %.ll
	@ $(call PRINT_SMART_DESC,$(FLEX))
	@ $(FLEX) -Cfe -p -p -o$@ $<

$(outdir)/%-rc.o: $(outdir)/%.rc
	@ $(call PRINT_SMART_DESC,$(WINDRES))
	@ $(WINDRES) $(WINDRES_FLAGS) -o$@ $<

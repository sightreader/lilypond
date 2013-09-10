.SUFFIXES: .cc .dep .hh .ll .o .so .yy

$(outdir)/%.o: %.cc
	$(HIDE) $(call PRINT_SMART_DESC,$(CXX))
	$(HIDE) $(DO_O_DEP) $(CXX) -c $(ALL_CXXFLAGS) -o $@ $<

$(outdir)/%.o: $(outdir)/%.cc
	$(HIDE) $(call PRINT_SMART_DESC,$(CXX))
	$(HIDE) $(DO_O_DEP) $(CXX) -c $(ALL_CXXFLAGS) -o $@ $<

$(outdir)/%.lo: %.cc
	$(HIDE) $(call PRINT_SMART_DESC,$(CXX))
	$(HIDE) $(DO_LO_DEP) $(CXX) -c $(ALL_CXXFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.lo: $(outdir)/%.cc
	$(HIDE) $(call PRINT_SMART_DESC,$(CXX))
	$(HIDE) $(DO_LO_DEP) $(CXX) -c $(ALL_CXXFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.cc: %.yy
	$(HIDE) $(call PRINT_SMART_DESC,$(BISON))
	$(HIDE) $(BISON) -o $@  $<

$(outdir)/%.hh: %.yy
	$(HIDE) $(call PRINT_SMART_DESC,$(BISON))
	$(HIDE) $(BISON) -o $(subst .hh,-tmp.cc,$@) -d  $<
	$(HIDE) rm $(subst .hh,-tmp.cc,$@)
	$(HIDE) mv $(subst .hh,-tmp.hh,$@) $@

$(outdir)/%.cc: %.ll
	$(HIDE) $(call PRINT_SMART_DESC,$(FLEX))
	$(HIDE) $(FLEX) -Cfe -p -p -o$@ $<

$(outdir)/%-rc.o: $(outdir)/%.rc
	$(HIDE) $(call PRINT_SMART_DESC,$(WINDRES))
	$(HIDE) $(WINDRES) $(WINDRES_FLAGS) -o$@ $<

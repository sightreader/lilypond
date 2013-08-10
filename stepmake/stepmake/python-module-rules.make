
$(outdir)/%$(SHARED_MODULE_SUFFIX): $(outdir)/%.lo
	@ $(call FANCY_PRINT_LD,$<)
	@ $(LD) -o $@ $< $(SHARED_FLAGS) $(ALL_LDFLAGS)

$(outdir)/%.pyc: $(outdir)/%.py
	PYTHONOPTIMIZE= $(PYTHON) -c 'import py_compile; py_compile.compile ("$<")'

$(outdir)/%.pyo: $(outdir)/%.py
	@ $(call FANCY_PRINT_COMPILATION_WITH,$(PYTHON),$<)
	@ $(PYTHON) -O -c 'import py_compile; py_compile.compile ("$<")'

$(outdir)/%.py: %.py $(config_make) $(depth)/VERSION
	@ $(call FANCY_PRINT_GENERATION,$@)
	@ cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	@ chmod 755 $@


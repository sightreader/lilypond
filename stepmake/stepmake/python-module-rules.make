
$(outdir)/%$(SHARED_MODULE_SUFFIX): $(outdir)/%.lo
	@ $(call PRINT_SMART_DESC,ld)
	@ $(LD) -o $@ $< $(SHARED_FLAGS) $(ALL_LDFLAGS)

$(outdir)/%.pyc: $(outdir)/%.py
	PYTHONOPTIMIZE= $(PYTHON) -c 'import py_compile; py_compile.compile ("$<")'

$(outdir)/%.pyo: $(outdir)/%.py
	@ $(call PRINT_SMART_DESC,$(PYTHON))
	@ $(PYTHON) -O -c 'import py_compile; py_compile.compile ("$<")'

$(outdir)/%.py: %.py $(config_make) $(depth)/VERSION
	@ $(call PRINT_SMART_DESC)
	@ cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	@ chmod 755 $@


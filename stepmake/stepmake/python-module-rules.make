
$(outdir)/%$(SHARED_MODULE_SUFFIX): $(outdir)/%.lo
	$(HIDE) $(call PRINT_SMART_DESC,ld)
	$(HIDE) $(LD) -o $@ $< $(SHARED_FLAGS) $(ALL_LDFLAGS)

$(outdir)/%.pyc: $(outdir)/%.py
	PYTHONOPTIMIZE= $(PYTHON) -c 'import py_compile; py_compile.compile ("$<")'

$(outdir)/%.pyo: $(outdir)/%.py
	$(HIDE) $(call PRINT_SMART_DESC,$(PYTHON))
	$(HIDE) $(PYTHON) -O -c 'import py_compile; py_compile.compile ("$<")'

$(outdir)/%.py: %.py $(config_make) $(depth)/VERSION
	$(HIDE) $(call PRINT_SMART_DESC)
	$(HIDE) cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	$(HIDE) chmod 755 $@


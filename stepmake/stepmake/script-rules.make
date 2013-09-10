
$(outdir)/%: %.pl $(config_make)  $(depth)/VERSION
	$(HIDE) $(call PRINT_SMART_DESC)
	$(HIDE) cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	$(HIDE) chmod 755 $@

$(outdir)/%: %.bash $(config_make) $(depth)/VERSION
	$(HIDE) $(call PRINT_SMART_DESC)
	$(HIDE) cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	$(HIDE) chmod 755 $@

$(outdir)/%: %.scm $(config_make) $(depth)/VERSION
	$(HIDE) $(call PRINT_SMART_DESC)
	$(HIDE) cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	$(HIDE) chmod 755 $@

$(outdir)/%: %.expect $(config_make) $(depth)/VERSION
	$(HIDE) $(call PRINT_SMART_DESC)
	$(HIDE) cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	$(HIDE) chmod 755 $@

$(outdir)/%: %.sh $(config_make) $(depth)/VERSION
	$(HIDE) $(call PRINT_SMART_DESC)
	$(HIDE) cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	$(HIDE) chmod 755 $@

$(outdir)/%: %.py $(config_make) $(depth)/VERSION
	$(HIDE) $(call PRINT_SMART_DESC)
	$(HIDE) cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@
	$(HIDE) chmod 755 $@


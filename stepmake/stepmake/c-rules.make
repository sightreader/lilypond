.SUFFIXES: .c .dep .h .l .lo .o .so .y

$(outdir)/%.o: %.c
	$(HIDE) $(call PRINT_SMART_DESC,$(CC))
	$(HIDE) $(DO_O_DEP) $(CC) -c $(ALL_CFLAGS) -o $@ $<

$(outdir)/%.o: $(outdir)/%.c
	$(HIDE) $(call PRINT_SMART_DESC,$(CC))
	$(HIDE) $(DO_O_DEP) $(CC) -c $(ALL_CFLAGS) -o $@ $<

$(outdir)/%.lo: %.c
	$(HIDE) $(call PRINT_SMART_DESC,$(CC))
	$(HIDE) $(DO_LO_DEP) $(CC) -c $(ALL_CFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.lo: %.c
	$(HIDE) $(call PRINT_SMART_DESC,$(CC))
	$(HIDE) $(DO_LO_DEP) $(CC) -c $(ALL_CFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.c: %.y
	$(HIDE) $(call PRINT_SMART_DESC,$(BISON))
	$(HIDE) $(BISON) $<
	$(HIDE) mv $(*F).tab.c $@

$(outdir)/%.h: %.y
	$(HIDE) $(call PRINT_SMART_DESC,$(BISON))
	$(HIDE) $(BISON) -d $<
	$(HIDE) mv $(*F).tab.h $@
	$(HIDE) rm -f $(*F).tab.c # if this happens in the wrong order it triggers recompile of the .cc file

$(outdir)/%.c: %.l
	$(HIDE) $(call PRINT_SMART_DESC,$(BISON))
	$(HIDE) $(FLEX) -Cfe -p -p -o$@ $<
# could be faster:
#	$(HIDE) $(FLEX) -8 -Cf -o$@ $<

$(outdir)/%.rc.o: $(outdir)/%.rc
	$(HIDE) $(call PRINT_SMART_DESC,$(WINDRES))
	$(HIDE) $(WINDRES) $(WINDRES_FLAGS) -o$@ $<

.SUFFIXES: .c .dep .h .l .lo .o .so .y

$(outdir)/%.o: %.c
    @ $(call PRINT_SMART_DESC,$(CC))
	@ $(DO_O_DEP) $(CC) -c $(ALL_CFLAGS) -o $@ $<

$(outdir)/%.o: $(outdir)/%.c
    @ $(call PRINT_SMART_DESC,$(CC))
	@ $(DO_O_DEP) $(CC) -c $(ALL_CFLAGS) -o $@ $<

$(outdir)/%.lo: %.c
    @ $(call PRINT_SMART_DESC,$(CC))
	@ $(DO_LO_DEP) $(CC) -c $(ALL_CFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.lo: %.c
    @ $(call PRINT_SMART_DESC,$(CC))
	@ $(DO_LO_DEP) $(CC) -c $(ALL_CFLAGS) $(PIC_FLAGS) -o $@ $<

$(outdir)/%.c: %.y
    @ $(call PRINT_SMART_DESC,$(BISON))
	@ $(BISON) $<
	@ mv $(*F).tab.c $@

$(outdir)/%.h: %.y
    @ $(call PRINT_SMART_DESC,$(BISON))
	@ $(BISON) -d $<
	@ mv $(*F).tab.h $@
	@ rm -f $(*F).tab.c # if this happens in the wrong order it triggers recompile of the .cc file

$(outdir)/%.c: %.l
    @ $(call PRINT_SMART_DESC,$(BISON))
	@ $(FLEX) -Cfe -p -p -o$@ $<
# could be faster:
#	@ $(FLEX) -8 -Cf -o$@ $<

$(outdir)/%.rc.o: $(outdir)/%.rc
    @ $(call PRINT_SMART_DESC,$(WINDRES))
	@ $(WINDRES) $(WINDRES_FLAGS) -o$@ $<

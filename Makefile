#
# Makefile for livepatch
# $Id: Makefile 330 2004-11-03 11:38:02Z ukai $
# Copyright (C) 2004 Fumitoshi UKAI <ukai@debian.or.jp>
# All rights reserved.
# This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms of
# the GNU General Public License version 2.
# #
CFLAGS ?= -Wall -O2 -g
TEST_FILE=testlive
LIVEPATCH_FILE=livepatch
.PHONY: all clean

# First real target = default goal: `make` links livepatch, not only *.o
all: $(LIVEPATCH_FILE) libfoo.so libfoo2.so $(TEST_FILE)

$(LIVEPATCH_FILE).o fixup.o: livepatch-arch.h

$(LIVEPATCH_FILE): $(LIVEPATCH_FILE).o
	$(CC) $(CFLAGS) -o $@ $< -lbfd

fixup: fixup.o
	$(CC) $(CFLAGS) -o $@ $< -lbfd

bfd: bfd.o
	$(CC) $(CFLAGS) -o $@ $< -lbfd

clean:
	-rm -f *.o *.s *.a *.so
	-rm -f *.asm
	-rm -f *.sect
	-rm -f $(LIVEPATCH_FILE) fixup bfd
	-rm -f $(TEST_FILE) $(TEST_FILE).o

libfoo.so: libfoo.o
	$(CC) $(CFLAGS) -shared -fPIC -o $@ $<
	objdump -D $@ > $@.asm
	objdump -s $@ > $@.sect

libfoo2.so: libfoo2.o
	$(CC) $(CFLAGS) -shared -fPIC -o $@ $<
	objdump -D $@ > $@.asm
	objdump -s $@ > $@.sect

# Default: normal PIE link (no -no-pie). If `jmp func_J` misses the real address on
# your distro, rebuild with: make testlive TESTLIVE_EXTRA_LDFLAGS=-no-pie
TESTLIVE_EXTRA_LDFLAGS ?=

# Avoid IPA so func_J stays a real call target (see testlive.c comment).
$(TEST_FILE).o: $(TEST_FILE).c
	$(CC) $(CFLAGS) -c -o $@ $<

$(TEST_FILE): $(TEST_FILE).o
	$(CC) $(CFLAGS) $(TESTLIVE_EXTRA_LDFLAGS) -o $@ $<
	objdump -D $@ > $@.asm

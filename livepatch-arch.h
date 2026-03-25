/**
 * Shared architecture / ELF definitions for livepatch.c and fixup.c.
 * Copyright (C) 2004 Fumitoshi UKAI <ukai@debian.or.jp>
 * SPDX-License-Identifier: GPL-2.0
 */
#ifndef LIVEPATCH_ARCH_H
#define LIVEPATCH_ARCH_H

#include <elf.h>
#include <link.h>

#if defined(linux)
/* sysdeps/i386/dl-machine.h */
/* The i386 never uses Elf32_Rela relocations for the dynamic linker.
 *    Prelinked libraries may use Elf32_Rela though.  */
#if SYSTEM32
#define ELF_MACHINE_PLT_REL 1
#else
#define ELF_MACHINE_NO_REL 1
#endif
#else
#error Unsupported platform
#endif

#if SYSTEM32
#define SYSTEM_ALIGN_TYPE int
#else
#define SYSTEM_ALIGN_TYPE long
#endif

/* glibc/elf/dl-runtime.c */
#if (!defined ELF_MACHINE_NO_RELA && !defined ELF_MACHINE_PLT_REL) || \
	ELF_MACHINE_NO_REL
#define PLTREL ElfW(Rela)
#else
#define PLTREL ElfW(Rel)
#endif

/* glibc/sysdeps/generic/ldsodefs.h */
#define ELFW(type) _ElfW(ELF, __ELF_NATIVE_CLASS, type)

struct symaddr {
	struct symaddr *next;
	char *name;
	SYSTEM_ALIGN_TYPE addr;
};

#endif /* LIVEPATCH_ARCH_H */

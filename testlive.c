#include <stdio.h>
#include <time.h>
#include <limits.h>
#include <unistd.h>
#include <sys/mman.h>

/*
 * Must not be inlined: livepatch resolves func_J by symbol address and patches
 * that entry. With -O2, GCC may inline func_J into main and leave an unused
 * copy at func_J — jmp there would never run.
 */
__attribute__((noinline)) int func_J(int a, int b)
{
	char *str_P = "I'm wrong function...QQ";
	printf("in %s\n", str_P);
	sleep(3);
	printf("exit %s\n", str_P);
	return (a + b);
}

/*
 * Must not be inlined: livepatch resolves func_J by symbol address and patches
 * that entry. With -O2, GCC may inline func_J into main and leave an unused
 * copy at func_J — jmp there would never run.
 */
__attribute__((noinline)) int func_Q(int a, int b)
{
	char *str_P = "I'm wrong function 2...QQ";
	printf("in func_Q %s\n", str_P);
	sleep(3);
	printf("exit func_Q %s\n", str_P);
	return (a + b);
}


int main()
{
	while (1) {
		int a = func_J(1, 2);
		int b = func_Q(1, 2);
		sleep(3);
		printf("In main get calculating result: %d\n", a);
		if (12 == a && 12 == b) {
			printf("=== You fix it !!! (%d %d) ===\n", a, b);
			break;
		} else {
			printf("=== No, this is not the right answer....(%d %d) ===\n",
			       a, b);
		}
	}
}

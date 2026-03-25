#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>

int func2(int a, int b)
{
	printf("in %s fixup\n", __func__);
	sleep(2);
	printf("exit %s fixup\n", __func__);
	return (a * 10 + b);
}

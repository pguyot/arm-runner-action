// From https://wiki.gentoo.org/wiki/Embedded_Handbook/General/Compiling_with_qemu_user_chroot
/*
 * pass arguments to qemu binary
 * QEMU_CPU environment variable can be unset
 */

#include <string.h>
#include <unistd.h>

#define XSTR(cpu) STR(cpu)
#define STR(cpu) #cpu

int main(int argc, char **argv, char **envp) {
	int this_len = strlen(argv[0]);
	char staticpath[this_len + 2];
	char *newargv[argc + 3];

	newargv[0] = argv[0];
	newargv[1] = "-cpu";
	newargv[2] = XSTR(QEMU_CPU);

	memcpy(&newargv[3], &argv[1], sizeof(*argv) * (argc -1));
	newargv[argc + 2] = NULL;
	strncpy(staticpath, argv[0], this_len + 2);
	staticpath[this_len] = '0';
	return execve(staticpath, newargv, envp);
}

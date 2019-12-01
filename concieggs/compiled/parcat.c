/* Stream from multiple files.  Whenever a new line is ready from either file,
   print it to standard out.  Assumes there is always an entire line to read
   whenever a read becomes possible.  */

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>
#include <stdint.h>
#include <stdbool.h>

int main(int argc, char* *argv) {
  int n_fds;
  FILE* *files = (FILE**) (argv + 1);
  fd_set rfds;
  int retval;

  assert(argc > 1);
  n_fds = argc - 1;
  FD_ZERO(&rfds);
  int fd_max = 0;
  for (int i = 1; i < argc; i++) {
    int fd = open(argv[i], O_RDWR);
    fd_max = fd > fd_max ? fd : fd_max;
    assert(fd != -1);
    assert(fd <= FD_SETSIZE);
    FILE* f = fdopen(fd, "rw");
    assert(f != NULL);
    setvbuf(f, NULL, _IOLBF, BUFSIZ);
    FD_SET(fd, &rfds);
    files[i - 1] = f;
  }

  while (true) {
    retval = select(fd_max + 1, &rfds, NULL, NULL, NULL);
    if (retval >= 1) {
      for (int i = 0; i < n_fds; i++) {
        FILE* f = files[i];
        int fd = fileno(f);
        if (FD_ISSET(fd, &rfds)) {
          char* line = NULL;
          size_t len = 0;
          ssize_t nread;
          nread = getline(&line, &len, f);
          assert(nread != -1);
          fwrite(line, nread, 1, stdout);
        }
        FD_SET(fd, &rfds);
      }
    } else {
      exit(EXIT_FAILURE);
    }
  }

  exit(EXIT_SUCCESS);
}

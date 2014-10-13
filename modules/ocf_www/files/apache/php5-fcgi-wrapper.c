#include <stdio.h>
// php5-cgi wrapper that passes environment variable
void main(){
  char *filename = "/usr/bin/php5-cgi";
  char *argv[] = { NULL };
  char *envp[] = { "PHP_FCGI_MAX_REQUESTS=10000" };
  execve(filename, argv, envp);
}

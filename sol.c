#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

int main(int argc, char* argv[]) {

  if (argc <= 1) {
    printf("%s\n", "Usage: sol <filename>.sol");
    return 1;
  }

  if (strlen(argv[1]) <= 4) {
    printf("'%s' is not a valid sol file. Abort", argv[1]);
    return 1;
  }

  /*
  char* ftype = (char*)malloc(4);
  strcpy(ftype, &argv[1][strlen(argv[1]) - 4]);
  printf("%s\n", ftype);
  if (!strcmp(ftype, ".sol")) {
    printf("'%s' is not a valid file type. Abort\n", ftype);
  }
  free(ftype);
  */

  FILE *f = fopen(argv[1], "rb");
  long fsize;
  if (f == NULL) {
    printf("Couldn't open file '%s'\n", argv[1]);
    return 1;
  }
  fseek(f, 0, SEEK_END);
  fsize = ftell(f);
  fseek(f, 0, SEEK_SET);

  char* contents = malloc(fsize + 1);
  fread(contents, fsize, 1, f);
  fclose(f);
  contents[fsize] = 0;

  lua_State *L = luaL_newstate();

  luaL_openlibs(L);

  lua_pushstring(L, contents);
  lua_setglobal(L, "_SRC");

  luaL_loadfile(L, "sol.lua");

  if (lua_pcall(L, -1, 0, 0)) {
    printf("%s\n", lua_tostring(L, -1));
  }

  return 0;

}


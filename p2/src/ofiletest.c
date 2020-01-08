//
// File-system system calls.
// Mostly argument checking, since we don't trust
// user code, and calls into file.c and fs.c.
//

#include "types.h"
#include "user.h"
#include "fs.h"
#include "stat.h"
#include "fcntl.h"


char*
strcmb(char* string1, char* string2)
{
  int total_Size = strlen(string1) + strlen(string2);
   char *final_String = malloc(total_Size);
  
  for(int k = 0; k < total_Size; k++){
    if(k < strlen(string1)){
      final_String[k] = string1[k];
    }else if(k - strlen(string1) <= strlen(string2)){
      final_String[k] = string2[k - strlen(string1)];
    }
  }
  return final_String;
}

char*
itos(int number)
{
  if(number < 10){
    static char str[1];
    str[0] = (char)(48 + number);
    return str;
  }else{
    static char str[2];
    str[0] = (char)(number/10 + 48);
    str[1] = (char)(number%10 + 48);
    return str;
  }
}


int
main(int argc, char *argv[])
{ 
  if (argc == 1){
    printf(1, "%d %d\n", 0, 0);
    exit();
  }
  int cur_Open_Num;
  int next_Descriptor;
  int storage[atoi(argv[1])];
  if (argc >= 2){
    int open_Num = atoi(argv[1]);
    for(int i = 0; i < open_Num; i++){
      char *file_Number = itos(i);
      char *combine = strcmb("ofile",file_Number);
      storage[i] = open(combine, O_CREATE);
      //printf(1,"%s",file_Number);
      //printf(1,"%s",combine);
    }
  }
  if (argc > 2){
    for(int j = 2; j < argc; j++){
      close(storage[atoi(argv[j])]);
      char *file_Number = itos(j);
      char *combine = strcmb("ofile",file_Number);
      unlink(combine);
    }
  }

  cur_Open_Num = getofilecnt(getpid());
  next_Descriptor = getofilenext(getpid());
  
  printf(1, "%d %d\n", cur_Open_Num, next_Descriptor); 
  exit();
}


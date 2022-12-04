#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// This code was generated by ChatGPT

int main(int argc, char **argv) {
  // check if no arguments were passed
  if (argc < 2) {
    printf("Error: no expression passed\n");
    return 1;
  }

  // initialize the result variable
  double result = 0;

  // initialize the current number and operation variables
  double current_num = 0;
  char current_op = '\0';

  // initialize the buffer and index variables
  char buffer[32];
  int buffer_idx = 0;

  // loop through each character in the argument
  for (int i = 0; i <= strlen(argv[1]); i++) {
    char c = argv[1][i];

    // check if the character is a digit
    if (c >= '0' && c <= '9') {
      // add the character to the buffer
      buffer[buffer_idx++] = c;
    } else {
      // character is not a digit
      // convert the buffer to a number and add it to the current number
      buffer[buffer_idx] = '\0';
      current_num = atof(buffer);

      // reset the buffer
      buffer_idx = 0;

      // check the current operation and update the result
      // according to the operation
      if (current_op == '+') {
        result += current_num;
      } else if (current_op == '*') {
        result *= current_num;
      } else {
        // no operation set, use the current number as the result
        result = current_num;
      }

      // check if the character is an operation
      if (c == '+' || c == '*') {
        // set the current operation
        current_op = c;
      }
    }
  }

  // print the result
  printf("Result: %.2f\n", result);

  return 0;
}

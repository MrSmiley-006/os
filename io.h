#ifndef IO
#define IO

#include "stdint.h"
#define VIDEO_MEMORY 0xb8000

int vmem_row = 0, vmem_col = 0;

static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("out %0, %1" : : "a"(value), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t value;
    __asm__ volatile ("in %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

void print_char(char ch) {
  char *video_memory = (char*)VIDEO_MEMORY;
  if (ch == '\n') {
    vmem_row++;
    vmem_col = 0;
  }
  else
  *(video_memory + 2 * (80 * vmem_row + vmem_col++)) = ch;
}

void print_string(char *str) {
  for (int i = 0;str[i] != '\0';i++)
    print_char(str[i]);
}


#endif

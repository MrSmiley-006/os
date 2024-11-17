void entrypoint() {}

void print_string(char *str);
void print_char(char ch);
static inline void outb(unsigned short port, unsigned char byte);
static inline unsigned char inb(unsigned short port);
unsigned char send_ps2_byte(unsigned char port, unsigned char byte);

void main() {
  char *str = "\nHello world.\n";
  print_string(str);
  unsigned char response = send_ps2_byte(0x64, 0xEE);
  print_char(response);
  if (response == 0xEE || response == 0xFA)
    print_string("Keyboard OK\n");
  else print_string("Error detecting keyboard.\n");
  /*print_string("Scan code set: ");
  response = send_ps2_byte(0x64, 0xF0);
  if (response == 0xFA) {
    response = send_ps2_byte(0x60, 0x0);
    print_char(response + 48);
  }
  else print_string("Error");*/
}

#include "io.h"

unsigned char send_ps2_byte(unsigned char port, unsigned char byte) {
  while (inb(0x64) & 1) {}
  outb(port, byte);
  unsigned char response = 0xFF;
  int counter = 0xFFFFF;
  while (!(inb(0x64) & 2)) {
    if (--counter == 0)
	break;
  }
  response = inb(0x60);
  if (response == 0xFE)
    return send_ps2_byte(port, byte);
  return response;
}

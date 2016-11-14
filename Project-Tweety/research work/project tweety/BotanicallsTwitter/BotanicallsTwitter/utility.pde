//// Functions that save RAM memory by putting strings into program ROM
//// created by Limor of LadyAda.net
void ROM_putstring(const char *str, uint8_t nl) {
    uint8_t i;

    for (i=0; pgm_read_byte(&str[i]); i++) {
        uart_putchar(pgm_read_byte(&str[i]));
  }
  if (nl) {
        uart_putchar('\n'); uart_putchar('\r');
  }
}

void ROM_putstringSS(const char *str, uint8_t nl) {
    uint8_t i;

    for (i=0; pgm_read_byte(&str[i]); i++) {
        uart_putcharSS(pgm_read_byte(&str[i]));
  }
  if (nl) {
        uart_putcharSS('\n');
  }
}

void uart_putchar(char c) {
        while (!(UCSR0A & _BV(UDRE0)));
    UDR0 = c;
}

void uart_putcharSS(char c) {
    mySerial.print(c);
}

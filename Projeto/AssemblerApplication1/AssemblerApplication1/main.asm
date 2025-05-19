.include "m328pdef.inc"

.org 0x0000
    rjmp RESET

RESET:
    ; Configura PB0 (porta digital 8) como sa�da
    ldi r16, (1 << PB0)
    out DDRB, r16

    ; Coloca PB0 em n�vel alto (aciona buzzer)
    ldi r16, (1 << PB0)
    out PORTB, r16

LOOP:
    rjmp LOOP    ; Loop infinito

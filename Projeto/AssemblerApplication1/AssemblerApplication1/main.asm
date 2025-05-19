.include "m328pdef.inc"

.org 0x0000
    rjmp RESET

RESET:
    ; Configura PB0 (porta digital 8) como saída
    ldi r16, (1 << PB0)
    out DDRB, r16

    ; Coloca PB0 em nível alto (aciona buzzer)
    ldi r16, (1 << PB0)
    out PORTB, r16

LOOP:
    rjmp LOOP    ; Loop infinito

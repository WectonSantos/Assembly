.include "m328pdef.inc"

.org 0x0000
    rjmp RESET

RESET:
    ; Configura o pino digital 2 (PD2) como entrada com pull-up
    sbi PORTD, PD2      ; Ativa pull-up interno
    cbi DDRD, PD2       ; Configura PD2 como entrada

    ; Configura o pino digital 13 (PB5) como sa�da
    sbi DDRB, PB5       ; Configura PB5 como sa�da

LOOP:
    sbic PIND, PD2      ; Verifica se PD2 est� em n�vel alto (sem chuva)
    rjmp LED_OFF        ; Se alto, desliga o LED

    ; Se PD2 est� em n�vel baixo (chuva detectada), liga o LED
    sbi PORTB, PB5
    rjmp LOOP

LED_OFF:
    cbi PORTB, PB5
    rjmp LOOP

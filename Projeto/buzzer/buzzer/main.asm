.include "m328pdef.inc"     ; Arquivo de definição para ATmega328P

.equ BUZZER = 2             ; PORTB2 = pino digital 10

.org 0x0000
    rjmp RESET              ; Salto para a rotina principal

RESET:
    ; Configura o pino do buzzer como saída
    ldi r16, (1 << BUZZER)
    out DDRB, r16

    ; Reproduz um som tipo apito simples
    ldi r18, 100             ; Número de ciclos (ajusta duração)
SOM:
    sbi PORTB, BUZZER        ; Liga o buzzer
    rcall DELAY_CURTO
    cbi PORTB, BUZZER        ; Desliga o buzzer
    rcall DELAY_CURTO
    dec r18
    brne SOM

FIM:
    rjmp FIM                 ; Fica em loop após tocar

; Pequeno delay (ajusta a frequência do som)
DELAY_CURTO:
    ldi r20, 200
DELAY_LOOP:
    nop
    dec r20
    brne DELAY_LOOP
    ret

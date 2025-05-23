.include "m328pdef.inc"

.equ LED = 5                ; PORTB5 (pino digital 13)
.equ BUZZER = 2             ; PORTB2 (pino digital 10)
.equ LUM_LIMIAR_L = 0x20    ; Parte baixa de 800
.equ LUM_LIMIAR_H = 0x03    ; Parte alta de 800

.org 0x0000
    rjmp RESET

RESET:
    ; Configura LED e BUZZER como saída
    ldi r16, (1 << LED) | (1 << BUZZER)
    out DDRB, r16

    ; Configura ADC: referência AVcc, canal ADC0
    ldi r16, (1 << REFS0)
    sts ADMUX, r16

    ; Habilita ADC com prescaler de 128
    ldi r16, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
    sts ADCSRA, r16

MAIN_LOOP:
    ; Inicia a conversão ADC
    lds r17, ADCSRA
    ori r17, (1 << ADSC)
    sts ADCSRA, r17

WAIT_ADC:
    lds r17, ADCSRA
    sbrs r17, ADIF
    rjmp WAIT_ADC

    ; Lê o valor do ADC (10 bits)
    lds r18, ADCL        ; LSB
    lds r19, ADCH        ; MSB

    ; Limpa a flag ADIF
    lds r17, ADCSRA
    ori r17, (1 << ADIF)
    sts ADCSRA, r17

    ; Compara com 800 (0x0320)
    ldi r20, LUM_LIMIAR_L
    ldi r21, LUM_LIMIAR_H

    cp r19, r21          ; Compara MSB (ADCH)
    brlo ABAIXO_LIMIAR   ; Se menor, aciona
    brne ACIMA_LIMIAR    ; Se maior, ignora

    cp r18, r20          ; Se MSB igual, compara LSB (ADCL)
    brlo ABAIXO_LIMIAR
    rjmp ACIMA_LIMIAR

ABAIXO_LIMIAR:
    sbi PORTB, LED

    ; Toca o buzzer
    ldi r22, 50
TOCA_BUZZER:
    sbi PORTB, BUZZER
    rcall DELAY_CURTO
    cbi PORTB, BUZZER
    rcall DELAY_CURTO
    dec r22
    brne TOCA_BUZZER

    rjmp MAIN_LOOP

ACIMA_LIMIAR:
    cbi PORTB, LED
    cbi PORTB, BUZZER
    rjmp MAIN_LOOP

; Delay simples
DELAY_CURTO:
    ldi r23, 200
DELAY_LOOP:
    nop
    dec r23
    brne DELAY_LOOP
    ret

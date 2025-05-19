.include "m328pdef.inc"     ; Arquivo de definição para ATmega328P

.equ LED = 5                ; PORTB5 (pino digital 13)
.equ LUM_LIMIAR = 100       ; Limiar de luminosidade (ajuste conforme necessário)

.org 0x0000
    rjmp RESET              ; Salto para a rotina principal

RESET:
    ; Configura PORTB5 como saída (LED embutido)
    ldi r16, (1 << LED)
    out DDRB, r16

    ; Configura ADC
    ldi r16, (1 << REFS0)           ; Referência AVcc, canal ADC0 temporário
    sts ADMUX, r16

    ; Habilita ADC com prescaler de 128 (f_ADC = 16MHz / 128 = 125kHz)
    ldi r16, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
    sts ADCSRA, r16

LOOP:
    ; Seleciona canal ADC5 (pino A5) com AVcc como referência
    ldi r16, (1 << REFS0) | 0x05
    sts ADMUX, r16

    ; Inicia conversão ADC
    lds r17, ADCSRA
    ori r17, (1 << ADSC)
    sts ADCSRA, r17

AGUARDA_ADC:
    lds r17, ADCSRA
    sbrs r17, ADIF
    rjmp AGUARDA_ADC

    ; Leitura do valor ADC (leia ADCL antes de ADCH)
    lds r18, ADCL
    lds r19, ADCH

    ; Limpa a flag ADIF (escreve 1 para limpar)
    lds r17, ADCSRA
    ori r17, (1 << ADIF)
    sts ADCSRA, r17

    ; Compara valor lido com limiar
    ldi r20, LUM_LIMIAR
    cp r18, r20
    brlo ACENDE_LED       ; Se valor < limiar, acende o LED
    rjmp APAGA_LED

ACENDE_LED:
    sbi PORTB, LED
    rjmp LOOP

APAGA_LED:
    cbi PORTB, LED
    rjmp LOOP

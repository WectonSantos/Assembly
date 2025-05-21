.include "m328pdef.inc"     ; Arquivo de definição para ATmega328P

.equ LED = 5                ; PORTB5 (pino digital 13)
.equ BUZZER = 2             ; PORTB2 (pino digital 10)
.equ LUM_LIMIAR = 100       ; Limiar de luminosidade

.org 0x0000
    rjmp RESET              ; Salto para a rotina principal

RESET:
    ; Configura LED e BUZZER como saída
    ldi r16, (1 << LED) | (1 << BUZZER)
    out DDRB, r16

    ; Configura ADC (referência AVcc, canal ADC0 para LDR)
    ldi r16, (1 << REFS0)
    sts ADMUX, r16

    ; Habilita ADC com prescaler de 128
    ldi r16, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
    sts ADCSRA, r16

LOOP:
    ; Inicia conversão do ADC
    lds r17, ADCSRA
    ori r17, (1 << ADSC)
    sts ADCSRA, r17

AGUARDA_ADC:
    lds r17, ADCSRA
    sbrs r17, ADIF
    rjmp AGUARDA_ADC

    ; Leitura do valor ADC
    lds r18, ADCL
    lds r19, ADCH

    ; Limpa a flag ADIF
    lds r17, ADCSRA
    ori r17, (1 << ADIF)
    sts ADCSRA, r17

    ; Compara valor com o limiar
    ldi r20, LUM_LIMIAR
    cp r18, r20
    brlo ACENDE_LED_BUZZER
    rjmp APAGA_TUDO

ACENDE_LED_BUZZER:
    sbi PORTB, LED

    ; --- Som de apito simples ---
    ldi r21, 50          ; Número de ciclos de som
TOCA_SOM:
    sbi PORTB, BUZZER    ; Liga buzzer
    rcall DELAY_CURTO
    cbi PORTB, BUZZER    ; Desliga buzzer
    rcall DELAY_CURTO
    dec r21
    brne TOCA_SOM
    ; --- fim som ---

    rjmp LOOP

APAGA_TUDO:
    cbi PORTB, LED
    cbi PORTB, BUZZER
    rjmp LOOP

; Rotina de delay simples (ajuste conforme necessário)
DELAY_CURTO:
    ldi r22, 200
DELAY_LOOP:
    nop
    dec r22
    brne DELAY_LOOP
    ret

.include "m328pdef.inc"     ; Arquivo de definição para ATmega328P

; Definições de pinos
.equ LASER_PIN = 4          ; PB4 corresponde ao pino 12 do Arduino
.equ LED = 5                ; PORTB5 (pino digital 13)
.equ LUM_LIMIAR = 100       ; Limiar de luminosidade (ajuste conforme necessário)
.equ MUDANCA_LIMIAR = 10    ; Limite de variação para considerar a mudança

.org 0x0000
    rjmp RESET              ; Salto para a rotina principal

RESET:
    ; Configura PB4 como saída para o laser
    ldi r16, (1 << LASER_PIN)
    out DDRB, r16           ; Configura o pino PB4 (LASER_PIN) como saída

    ; Configura PB5 como saída para o LED
    ldi r16, (1 << LED)
    out DDRB, r16           ; Configura o pino PB5 (LED) como saída

    ; Configura ADC (referência AVcc, canal ADC0 para LDR)
    ldi r16, (1 << REFS0)           ; Referência AVcc, canal ADC0
    sts ADMUX, r16

    ; Habilita ADC com prescaler de 128 (f_ADC = 16MHz / 128 = 125kHz)
    ldi r16, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
    sts ADCSRA, r16

    ; Inicializa o valor anterior do LDR
    ldi r20, 0   ; r20 = valor anterior do LDR (inicializado com 0)

main:
    ; Leitura do valor ADC (LDR)
    lds r17, ADCSRA
    ori r17, (1 << ADSC)   ; Inicia conversão ADC
    sts ADCSRA, r17

AGUARDA_ADC:
    lds r17, ADCSRA
    sbrs r17, ADIF         ; Aguarda conversão terminar
    rjmp AGUARDA_ADC

    ; Lê o valor ADC (leitura de 8 bits de ADCL)
    lds r18, ADCL           ; Lê ADCL (8 bits de valor)
    lds r19, ADCH           ; Lê ADCH (8 bits se necessário)

    ; Limpa a flag ADIF
    lds r17, ADCSRA
    ori r17, (1 << ADIF)
    sts ADCSRA, r17

    ; Compara o valor atual do LDR (r18) com o valor anterior (r20)
    ; Se a mudança for maior que o limiar, então consideramos que a luz mudou
    mov r21, r18            ; r21 = valor atual do LDR
    sub r21, r20            ; r21 = valor atual - valor anterior (comparação)
    brmi MUDANCA            ; Se houve uma mudança negativa, não há variação relevante
    cpi r21, MUDANCA_LIMIAR ; Compara a diferença com o limiar de mudança
    brge MUDANCA            ; Se a diferença for maior ou igual ao limiar, houve uma mudança

    ; Se não houver mudança significativa, retorna ao loop
    rjmp main

MUDANCA:
    ; Atualiza o valor anterior com o valor atual
    mov r20, r18            ; r20 = valor atual do LDR (salva como anterior)
    
    ; Acende ou apaga o LED dependendo da intensidade da luz
    ldi r20, LUM_LIMIAR     ; Limiar de luminosidade
    cp r18, r20             ; Compara o valor lido com o limiar
    brlo ACENDE_LED         ; Se o valor for abaixo do limiar, acende o LED
    rjmp APAGA_LED

ACENDE_LED:
    sbi PORTB, LED          ; Acende o LED (PORTB5)
    rjmp main

APAGA_LED:
    cbi PORTB, LED          ; Apaga o LED (PORTB5)
    rjmp main

; Controle do Laser (simples)
ACENDE_LASER:
    sbi PORTB, LASER_PIN    ; Liga o laser (PB4)
    rjmp main

APAGA_LASER:
    cbi PORTB, LASER_PIN    ; Desliga o laser (PB4)
    rjmp main

; Função de delay simples
_delay:
    ldi r18, 255
loop1:
    ldi r19, 255
loop2:
    dec r19
    brne loop2
    dec r18
    brne loop1
    ret

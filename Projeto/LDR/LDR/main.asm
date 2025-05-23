.include "m328Pdef.inc" ; Inclui definições para o ATmega328P

; Definições de pinos
.equ LDR_PIN = 0      ; A0
.equ BUZZER_PIN = 10  ; Pino 10

; Variáveis
.def valorldr = r16   ; Registrador para armazenar o valor lido do LDR

; Inicialização
.org 0x0000           ; Endereço de início do programa
rjmp main             ; Salta para a função principal

main:
    ; Configuração dos pinos
    ldi r16, (1 << BUZZER_PIN) ; Configura o pino do buzzer como saída
    out DDRB, r16               ; Escreve no registrador de direção do PORTB

    ldi r16, 0                  ; Configura o pino LDR como entrada
    out DDRC, r16               ; Escreve no registrador de direção do PORTC

    ; Inicializa a comunicação serial
    ldi r16, 51                 ; UBRR = 51 para 9600 bps
    out UBRR0, r16              ; Configura a taxa de transmissão
    ldi r16, (1 << RXEN0) | (1 << TXEN0) ; Habilita RX e TX
    out UCSR0B, r16

loop:
    ; Leitura do LDR
    ldi r16, LDR_PIN            ; Seleciona o canal do LDR
    out ADMUX, r16              ; Configura o ADC para ler o LDR
    ldi r16, (1 << ADEN)        ; Habilita o ADC
    out ADCSRA, r16

    ; Inicia a conversão
    ldi r16, (1 << ADSC)        ; Inicia a conversão ADC
    out ADCSRA, r16

wait_adc:
    ; Espera a conversão terminar
    in r16, ADCSRA              ; Lê o registrador de controle do ADC
    sbrs r16, ADSC              ; Se ADSC for 0, a conversão terminou
    rjmp wait_adc               ; Caso contrário, continua esperando

    ; Lê o valor do ADC
    in r16, ADCL                ; Lê o byte baixo
    in r17, ADCH                ; Lê o byte alto
    ; Combina os dois bytes em valorldr
    ; Aqui, r16 contém o byte baixo e r17 o byte alto
    ; Para simplificar, vamos usar r16 como valorldr

    ; Verifica se valorldr < 500
    cpi r16, 500                ; Compara valorldr com 500
    brlt turn_on_buzzer         ; Se valorldr < 500, liga o buzzer

    ; Desliga o buzzer
    ldi r16, (1 << BUZZER_PIN)  ; Prepara para desligar o buzzer
    out PORTB, r16              ; Desliga o buzzer
    rjmp loop                   ; Volta para o loop

turn_on_buzzer:
    ; Liga o buzzer
    ldi r16, (1 << BUZZER_PIN)  ; Prepara para ligar o buzzer
    out PORTB, r16              ; Liga o buzzer
    ; Aguarda 500 ms
    ldi r18, 0xFF                ; Contador para 500 ms
delay_500ms:
    ldi r19, 0xFF                ; Contador interno
delay_inner:
    nop                          ; Não faz nada (1 ciclo)
    dec r19                      ; Decrementa o contador interno
    brne delay_inner             ; Se não chegou a zero, continua
    dec r18                      ; Decrementa o contador externo
    brne delay_500ms            ; Se não chegou a zero, continua

    ; Desliga o buzzer
    ldi r16, (1 << BUZZER_PIN)  ; Prepara para desligar o buzzer
    out PORTB, r16              ; Desliga o buzzer
    rjmp loop                   ; Volta para o loop
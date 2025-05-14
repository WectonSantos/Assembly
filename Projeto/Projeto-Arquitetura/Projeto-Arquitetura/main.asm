;
; Projeto-Arquitetura.asm
;
; Created: 13/05/2025 23:44:04
; Author : Wecton
;


; SENSOR DE CHUVA - HW028

; PD2 = entrada do sensor
; PB5 = LED


sensorChuva:
	.include "m328pdef.inc" ;Inclui o arquivo de definições específicas do ATmega328P, nomes simbólicos para registradores e bits (DDRB, PORTB, PD2, PB5, etc.).  Para que o código seja legível e portátil.

	ldi r16, 0x00 ; setando o r16 como 0
	out DDRD, r16      ; envia o valor 0x00 para o registrador DDRD
	ldi r16, (1 << PB5) ; configura o bit 5 como 1
	out DDRB, r16      ; envia o valor de r16 para o registrador DDRB

	loop: ;função que será executada em loop para ler o sensor
		in r17, PIND ;le o valor de PIND e armazena em r17
		sbrc r17, PD2 ; pula o proximo se o bit PD2 em r17 for zero
		rjmp ledLigado ; vai pra função que liga o led
		rjmp led_off ; vai pra função que desliga o led

	ledLigado:
		sbi PORTB, PB5 ; envia nível alto para o pino digital 13 e liga o led
		rjmp loop ; retoma a função de loop

	ledDesligado:
		cbi PORTB, PB5 ;  envia nível baixo para o pino e desliga o led
		rjmp loop ; retoma a função de loop


sensorLDR:
	.include "m328pdef.inc"
	
	.org 0x00 ; vetor de reset, início do programa
	rjmp setup ; pula para a rotina de configuração

;config inicial
setup:
	; configura PB0 (pino digital 8) como saída (LED)
	ldi r16, (1 << PB0)
	out DDRB, r16 ; define PB0 como saída

	; seleciona referência de tensão AVcc (5V) e canal ADC0 (pino A0)
	ldi r16, (1 << REFS0); REFS0 = 1 ? referência AVcc com capacitor no AREF
	sts ADMUX, r16 ; grava no registrador ADMUX

	; habilita o ADC e define prescaler para 128 (16 MHz / 128 = 125 kHz)
	; ADEN = 1 ? habilita o ADC
	; ADPS2:0 = 111 ? prescaler = 128
	ldi r16, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, r16 ; grava no registrador ADCSRA

;loop principal
loopPrincipal:
	; inicia uma nova conversão analógica
	lds r16, ADCSRA  ; carrega valor atual de ADCSRA
	ori r16, (1 << ADSC) ; define o bit ADSC (start conversion)
	sts ADCSRA, r16 ; inicia a conversão

; aguarda a conversão terminar (ADSC = 0 indica término)
esperaConversao:
	lds r16, ADCSRA ; lê o registrador ADCSRA
	sbrc r16, ADSC ; verifica se ADSC ainda está em 1
	rjmp esperaConversao ; se sim, volta e espera

	;lê o resultado da conversão (10 bits: ADCL + ADCH)
	lds r17, ADCL ; primeiro deve-se ler ADCL!
	lds r18, ADCH ; depois lê ADCH

	; o valor lido está em r18:r17 (10 bits: r18 contém os bits mais significativos)

	; compara se valor do ADC é menor que 512 (r18 < 0x02)
	ldi r19, 0x02       ; parte alta de 512
	cp r18, r19         ; compara r18 com 0x02
	brlo ligaLED        ; se valor < 512, liga LED
	rjmp desligaLED     ; senão, desliga LED

ligaLED:
	sbi PORTB, PB0      ; liga LED (PB0 = 1)
	rjmp loopPrincipal  ; volta ao início do loop

desligaLED:
	cbi PORTB, PB0      ; desliga LED (PB0 = 0)
	rjmp loopPrincipal  ; volta ao início do loop

.include "m328pdef.inc"

.org 0x0000
    rjmp    RESET

; =======================================================
; Inicialização
; =======================================================
RESET:
    ; Inicializa a pilha
    ldi     r16, LOW(RAMEND)
    out     SPL, r16
    ldi     r16, HIGH(RAMEND)
    out     SPH, r16

    ; --- Configuração das portas ---
    ; Configura o buzzer (digital 10 -> PB2) como saída
    in      r16, DDRB         ; DDRB está em endereço estendido
    ori     r16, (1 << PB2)
    out     DDRB, r16

    ; Configura o LED azul (digital 3 -> PD3) como saída
    in      r16, DDRD
    ori     r16, (1 << PD3)
    out     DDRD, r16

    ; Configura o servo (digital 9 -> PB1 - saída PWM OC1A) como saída
    in      r16, DDRB
    ori     r16, (1 << PB1)
    out     DDRB, r16

    ; --- Configuração do ADC ---
    ; Seleciona referência AVcc (REFS0 = 1) e canal 0 (LDR1)
    ldi     r16, (1 << REFS0)
    sts     ADMUX, r16
    ; Habilita o ADC e define prescaler para 128
    ldi     r16, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
    sts     ADCSRA, r16

    ; --- Configuração do Timer1 para PWM do Servo ---
    ; Configuração do TCCR1A: Fast PWM, modo 14 – 
    ; bits: COM1A1 (bit7) ativo, WGM11 (bit1) em 1.
    ldi     r16, (1 << COM1A1) | (1 << WGM11)
    sts     TCCR1A, r16
    ; Configuração do TCCR1B: Modo PWM Fast (WGM13 e WGM12) e prescaler 8 (CS11)
    ldi     r16, (1 << WGM13) | (1 << WGM12) | (1 << CS11)
    sts     TCCR1B, r16
    ; Define o TOP para 20ms: com 16MHz/8 = 2MHz, 20ms = 40000 ticks ? ICR1 = 39999
    ldi     r16, high(39999)
    sts     ICR1H, r16
    ldi     r16, low(39999)
    sts     ICR1L, r16
    ; Posição inicial do servo: 0° (pulso de 1ms = 2000 ticks)
    ldi     r16, high(2000)
    sts     OCR1AH, r16
    ldi     r16, low(2000)
    sts     OCR1AL, r16

; =======================================================
; Loop Principal
; =======================================================
MAIN_LOOP:
    ; ---------------------------------------------------
    ; Leitura do LDR1 (canal A0)
    ; ---------------------------------------------------
    ; Seleciona o canal 0: ADMUX = (REFS0)
    ldi     r16, (1 << REFS0)
    sts     ADMUX, r16
    ; Inicia a conversão ADC: seta o bit ADSC em ADCSRA
    lds     r16, ADCSRA
    ori     r16, (1 << ADSC)
    sts     ADCSRA, r16
WAIT_ADC_LDR1:
    lds     r16, ADCSRA
    sbrs    r16, ADIF       ; se ADIF estiver setado, pula a próxima instrução
    rjmp    WAIT_ADC_LDR1
    ; Limpa a flag ADIF (escrevendo 1 no bit ADIF)
    lds     r16, ADCSRA
    ori     r16, (1 << ADIF)
    sts     ADCSRA, r16
    ; Lê o resultado do ADC (leia ADCL primeiro!)
    lds     r18, ADCL       ; LDR1 – byte inferior
    lds     r19, ADCH       ; LDR1 – byte superior
    ; Compara com 512 (0x0200):
    ldi     r20, 0x00       ; parte baixa de 512
    ldi     r21, 0x02       ; parte alta de 512
    cp      r18, r20
    cpc     r19, r21
    brcc    LDR1_BUZZER_OFF   ; se ADC >= 512, desliga buzzer
    ; Se ADC < 512, ativa o buzzer (PB2)
    in      r16, PORTB
    ori     r16, (1 << PB2)
    out     PORTB, r16
    rjmp    LDR1_DONE
LDR1_BUZZER_OFF:
    in      r16, PORTB
    andi    r16, ~(1 << PB2)
    out     PORTB, r16
LDR1_DONE:

    ; ---------------------------------------------------
    ; Leitura do LDR2 (canal A1)
    ; ---------------------------------------------------
    ; Seleciona o canal 1: ADMUX = (REFS0) | 1
    ldi     r16, (1 << REFS0) | 1
    sts     ADMUX, r16
    ; Inicia a conversão ADC
    lds     r16, ADCSRA
    ori     r16, (1 << ADSC)
    sts     ADCSRA, r16
WAIT_ADC_LDR2:
    lds     r16, ADCSRA
    sbrs    r16, ADIF
    rjmp    WAIT_ADC_LDR2
    ; Limpa a flag ADIF
    lds     r16, ADCSRA
    ori     r16, (1 << ADIF)
    sts     ADCSRA, r16
    ; Lê o valor do ADC para LDR2
    lds     r18, ADCL
    lds     r19, ADCH
    ; Compara com 500 (0x01F4): se ADC < 500, acende o LED azul (PD3)
    ldi     r20, 0xF4       ; parte baixa de 500 (0xF4)
    ldi     r21, 0x01       ; parte alta de 500 (0x01)
    cp      r18, r20
    cpc     r19, r21
    brcc    LDR2_LED_OFF    ; se ADC >= 500, desliga o LED
    ; Acende o LED azul (PD3)
    in      r16, PORTD
    ori     r16, (1 << PD3)
    out     PORTD, r16
    rjmp    LDR2_DONE
LDR2_LED_OFF:
    in      r16, PORTD
    andi    r16, ~(1 << PD3)
    out     PORTD, r16
LDR2_DONE:

    ; ---------------------------------------------------
    ; Leitura do sensor HW-028 (canal A2)
    ; ---------------------------------------------------
    ; Seleciona o canal 2: ADMUX = (REFS0) | 2
    ldi     r16, (1 << REFS0) | 2
    sts     ADMUX, r16
    ; Inicia a conversão ADC
    lds     r16, ADCSRA
    ori     r16, (1 << ADSC)
    sts     ADCSRA, r16
WAIT_ADC_HW028:
    lds     r16, ADCSRA
    sbrs    r16, ADIF
    rjmp    WAIT_ADC_HW028
    ; Limpa a flag ADIF
    lds     r16, ADCSRA
    ori     r16, (1 << ADIF)
    sts     ADCSRA, r16
    ; Lê o valor do ADC para o sensor HW-028
    lds     r18, ADCL
    lds     r19, ADCH
    ; Compara com 700 (0x02BC): se ADC < 700, posiciona o servo em 180° (pulso de 2ms = 4000 ticks);
    ; caso contrário, posiciona para 0° (1ms = 2000 ticks)
    ldi     r20, 0xBC       ; parte baixa de 700
    ldi     r21, 0x02       ; parte alta de 700
    cp      r18, r20
    cpc     r19, r21
    brcc    SERVO_SET_0     ; se ADC >= 700, configura para 0°
    ; Se ADC < 700, posiciona o servo para 180°
    ldi     r16, high(4000)
    sts     OCR1AH, r16
    ldi     r16, low(4000)
    sts     OCR1AL, r16
    rjmp    SERVO_DONE
SERVO_SET_0:
    ; Configura o servo para 0° (pulso de 1ms = 2000 ticks)
    ldi     r16, high(2000)
    sts     OCR1AH, r16
    ldi     r16, low(2000)
    sts     OCR1AL, r16
SERVO_DONE:

    ; Reinicia o loop
    rjmp    MAIN_LOOP

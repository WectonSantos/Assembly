.include "m328pdef.inc"

; --- Inicialização ---
ldi r16, (1 << PB5)     ; Configura PB5 (LED) como saída
out DDRB, r16

ldi r16, 0x00           ; PB0 como entrada
out DDRB, r16

ldi r16, (1 << PB0)     ; Ativa pull-up interno no PB0
out PORTB, r16

; --- Loop principal ---
loop:
    in r17, PINB         ; Lê PB0
    sbrs r17, 0           ; Se PB0 == 1, pula
    rjmp liga_led        ; Se PB0 == 0 (chuva), acende LED

desliga_led:
    cbi PORTB, PB5        ; Apaga o LED
    rjmp loop

liga_led:
    sbi PORTB, PB5        ; Acende o LED
    rjmp loop

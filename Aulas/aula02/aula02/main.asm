;DDR ==> pinMode
;Registrador DDR define o estado do pino
;Saída = 1, Entrada = 0
;PORT ==> digitalWrite
;PORT sera para escrever o estado
;Acionado = 1, Desacionado = 0

;PORT ==> digitalRead
;PORT para escrever um estado
;seja acionado (1) desacionado (0)

;PIN ==> didigtalRead
;PIN para leitura de estado
;de um pino, setado (1) resetado (0)

;Comando SBI (Set Bit in I/O Register)
;sbi DDRB, PINB6 ;Setando o registrador DDDRB no bit 6 
;sbi DDRB, PINB5 ;Setando o registrador DDDRB no bit 5 
;sbi DDRB, PINB4 ;Setando o registrador DDDRB no bit 4 
;sbi DDRB, PIND3 ;Setando o registrador DDDRB no bit 3 
;sbi DDRB, PIND2 ;Setando o registrador DDDRB no bit 2 
;sbi DDRB, PIND0 ;Setando o registrador DDDRB no bit 2 

;Comando IN (Do I/O Register para GPR)
;in R30, DDRB 

;Comando OUT (Do GPR para I/O)
;ldi r20, 0x34 ;armazenando um valor
;out DDRB, r20

;Comando CBI (Clear Bit in I/O Register)
;cbi DDRB, PINB5

; EXEMPLO - Suponhamos que há um botão no PINB0, e um led no PINB5. Ao pressionar o botão,
;o LED deve ligar, e ao despressionar o botão, o LED deve desligar

;cbi DDRB, PINB0 ;Setando como entrada, porém não é necessário por que ele já é de entrada automaticamente
sbi DDRB, PINB5 ;Setando pino PB5 como saída (LED)

;METÓDO 01
;sbic PINB, 0 ;pula a linha se o botão estiver despressionado (PB0)
;sbi PORTB, PINB5 ;ligando o LED (PINB5)
;sbis PINB, 0 ;pula a linha se o botão estiver pressionado (PB0)
;cbi PORTB, PINB5 ;desligando o LED (PINB5)

;SBIS (Skip line if Bit in I/O Register is Set)
;sbis PINB, 0

;SBIC (Skip line if Bit in I/O Register is Clear)
;sbis PINB, 0


;METÓDO 02

inicio:
sbis PINB, 0; Pula linha se o botão pressionado (PB0)
rjmp desligaLED

ligaLED:
sbi PORTB, PINB5 ;ligar o LED (PB5)
rjmp inicio;voltando para o começo


desligaLED:
cbi PORTB, PINB5 ;desliga o LED (PB5)


inc r16
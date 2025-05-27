#include <Servo.h>  // Inclui a biblioteca Servo

// Definindo as portas
int ldr1Pin = A0;        // LDR1 na porta analógica A0
int ldr2Pin = A1;        // LDR2 na porta analógica A1
int hw028Pin = A2;       // Sensor HW-028 na porta analógica A2
int buzzerPin = 10;      // Buzzer na porta digital 10
const int ledBluePin = 3;  // Pino 3 do Arduino para controlar o MOSFET

Servo meuServo;         // Cria o objeto para controlar o servo

void setup() {
  Serial.begin(9600);    // Inicia a comunicação serial
  meuServo.attach(9);    // Conecta o servo na porta 9
  pinMode(buzzerPin, OUTPUT);  // Define o pino do buzzer como saída
  meuServo.write(0);  // Move o servo para 180 graus
  pinMode(ledBluePin, OUTPUT);  // Configura o pino 3 como saída

}

void loop() {
  // Leitura dos LDRs
  int ldr1Value = analogRead(ldr1Pin);  // Lê o valor do LDR1
  int ldr2Value = analogRead(ldr2Pin);  // Lê o valor do LDR2
  
  // Leitura do sensor HW-028
  int hw028Value = analogRead(hw028Pin);  // Lê o valor do sensor HW-028
  
  // Imprime os valores dos sensores no Serial Monitor
  Serial.print("LDR1: ");
  Serial.println(ldr1Value);
  Serial.print(" LDR2: ");
  Serial.println(ldr2Value);
  Serial.print(" HW-028: ");
  Serial.println(hw028Value);
  
  
  
  // Controle do buzzer baseado no valor do LDR2
  if (ldr1Value < 512) {  // Se o LDR2 estiver em um ambiente mais claro
    digitalWrite(buzzerPin, HIGH);  // Aciona o buzzer
    delay(1000);
    digitalWrite(buzzerPin, LOW);  // Aciona o buzzer
  }

  if (ldr2Value < 500) {  // Se o LDR2 estiver em um ambiente mais claro
    digitalWrite(ledBluePin, HIGH);  // Acende o LED azul
  }

  // Ação com base no sensor HW-028
  if (hw028Value < 700) {  // Se a leitura do sensor HW-028 for maior que 512 (valor de referência)
      meuServo.write(180);  // Move o servo para 180 graus
  }

  delay(1000);

  }

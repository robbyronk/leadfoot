#include "FastLED.h"
#define NUM_LEDS 16
#define DATA_PIN 6
#define BRIGHTNESS 32

CRGB leds[NUM_LEDS];

void setup() {
  Serial.begin(115200);
  FastLED.addLeds<NEOPIXEL, DATA_PIN>(leds, NUM_LEDS);
  startupLEDsTest();
}

void loop() {
  char in = Serial.read();

  if ( in == 'L' ) {
    handleLedCommand();
  }
  // todo more commands
}

void handleLedCommand() {
  static byte input[4];
  static int ledIndex;
  if (Serial.readBytes(input, 4) != 4) {
    return;
  }
  if (input[0] > NUM_LEDS - 1) {
    return;
  }
  FastLED.clear();
  leds[input[0]].red = input[1];
  leds[input[0]].green = input[2];
  leds[input[0]].blue = input[3];
  FastLED.show();
}

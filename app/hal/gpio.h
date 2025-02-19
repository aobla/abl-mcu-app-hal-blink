#pragma once

#define LED_PORT LED_GPIO_PORT  // Определяется в сгенерированном gpio_config.h
#define LED_PIN  LED_GPIO_PIN

typedef enum {
    GPIO_MODE_OUTPUT
} GPIOMode;

void GPIO_Init(uint32_t port, uint32_t pin, GPIOMode mode);
void GPIO_Toggle(uint32_t port, uint32_t pin);
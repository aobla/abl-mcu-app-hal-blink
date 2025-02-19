#include "hal/gpio.h"  // Абстрактный интерфейс
#include "stm32f1xx_hal.h"  // Конкретный HAL

void SystemClock_Config();  // Реализация зависит от MCU

int main() {
    HAL_Init();
    SystemClock_Config();
    GPIO_Init(LED_PORT, LED_PIN, GPIO_MODE_OUTPUT);

    while (1) {
        GPIO_Toggle(LED_PORT, LED_PIN);
        HAL_Delay(500);
    }
}
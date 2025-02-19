cmake_minimum_required(VERSION 3.15)
project(abl-mcu-app-blink C)

# Подключение платформы
include(${CMAKE_SOURCE_DIR}/platform/abl-mcu-platform-core/cmake/mcu/${TARGET}.cmake)
include(${CMAKE_SOURCE_DIR}/platform/abl-mcu-platform-core/cmake/compiler/toolchain-arm-none-eabi-gcc.cmake)

# Генерация GPIO-конфига
add_custom_target(generate_pins ALL
    DEPENDS ${CMAKE_BINARY_DIR}/generated/gpio_config.h
)

# Исполняемый файл
add_executable(${PROJECT_NAME}
    app/main.c
    ${STARTUP_ASM}
    drivers/stm32f1xx-hal-driver/Src/stm32f1xx_hal_gpio.c
)

# Зависимости
add_dependencies(${PROJECT_NAME} generate_pins)
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_BINARY_DIR}/generated
    ${HAL_DIR}/Inc
)

# Линковка
target_link_script(${PROJECT_NAME} ${LINKER_SCRIPT})
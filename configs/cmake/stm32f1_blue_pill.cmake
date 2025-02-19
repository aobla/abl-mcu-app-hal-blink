# Настройки для STM32F1 Blue Pill
include(${PLATFORM_PATH}/cmake/parse_yaml.cmake)

# Парсинг target.yaml и pinmux.yaml
parse_yaml(${PROJECT_SOURCE_DIR}/configs/target.yaml "TARGET_")
parse_yaml(${PROJECT_SOURCE_DIR}/configs/pinmux.yaml "PINMUX_")

# Конфигурация MCU
set(MCU_MODEL ${TARGET_mcu} CACHE STRING "STM32F103C8")
set(CPU_FREQ ${TARGET_clock} CACHE STRING "72MHz")

string(TOUPPER ${MCU_MODEL} MCU_DEFINE)  # Например, STM32F103C8TX

# Специфичные флаги для STM32F1
add_compile_definitions(
    ${MCU_DEFINE}
    USE_HAL_DRIVER
    HSE_VALUE=${CPU_FREQ}
)

# Пути к HAL
set(HAL_DIR ${PROJECT_SOURCE_DIR}/drivers/stm32f1xx-hal-driver)
include_directories(
    ${HAL_DIR}/Inc
    # ${PLATFORM_PATH}/templates/stm32f1
    ${PLATFORM_PATH}/templates/linker_scripts
    ${PLATFORM_PATH}/templates/startup
    ${PROJECT_SOURCE_DIR}/platform/configs/mcu
    ${PROJECT_BINARY_DIR}/generated  # Для gpio_config.h
)

# Генерация GPIO-конфига
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/generated/gpio_config.h
    COMMAND python ${PLATFORM_PATH}/scripts/generate_pins.py
        -i ${PROJECT_SOURCE_DIR}/configs/pinmux.yaml
        -o ${CMAKE_BINARY_DIR}/generated/gpio_config.h
    DEPENDS ${PROJECT_SOURCE_DIR}/configs/pinmux.yaml
)

# Стартап и линкер
set(STARTUP_ASM ${PLATFORM_PATH}/templates/startup/startup_stm32f103x6.s)
set(LINKER_SCRIPT ${PLATFORM_PATH}/templates/linker_scripts/STM32F103X6_FLASH.ld)
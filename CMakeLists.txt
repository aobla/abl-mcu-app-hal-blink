cmake_minimum_required(VERSION 3.15)
project(abl-mcu-app-blink C)

# Подключение платформы
set(PLATFORM_PATH ${CMAKE_SOURCE_DIR}/platform/abl-mcu-platform-core)
include(${CMAKE_SOURCE_DIR}/platform/abl-mcu-platform-core/cmake/mcu/mcu.cmake)
include(${CMAKE_SOURCE_DIR}/platform/abl-mcu-platform-core/cmake/compiler/toolchain-arm-none-eabi-gcc.cmake)

# Создаем директорию для сгенерированных файлов
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/generated)

# Генерация gpio_config.h
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/generated/gpio_config.h
    COMMAND python3 ${PLATFORM_PATH}/scripts/generate_pinmux.py
        -i ${PROJECT_SOURCE_DIR}/configs/pinmux.yaml
        -o ${CMAKE_BINARY_DIR}/generated/gpio_config.h
    DEPENDS ${PROJECT_SOURCE_DIR}/configs/pinmux.yaml
    COMMENT "Generating GPIO config..."
)

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

# Линковка с указанием скрипта
target_link_options(${PROJECT_NAME} PRIVATE 
    -T${LINKER_SCRIPT}  # Флаг -T + путь к скрипту
    -Wl,--print-memory-usage  # Опционально: другие флаги
    -Wl,--cref,-Map=${PROJECT_NAME}.map
)

# Подключение HAL и других библиотек
target_link_libraries(${PROJECT_NAME} PRIVATE 
    stm32f1xx_hal
)
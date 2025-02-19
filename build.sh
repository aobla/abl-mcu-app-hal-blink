#!/bin/bash
# Аргумент: название платформы из configs/targets (например, stm32f1_blue_pill)
TARGET=$1

#
# Проверка аргумента
#
if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

#
# target
#
CONFIG_FILE="configs/target/${TARGET}.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config for $TARGET not found!"
    exit 1
fi
# Копирование выбранного конфига в target.yaml
cp $CONFIG_FILE configs/target.yaml

#
# pinmux
#
PINMUX_FILE="configs/pinmux/${TARGET}_pinmux.yaml"
if [ ! -f "$PINMUX_FILE" ]; then
    echo "Error: Pinmux for $TARGET not found!"
    exit 1
fi
# Копирование выбранного конфига в target.yaml
cp $PINMUX_FILE configs/pinmux.yaml

#
# cmake
#
CMAKE_FILE="configs/cmake/${TARGET}.cmake"
if [ ! -f "$CMAKE_FILE" ]; then
    echo "Error: $TARGET.cmake file for $TARGET not found!"
    exit 1
fi
# Копирование выбранного конфига в mcu.cmake
cp $CMAKE_FILE platform/abl-mcu-platform-core/cmake/mcu/mcu.cmake

#
# Загрузка HAL для выбранного TARGET (пример для STM32F1)
# todo добавить флаг debug/release или продумать как это сделать, возможно файл _versions.yaml
case $TARGET in
    "stm32f1_blue_pill")
        git submodule add https://github.com/STMicroelectronics/stm32f1xx-hal-driver.git drivers/stm32f1xx-hal-driver
        ;;
    "esp32")
        git submodule add -b release/v4.4 https://github.com/espressif/esp-idf.git drivers/esp_idf
        ;;
esac

git submodule add -b dev https://github.com/aobla/abl-mcu-platform-core.git platform/abl-mcu-platform-core

# Инициализация подмодулей
git submodule update --init --recursive

#
# Проверка компилятора
#
if ! command -v arm-none-eabi-gcc &> /dev/null; then
    echo "Error: Install ARM compiler: run platform/abl-mcu-platform-core/scripts/prerequisite_install.sh"
    exit 1
fi

#
# Сборка
#
mkdir -p build && cd build
cmake .. --debug-trycompile -DCMAKE_TOOLCHAIN_FILE=../platform/abl-mcu-platform-core/cmake/compiler/toolchain-arm-none-eabi-gcc.cmake
make -j4
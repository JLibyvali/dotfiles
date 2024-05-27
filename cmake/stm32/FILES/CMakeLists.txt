cmake_minimum_required(VERSION 3.22)

project(${PROJECT_FILES})
add_library(${PROJECT_FILES} INTERFACE)

set(START_FILE "${CMAKE_CURRENT_LIST_DIR}/startup_stm32f103xb.s")
get_filename_component(START_FILE_ABSOLUTE  ${START_FILE} ABSOLUTE)

enable_language(C ASM)

target_compile_definitions(
  ${PROJECT_FILES} INTERFACE USE_HAL_DRIVER STM32F103xB
                                  $<$<CONFIG:Debug>:DEBUG>)

target_include_directories(
  ${PROJECT_FILES}
  INTERFACE ../Core/Inc
            ../Drivers/STM32F1xx_HAL_Driver/Inc
            ../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy
            ../Drivers/CMSIS/Device/ST/STM32F1xx/Include
            ../Drivers/CMSIS/Include)

target_sources(
  ${PROJECT_FILES}
  INTERFACE ../Core/Src/main.c
            ../Core/Src/gpio.c
            ../Core/Src/stm32f1xx_it.c
            ../Core/Src/stm32f1xx_hal_msp.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim_ex.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c
            ../Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_exti.c
            ../Core/Src/system_stm32f1xx.c
            ../Core/Src/sysmem.c
            ../Core/Src/syscalls.c
            ${START_FILE_ABSOLUTE}
            )

# for link library
target_link_directories(${CMAKE_PROJECT_NAME} INTERFACE)
target_link_libraries(${CMAKE_PROJECT_NAME} INTERFACE)


# Validate that STM32CubeMX code is compatible with C standard
if(CMAKE_C_STANDARD LESS 11)
    message(ERROR "Generated code requires C11 or higher")
endif()

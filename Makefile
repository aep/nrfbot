SDK_PATH=../
PROJECT_NAME := ix_wetterstation

export OUTPUT_FILENAME
#MAKEFILE_NAME := $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
MAKEFILE_NAME := $(MAKEFILE_LIST)
MAKEFILE_DIR := $(dir $(MAKEFILE_NAME) ) 

TEMPLATE_PATH = $(SDK_PATH)components/toolchain/gcc
ifeq ($(OS),Windows_NT)
include $(TEMPLATE_PATH)/Makefile.windows
else
include $(TEMPLATE_PATH)/Makefile.posix
endif

MK := mkdir
RM := rm -rf

#echo suspend
ifeq ("$(VERBOSE)","1")
NO_ECHO := 
else
NO_ECHO := @
endif

# Toolchain commands
CC       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-gcc"
AS       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-as"
AR       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar" -r
LD       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ld"
NM       		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-nm"
OBJDUMP  		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objdump"
OBJCOPY  		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objcopy"
SIZE    		:= "$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-size"

#function for removing duplicates in a list
remduplicates = $(strip $(if $1,$(firstword $1) $(call remduplicates,$(filter-out $(firstword $1),$1))))

#source common to all targets
C_SOURCE_FILES += \
$(SDK_PATH)components/libraries/button/app_button.c \
$(SDK_PATH)components/libraries/fifo/app_fifo.c \
$(SDK_PATH)components/libraries/timer/app_timer.c \
$(SDK_PATH)components/libraries/trace/app_trace.c \
$(SDK_PATH)components/libraries/util/nrf_assert.c \
$(SDK_PATH)components/libraries/uart/retarget.c \
$(SDK_PATH)components/libraries/sensorsim/sensorsim.c \
$(SDK_PATH)components/drivers_nrf/uart/app_uart_fifo.c \
$(SDK_PATH)components/drivers_nrf/hal/nrf_delay.c \
$(SDK_PATH)components/drivers_nrf/common/nrf_drv_common.c \
$(SDK_PATH)components/drivers_nrf/gpiote/nrf_drv_gpiote.c \
$(SDK_PATH)components/drivers_nrf/pstorage/pstorage.c \
$(SDK_PATH)components/ble/common/ble_advdata.c \
$(SDK_PATH)components/ble/ble_advertising/ble_advertising.c \
$(SDK_PATH)components/ble/ble_services/ble_bas/ble_bas.c \
$(SDK_PATH)components/ble/ble_services/ble_bps/ble_bps.c \
$(SDK_PATH)components/ble/common/ble_conn_params.c \
$(SDK_PATH)components/ble/ble_services/ble_dis/ble_dis.c \
$(SDK_PATH)components/ble/common/ble_srv_common.c \
$(SDK_PATH)components/ble/device_manager/device_manager_peripheral.c \
$(SDK_PATH)components/toolchain/system_nrf51.c \
$(SDK_PATH)components/softdevice/common/softdevice_handler/softdevice_handler.c \
$(SDK_PATH)components/ble/ble_debug_assert_handler/ble_debug_assert_handler.c \
$(SDK_PATH)components/ble/ble_error_log/ble_error_log.c \
$(SDK_PATH)components/drivers_nrf/ble_flash/ble_flash.c \
$(SDK_PATH)components/ble/ble_services/ble_hts/ble_hts.c \
$(SDK_PATH)components/drivers_nrf/twi_master/incubated/twi_sw_master.c \
$(SDK_PATH)components/ble/ble_services/ble_nus/ble_nus.c \
bsp/bsp.c \
main.c \
lcd.c \

#assembly files common to all targets
ASM_SOURCE_FILES  = $(SDK_PATH)components/toolchain/gcc/gcc_startup_nrf51.s

#includes common to all targets
INC_PATHS  = -Iconfig -I.
INC_PATHS += -Ibsp
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/config
INC_PATHS += -I$(SDK_PATH)components/libraries/fifo
INC_PATHS += -I$(SDK_PATH)components/libraries/util
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/pstorage
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/uart
INC_PATHS += -I$(SDK_PATH)components/ble/common
INC_PATHS += -I$(SDK_PATH)components/libraries/sensorsim
INC_PATHS += -I$(SDK_PATH)components/ble/ble_services/ble_bps
INC_PATHS += -I$(SDK_PATH)components/ble/device_manager
INC_PATHS += -I$(SDK_PATH)components/ble/ble_services/ble_dis
INC_PATHS += -I$(SDK_PATH)components/device
INC_PATHS += -I$(SDK_PATH)components/libraries/button
INC_PATHS += -I$(SDK_PATH)components/libraries/timer
INC_PATHS += -I$(SDK_PATH)components/softdevice/s110/headers
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/gpiote
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/hal
INC_PATHS += -I$(SDK_PATH)components/toolchain/gcc
INC_PATHS += -I$(SDK_PATH)components/toolchain
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/common
INC_PATHS += -I$(SDK_PATH)components/ble/ble_advertising
INC_PATHS += -I$(SDK_PATH)components/libraries/trace
INC_PATHS += -I$(SDK_PATH)components/ble/ble_services/ble_bas
INC_PATHS += -I$(SDK_PATH)components/softdevice/common/softdevice_handler
INC_PATHS += -I$(SDK_PATH)components/ble/ble_debug_assert_handler/
INC_PATHS += -I$(SDK_PATH)components/ble/ble_error_log/
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/ble_flash/
INC_PATHS += -I$(SDK_PATH)components/ble/ble_services/ble_hts/
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/twi_master/incubated/
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/hal/
INC_PATHS += -I$(SDK_PATH)components/drivers_nrf/uart/
INC_PATHS += -I$(SDK_PATH)components/ble/ble_services/ble_nus/

OBJECT_DIRECTORY = _build
LISTING_DIRECTORY = $(OBJECT_DIRECTORY)
OUTPUT_BINARY_DIRECTORY = $(OBJECT_DIRECTORY)

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )

#flags common to all targets
CFLAGS += -DSOFTDEVICE_PRESENT
CFLAGS += -DNRF51
CFLAGS += -DS110
CFLAGS += -DBLE_STACK_SUPPORT_REQD
CFLAGS += -DSWI_DISABLE0
CFLAGS += -mcpu=cortex-m0
CFLAGS += -mthumb -mabi=aapcs --std=gnu99
CFLAGS += -Wall -Werror -O3
CFLAGS += -mfloat-abi=soft
# keep every function in separate section. This will allow linker to dump unused functions
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin --short-enums

# keep every function in separate section. This will allow linker to dump unused functions
LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
LDFLAGS += -mthumb -mabi=aapcs -L $(TEMPLATE_PATH) -T$(LINKER_SCRIPT)
LDFLAGS += -mcpu=cortex-m0
# let linker to dump unused sections
LDFLAGS += -Wl,--gc-sections
# use newlib in nano version
LDFLAGS += --specs=nano.specs -lc -lnosys

# Assembler flags
ASMFLAGS += -x assembler-with-cpp
ASMFLAGS += -DBOARD_PCA10028
ASMFLAGS += -DSOFTDEVICE_PRESENT
ASMFLAGS += -DNRF51
ASMFLAGS += -DS110
ASMFLAGS += -DBLE_STACK_SUPPORT_REQD
ASMFLAGS += -DSWI_DISABLE0
#default target - first one defined
default: clean nrf51422_xxac_s110

#building all targets
all: clean
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e cleanobj
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e nrf51422_xxac_s110 

#target for printing all targets
help:
	@echo following targets are available:
	@echo 	nrf51422_xxac_s110
	@echo 	flash_softdevice


C_SOURCE_FILE_NAMES = $(notdir $(C_SOURCE_FILES))
C_PATHS = $(call remduplicates, $(dir $(C_SOURCE_FILES) ) )
C_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(C_SOURCE_FILE_NAMES:.c=.o) )

ASM_SOURCE_FILE_NAMES = $(notdir $(ASM_SOURCE_FILES))
ASM_PATHS = $(call remduplicates, $(dir $(ASM_SOURCE_FILES) ))
ASM_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(ASM_SOURCE_FILE_NAMES:.s=.o) )

vpath %.c $(C_PATHS)
vpath %.s $(ASM_PATHS)

OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

nrf51422_xxac_s110: OUTPUT_FILENAME := nrf51422_xxac_s110
nrf51422_xxac_s110: LINKER_SCRIPT=armgcc_s110_nrf51422_xxaa.ld
nrf51422_xxac_s110: $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: $(OUTPUT_FILENAME).out
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e finalize

## Create build directories
$(BUILD_DIRECTORIES):
	echo $(MAKEFILE_NAME)
	$(MK) $@

# Create objects from C SRC files
$(OBJECT_DIRECTORY)/%.o: %.c
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<

# Assemble files
$(OBJECT_DIRECTORY)/%.o: %.s
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) $(ASMFLAGS) $(INC_PATHS) -c -o $@ $<


# Link
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out: $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: $(OUTPUT_FILENAME).out
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out


## Create binary .bin file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	@echo Preparing: $(OUTPUT_FILENAME).bin
	$(NO_ECHO)$(OBJCOPY) -O binary $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin

## Create binary .hex file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	@echo Preparing: $(OUTPUT_FILENAME).hex
	$(NO_ECHO)$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

finalize: genbin genhex echosize

genbin:
	@echo Preparing: $(OUTPUT_FILENAME).bin
	$(NO_ECHO)$(OBJCOPY) -O binary $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin

## Create binary .hex file from the .out file
genhex: 
	@echo Preparing: $(OUTPUT_FILENAME).hex
	$(NO_ECHO)$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

echosize:
	-@echo ""
	$(NO_ECHO)$(SIZE) $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	-@echo ""

clean:
	$(RM) $(BUILD_DIRECTORIES)

cleanobj:
	$(RM) $(BUILD_DIRECTORIES)/*.o

flash: $(MAKECMDGOALS)
	@echo Flashing: $(OUTPUT_BINARY_DIRECTORY)/$<.hex
	nrfjprog --reset --program $(OUTPUT_BINARY_DIRECTORY)/$<.hex

## Flash softdevice
flash_softdevice: 
	@echo Flashing: s110_softdevice.hex
	nrfjprog --reset --program $(SDK_PATH)components/softdevice/s110/hex/s110_softdevice.hex

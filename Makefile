ifeq ($(KERNEL_A32_SUPPORT), true)
KERNEL_ARCH := arm
else
KERNEL_ARCH := arm64
endif


#EXTRA_CFLAGS1 += -Wno-error
#ifeq ($(PLATFORM_VERSION),10)
#CONFIGS := CONFIG_PLATFORM_VERSION=10
#else
#CONFIGS := CONFIG_PLATFORM_VERSION=9
#endif

HAS_PM_DOMAIN ?= 1
DEBUG ?= 0

ifeq ($(DEBUG),1)
EXTRA_CFLAGS1 += -DCONFIG_ADLAK_DEBUG=1
endif

ifneq ($(DEBUG),1)
EXTRA_LDFLAGS1 += --strip-debug
#EXTRA_CFLAGS1 += -Wno-error
endif

ifeq ($(HAS_PM_DOMAIN),0)
EXTRA_CFLAGS1 += -DCONFIG_HAS_PM_DOMAIN=0
endif

#CONFIG_MODULE_SIG=n



EXTRA_INCLUDE := -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/port/platform/linux
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/port/platform
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/port/os/linux/mm
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/port/os/linux
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/port/os
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/port
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/uapi/linux
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/uapi
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/common/mm
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv/common
EXTRA_INCLUDE += -I$(KERNEL_SRC)/$(M)/adla/kmd/drv

# file_adlak_version := $(KERNEL_SRC)/$(M)/adla/kmd/drv/common/adlak_version.h


#CONFIGS_BUILD := -Wno-undef -Wno-pointer-sign \
#		-Wno-unused-const-variable \
#		-Wimplicit-function-declaration \
#		-Wno-unused-function


modules:
	$(MAKE) -C $(KERNEL_SRC) M=$(M)/adla/kmd  modules ARCH=$(KERNEL_ARCH)  "EXTRA_LDFLAGS+=$(EXTRA_LDFLAGS1)" "EXTRA_CFLAGS+= -Wno-error $(EXTRA_CFLAGS1) $(CONFIGS_BUILD) $(EXTRA_INCLUDE)" $(CONFIGS)

# include $(KERNEL_SRC)/$(M)/VERSION
# ADLAK_V_MAJOR := $(strip $(ADLA_DRIVER_V_MAJOR))
# ADLAK_V_MINOR := $(strip $(ADLA_DRIVER_V_MINOR))
# ADLAK_V_PATCH := $(strip $(ADLA_DRIVER_V_PATCH))

# FORCE:

# Generate a temporary adlak_version.h
# generate-files: $(file_adlak_version)
# $(file_adlak_version):FORCE
	# @echo "Generate $@"
	# @echo "" > $@
	# @echo /\* This file is auto generated\*/ >> $@
	# @echo \#ifndef __ADLAK_VERSION_H__ >> $@
	# @echo \#define __ADLAK_VERSION_H__ >> $@
	# @echo \#define ADLAK_VERSION \"$(ADLAK_V_MAJOR).$(ADLAK_V_MINOR).$(ADLAK_V_PATCH)\" >> $@
	# @echo "" >> $@
	# @echo \#define ADLAK_VERSION_MAJOR $(ADLAK_V_MAJOR) >> $@
	# @echo \#define ADLAK_VERSION_MINOR $(ADLAK_V_MINOR) >> $@
	# @echo \#define ADLAK_VERSION_RSV $(ADLAK_V_PATCH) >> $@
	# @echo '#define ADLAK_VERSION_VAL  ((ADLAK_VERSION_MAJOR << 16) + ((ADLAK_VERSION_MINOR) << 8) + (ADLAK_VERSION_RSV))' >> $@
	# @echo '#endif /* __ADLAK_VERSION_H__ end define*/' >> $@
	# @echo "" >> $@
# del-generate-files: $(file_adlak_version)
	# @echo  "Remove the temporary files...\n $^"
	# @rm -fv $^

ifeq ($(O),)
out_dir := .
else
out_dir := $(O)
endif
include $(out_dir)/include/config/auto.conf

all:modules

modules_install:
	$(MAKE) INSTALL_MOD_STRIP=1 M=$(M)/adla/kmd -C $(KERNEL_SRC) modules_install
	$(Q)mkdir -p ${out_dir}/../vendor_lib/modules
	$(Q)if [ -z "$(CONFIG_AMLOGIC_KERNEL_VERSION)" ]; then \
		cd ${out_dir}/$(M)/; find -name "*.ko" -exec cp {} ${out_dir}/../vendor_lib/modules/ \; ; \
	else \
		find $(INSTALL_MOD_PATH)/lib/modules/*/$(INSTALL_MOD_DIR) -name "*.ko" -exec cp {} ${out_dir}/../vendor_lib/modules \; ; \
	fi;

#clean:del-generate-files
#$(MAKE) -C $(KERNEL_SRC) M=$(M) clean

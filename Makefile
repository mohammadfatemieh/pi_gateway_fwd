### Application-specific constants

APP_NAME := lora_pkt_fwd

### Environment constants 

LGW_PATH ?= ../../lora_gateway/libloragw
ARCH ?=
CROSS_COMPILE ?=

OBJDIR = obj
INCLUDES = $(wildcard inc/*.h)

### External constant definitions
# must get library build option to know if mpsse must be linked or not

include $(LGW_PATH)/library.cfg
RELEASE_VERSION := `cat ../VERSION`

### Constant symbols

CC := $(CROSS_COMPILE)gcc
AR := $(CROSS_COMPILE)ar

CFLAGS := -O2 -Wall -Wextra -std=c99 -Iinc -I.
VFLAG := -D VERSION_STRING="\"$(RELEASE_VERSION)\""

### Constants for Lora concentrator HAL library
# List the library sub-modules that are used by the application

LGW_INC =
ifneq ($(wildcard $(LGW_PATH)/inc/config.h),)
  # only for HAL version 1.3 and beyond
  LGW_INC += $(LGW_PATH)/inc/config.h
endif
LGW_INC += $(LGW_PATH)/inc/loragw_hal.h
LGW_INC += $(LGW_PATH)/inc/loragw_gps.h

### Linking options

LIBS := -lloragw -luci -lrt -lpthread -lm

### General build targets

all: $(APP_NAME) single_tx
#all: $(APP_NAME)

clean:
	rm -f $(OBJDIR)/*.o
	rm -f $(APP_NAME) single_tx

### Sub-modules compilation

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: src/%.c $(INCLUDES) | $(OBJDIR)
	$(CC) -c $(CFLAGS) -I$(LGW_PATH)/inc $< -o $@

### Main program compilation and assembly

$(OBJDIR)/single_tx.o: src/single_tx.c $(LGW_INC) $(INCLUDES) | $(OBJDIR)
	$(CC) -c $(CFLAGS) $(VFLAG) -I$(LGW_PATH)/inc $< -o $@

single_tx: $(OBJDIR)/single_tx.o $(LGW_PATH)/libloragw.a $(OBJDIR)/radio.o
	$(CC) -L$(LGW_PATH) $< $(OBJDIR)/radio.o -o $@ $(LIBS)

$(OBJDIR)/$(APP_NAME).o: src/$(APP_NAME).c $(LGW_INC) $(INCLUDES) | $(OBJDIR)
	$(CC) -c $(CFLAGS) $(VFLAG) -I$(LGW_PATH)/inc $< -o $@

$(APP_NAME): $(OBJDIR)/$(APP_NAME).o $(LGW_PATH)/libloragw.a $(OBJDIR)/parson.o $(OBJDIR)/radio.o $(OBJDIR)/base64.o $(OBJDIR)/jitqueue.o $(OBJDIR)/timersync.o
	$(CC) -L$(LGW_PATH) $< $(OBJDIR)/parson.o $(OBJDIR)/base64.o $(OBJDIR)/jitqueue.o $(OBJDIR)/timersync.o $(OBJDIR)/radio.o -o $@ $(LIBS)

### EOF
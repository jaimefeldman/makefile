# Makefile by Jaime Feldman B. 2020.
#
######################################################################
# MACROS
######################################################################
# $(1) : Source file.
define CPP2OBJ
	$(patsubst %.cpp,%.o,$(patsubst $(SRC)%,$(OBJ)%,$(1)))
endef

define C2OBJ
	$(patsubst %.c,%.o,$(patsubst $(SRC)%,$(OBJ)%,$(1)))
endef

# $(1) : Nombre del archivo compilando.
define PRINTOK
	echo -n ${1}; \
	printf %$$(($(TERMIANL_HALF_COLS_SIZE) - $(shell echo -n $(1) | wc -c)))s | tr " " "."; \
	echo -e "[${green}OK${NOC}]"
endef

# $(1) : Nombre del archivo compilando.
define PRINTFAIL
	echo -n ${1}; \
	printf %$$(($(TERMIANL_HALF_COLS_SIZE) - $(shell echo -n $(1) | wc -c)))s | tr " " "."; \
	echo -e "[${red}STOP${NOC}]"
endef

######################################################################
# CONFIG
######################################################################

red		=\033[0;31m
green	=\033[0;32m
NOC		=\033[0m

SHELL    := /bin/bash
APP      := bin/ejecutable
APPLINK  := appEjecutable
CCFLAGAS := -std=c++17 -Wall -O3 -Wno-c++11-extensions
CFLAGS   := -std=c99 -Wall -pedantic
INCLUDES := src/clases/
CC       := g++
C		 := gcc
MKDIR    := mkdir -p
SRC      := src
OBJ      := obj
BIN      := bin

ALLCPPS         := $(shell find $(SRC) -type f -iname *.cpp)
ALLCS		    := $(shell find $(SRC) -type f -iname *.c)
SUBDIRS         := $(shell find $(SRC) -type d)
OBJSUBDIRS      := $(patsubst $(SRC)%,$(OBJ)%,$(SUBDIRS))
OBJECTS_FILES   := $(foreach F,$(ALLCPPS),$(call CPP2OBJ,$(F)))
C_OBJECTS_FILES := $(foreach F,$(ALLCS),$(call C2OBJ,$(F)))

TERMINAL_COLS_SIZE      :=$(shell tput cols)
TERMIANL_HALF_COLS_SIZE :=$$(($(TERMINAL_COLS_SIZE) / 2 - 10))

.PHONY: info clean project debug memchk
.SILENT: clean debug memchk $(APP) $(OBJECTS_FILES) $(OBJSUBDIRS) $(C_OBJECTS_FILES) 

$(APP): $(OBJSUBDIRS) $(OBJECTS_FILES) $(C_OBJECTS_FILES)

	if [ -d "bin" ]; then \
		$(CC) -o $(APP) $(OBJECTS_FILES) $(C_OBJECTS_FILES) $(CCFLAGAS); \
	else \
		mkdir -p bin; \
		$(CC) -o $(APP) $(OBJECTS_FILES) $(CCFLAGAS) $(C_OBJECTS_FILES); \
	fi

	$(call PRINTOK,"Enlazando $(APP)")

	if [ -a $(APP) ]; then \
		ln -f -s $(APP) $(APPLINK); \
		$(call PRINTOK,"Crando enalce simbolico $(APPLINK)"); \
	else \
		$(call PRINTFAIL,"Creando enlace simbolico $(APPLINK)"); \
	fi

$(OBJ)/%.o : $(SRC)/%.cpp
	$(CC) -o $(patsubst $(SRC)%,$(OBJ)%,$@) -c $^ $(CCFLAGAS)
	$(call PRINTOK,"Copilando "$^)

$(OBJ)/%.o : $(SRC)/%.c
	$(C) -o $(patsubst $(SRC)%,$(OBJ)%,$@) -c $^ $(CFLAGAS)
	$(call PRINTOK,"Copilando "$^)

debug:
	$(info $(ALLCPPS))
	$(info $(OBJECTS_FILES))
	$(info $(ALLCS))
	$(info $(C_OBJECTS_FILES))

info:
	@echo " + Información de la compilación de $(APP) +"
	@echo " - Nivel de optimización: 3"
	@echo " - Usando el standard c++ 17"
	@echo " - Todos los Warning activados."
	@echo " - Desactivados los avisos de extenciones de c++ 11"
	
CCFLAGAS := -std=c++17 -Wall -O3 -Wno-c++11-extensions

$(OBJSUBDIRS):
	$(MKDIR) $(OBJSUBDIRS) 
	$(call PRINTOK,"Creando estructura de directorios")
#	$(MKDIR) $(OBJSUBDIRS) > /dev/null 2>&1

clean:
	if [ $(shell find $(OBJ) -type f -iname *.o | wc -l)  -gt 0 ]; then \
		find $(OBJ) -type f -iname *.o -delete; \
		rm -f $(APP); \
		rm -f $(APPLINK); \
		$(call PRINTOK, "Limpiando el proyecto"); \
	else \
		$(call PRINTFAIL,"El proyecto se encuentra limpio"); \
    fi

memchk:
	@echo "+ Chequeando fugas de memoria +"


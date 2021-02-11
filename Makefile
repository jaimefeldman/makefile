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
	echo -e "${NOC}[${green}OK${NOC}]${gris}"
endef

# $(1) : Nombre del archivo compilando.
define PRINTFAIL
	echo -n ${1}; \
	printf %$$(($(TERMIANL_HALF_COLS_SIZE) - $(shell echo -n $(1)} | wc -c)))s | tr " " "."; \
	echo -e "${NOC}[${red}STOP${NOC}]${girs}"
endef

define MESSAGE
	echo -e "[${red}Welcome Message${NOC}]"
endef

######################################################################
# CONFIG
######################################################################

red		   =\033[0;91m
green	   =\033[0;92m
blue       =\033[0;34m
purple     =\033[0;35m
yellowdark =\033[0;33m
yellow	   =\033[0;93m
purpleDark =\033[0;36m
greenDark  =\033[0;96m
gris	   =\033[0;2m
NOC		   =\033[0m

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

OS_TYPE := "" 
PROJECT_NAME	:= $(shell basename $(shell pwd))

TERMINAL_COLS_SIZE      :=$(shell tput cols)
TERMIANL_HALF_COLS_SIZE :=$$(($(TERMINAL_COLS_SIZE) / 2 - 10))


.PHONY: info clean project debug memchk test
.SILENT: clean debug memchk test $(APP) $(OBJECTS_FILES) $(OBJSUBDIRS) $(C_OBJECTS_FILES) 


UNAME   := $(shell uname)
CMDGOAL := $(firstword $(MAKECMDGOALS))
xx		:= ""
FECHA_HOY := $(shell date +"hoy %A %d %B de %Y a las %H:%M")
RESULT  := ""

ifeq ($(UNAME), Darwin)
	OS_TYPE="MacOS"
endif

ifeq ($(UNAME), Linux)
	OS_TYPE="Linux"
endif



ifeq (memchk, $(CMDGOAL))
	xx:=$(shell if [ $(UNAME) == "Darwin" ]; then \
		echo -e "[ ${yellowdark}Buscando fugas de memoria en (${yellow}${APP}${NOC}${yellowdark}) - ${blue}MacOS${NOC} ]${girs}"; \
	elif [ $(UNAME) == "Linux" ]; then \
		echo -e "[ ${yellowdark}Buscando fugas de memoria en (${yellow}${APP}${NOC}${gris}) - ${greenDark}Linux${NOC} ]${girs}"; \
	fi)

else ifeq (clean, $(CMDGOAL))
	xx:=$(shell if [ $(UNAME) == "Darwin" ]; then \
		echo -e "[ ${yellowdark}Limpiando (${yellow}$(PROJECT_NAME)${yellowdark}) - ${blue}MacOS${NOC} ] ${gris}${FECHA_HOY}"; \
	elif [ $(UNAME) == "Linux" ]; then \
		echo -e "[ ${yellowdark}Limpiando (${yellow}$(PROJECT_NAME)${yellowdark}) - ${greenDark}Linux${NOC} ] ${gris}${FECHA_HOY}"; \
	fi)

else
	xx:=$(shell if [ $(UNAME) == "Darwin" ]; then \
		echo -e "[ ${yellowdark}Compilando (${yellow}$(PROJECT_NAME)${yellowdark}) - ${blue}MacOS${NOC} ] ${gris}${FECHA_HOY}"; \
	elif [ $(UNAME) == "Linux" ]; then \
		echo -e "[ ${gris}Compilando (${yellow}$(PROJECT_NAME)${yellowdark}) - ${greenDark}Linux${NOC} ] ${gris}${FECHA_HOY}"; \
	fi)
endif

$(info $(xx))

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
	echo -en "${NOC}"

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
	echo -en "${NOC}"

memchk:
	if [ -f ${APP} ]; then \
		leaks -atExit -- ${APP}; \
	else \
		echo -e "[${red}Error${NOC}]: ${gris}No existe ${APP}, \"ejecute make primero para crear el ejecutable..\"${NOC}"; \
	fi
	echo -en "${NOC}"

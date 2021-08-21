# rayimg makefile

STD=-std=c99
WFLAGS=-Wall
OPT=-O2
IDIR=-I. -Iinclude
LIBS=fract imgtool
CC=gcc
NAME=rayimg
SRC=*.c

CFLAGS=$(STD) $(WFLAGS) $(OPT) $(IDIR)
OS=$(shell uname -s)

LDIR=lib
LSTATIC=$(patsubst %,lib%.a,$(LIBS))
LPATHS=$(patsubst %,$(LDIR)/%,$(LSTATIC))
LFLAGS=$(patsubst %,-L%,$(LDIR))
LFLAGS += $(patsubst %,-l%,$(LIBS))
LFLAGS += -lz -lpng -ljpeg

ifeq ($(OS),Darwin)
	OSFLAGS=-mmacos-version-min=10.9
else 
	OSFLAGS=-lm
endif

$(NAME): $(LPATHS) $(SRC)
	$(CC) -o $@ $(SRC) $(CFLAGS) $(LFLAGS) $(OSFLAGS)

$(LPATHS): $(LDIR) $(LSTATIC)
	mv *.a $(LDIR)/

$(LDIR): 
	mkdir $@

$(LDIR)%.a: %
	cd $^ && make && mv $@ ../

clean:
	rm -r $(LDIR) && rm $(NAME) && rm imgtool/imgtool
	
install: $(NAME)
	sudo cp $^ /usr/local/bin/

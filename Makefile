# rayimg makefile

STD=-std=c99
WFLAGS=-Wall
OPT=-O2
LIBS=fract imgtool
CC=gcc
NAME=rayimg
SRC=*.c

OS=$(shell uname -s)

LDIR=lib
IDIR=$(patsubst %,-I%/,$(LIBS))
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

CFLAGS=$(STD) $(WFLAGS) $(OPT) $(IDIR)

$(NAME): $(LPATHS) $(SRC)
	$(CC) -o $@ $(SRC) $(CFLAGS) $(LFLAGS) $(OSFLAGS)

$(LPATHS): $(LDIR) $(LSTATIC)
	mv *.a $(LDIR)/

$(LDIR): 
	mkdir $@

$(LDIR)%.a: %
	cd $^ && make && mv $@ ../

clean:
	rm -r $(LDIR) && rm $(NAME)
	
exe: 
	$(CC) -o $(NAME) $(SRC) $(CFLAGS) $(LFLAGS) $(OSFLAGS)

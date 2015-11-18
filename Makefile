CC = gcc
CF = -c -Wall

all: sol
	sudo mv sol /usr/bin
	rm -Rf *.o

sol: sol.o
	$(CC) sol.o -o sol -llua -lm

sol.o: sol.c
	$(CC) $(CF) sol.c -o sol.o

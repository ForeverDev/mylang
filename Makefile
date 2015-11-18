CC = gcc
CF = -c -Wall

all: moon
	sudo mv moon /usr/bin
	rm -Rf *.o

moon: moon.o
	$(CC) moon.o -o moon -llua -lm

moon.o: moon.c
	$(CC) $(CF) moon.c -o moon.o

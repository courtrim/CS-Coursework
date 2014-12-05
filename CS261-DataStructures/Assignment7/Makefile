default all: prog 

cirListDeque.o: cirListDeque.h cirListDeque.c
	gcc -g -Wall -ansi -c cirListDeque.c

graph.o: graph.h graph.c cirListDeque.o
	gcc -g -Wall -ansi -c graph.c

prog: graph.o cirListDeque.o main.c
	gcc -g -Wall -ansi -o prog graph.o cirListDeque.o main.c

clean:
	rm cirListDeque.o
	rm graph.o

cleanall: clean
	rm prog 
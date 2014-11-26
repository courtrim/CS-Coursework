default all: prog 

hashMap.o: hashMap.c hashMap.h 
	gcc -g -Wall -std=c99 -pedantic-errors -c hashMap.c

prog: hashMap.o main.c
	gcc -g -Wall -std=c99 -pedantic-errors -o prog hashMap.o  main.c

spellcheck: hashMap.o spellcheck.c
	gcc -g -Wall -std=c99 -pedantic-errors -o spell hashMap.o  spellcheck.c
	
clean:
	rm hashMap.o	

cleanall: clean
	rm prog

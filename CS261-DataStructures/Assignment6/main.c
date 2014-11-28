#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "hashMap.h"

/*
 the getWord function takes a FILE pointer and returns you a string which was
 the next word in the in the file. words are defined (by this function) to be
 characters or numbers separated by periods, spaces, or newlines.
 
 when there are no more words in the input file this function will return NULL.
 
 this function will malloc some memory for the char* it returns. it is your job
 to free this memory when you no longer need it.
 */
char* getWord(FILE *file);
void testHash();
void testHashContains();
void testHashInsert_WithPreExistingKey();
void testHashInsert_IncrementsCount();
void testHashInsert_ResizeHashTable();

/*FIXME
 * Changed value type for atMap(). mention at turn in
 * */

int main (int argc, const char * argv[]) {
	const char* filename;
	struct hashMap *hashTable;	
	int tableSize = 10;
	clock_t timer;
	FILE *fileptr;

    /*
     this part is using command line arguments, you can use them if you wish
     but it is not required. DO NOT remove this code though, we will use it for
     testing your program.
     
     if you wish not to use command line arguments manually type in your
     filename and path in the else case.
     */
    if(argc == 2)
        filename = argv[1];
    else
        filename = "input1.txt"; /*specify your input text file here*/
    
    printf("opening file: %s\n", filename);
    
	timer = clock();
	
	hashTable = createMap(tableSize);	   
	
    /*... concordance code goes here ...*/
	testHash();

	char *curWord;
	fileptr = fopen(filename, "r");
	assert(fileptr != 0);

	// steps:
	// 1. read in a word with getword()
	curWord = getWord(fileptr);
	// Test add first word
	insertMap(hashTable, curWord, 1);
	// Test contains first word
	while(curWord != 0)
	{

		// 2. if the word is already in your hash table then increment it's number
		//    of occurrences


		curWord = getWord(fileptr);
	}
	fclose(fileptr);
	// 3. If the word is not in your hash table then insert it with an occurrence
	//    count of 1
//		insertMap(hashTable, curWord, 1);
	/*... concordance code ends here ...*/

	printMap(hashTable);
	timer = clock() - timer;
	printf("\nconcordance ran in %f seconds\n", (float)timer / (float)CLOCKS_PER_SEC);
	printf("Table emptyBuckets = %d\n", emptyBuckets(hashTable));
    printf("Table count = %d\n", size(hashTable));
	printf("Table capacity = %d\n", capacity(hashTable));
	printf("Table load = %f\n", tableLoad(hashTable));
	
	printf("Deleting keys\n");
	
	removeKey(hashTable, "and");
	removeKey(hashTable, "me");
	removeKey(hashTable, "the");
	printMap(hashTable);
		
	deleteMap(hashTable);
	printf("\nDeleted the table\n");   
	return 0;
}

void printValue(ValueType v) {
	printf("Value:%d",(int *)v);
}

char* getWord(FILE *file)
{
	int length = 0;
	int maxLength = 16;
	char character;
    
	char* word = malloc(sizeof(char) * maxLength);
	assert(word != NULL);
    
	while( (character = fgetc(file)) != EOF)
	{
		if((length+1) > maxLength)
		{
			maxLength *= 2;
			word = (char*)realloc(word, maxLength);
		}
		if((character >= '0' && character <= '9') || /*is a number*/
		   (character >= 'A' && character <= 'Z') || /*or an uppercase letter*/
		   (character >= 'a' && character <= 'z') || /*or a lowercase letter*/
		   character == 39) /*or is an apostrophe*/
		{
			word[length] = character;
			length++;
		}
		else if(length > 0)
			break;
	}
    
	if(length == 0)
	{
		free(word);
		return NULL;
	}
	word[length] = '\0';
	return word;
}

void testHash()
{
	printf("Running test hash...\n");
	struct hashMap *hashTable;
	int tableSize = 10;

	hashTable = createMap(tableSize);

	char *firstWord = "hello";
	char *secondWord = "hello";

	insertMap(hashTable, firstWord, 1);
	insertMap(hashTable, secondWord, 1);

	// Run Tests
	testHashContains();
	testHashInsert_WithPreExistingKey();
	testHashInsert_IncrementsCount();
	testHashInsert_ResizeHashTable();
	printf("Ending test hash...\n");
}

void testHashContains()
{
	printf("\n");
	struct hashMap *hashTable;
	int tableSize = 10;

	hashTable = createMap(tableSize);

	char *firstWord = "hello";
	char *secondWord = "bye";
	char *thirdWord = "good";

	insertMap(hashTable, firstWord, 1);
	insertMap(hashTable, secondWord, 1);

	// Test if the first word is in the hash table
	if (containsKey(hashTable, firstWord))
	{
		printf("First contains() passed...\n");
	}
	else
	{
		printf("First contains() failed...\n");
	}

	// Test if the second word is in the hash table
	if (containsKey(hashTable, secondWord))
	{
		printf("Second contains() passed...\n");
	}
	else
	{
		printf("Second contains() failed...\n");
	}

	// Test if the third word is not in the hash table
	if (!containsKey(hashTable, thirdWord))
	{
		printf("not contains() passed...\n");
	}
}

void testHashInsert_WithPreExistingKey()
{
	printf("\n");
	struct hashMap *hashTable;
	int tableSize = 10;

	hashTable = createMap(tableSize);

	char *firstWord = "hello";
	char *secondWord = "bye";

	insertMap(hashTable, firstWord, 1);
	insertMap(hashTable, firstWord, 10);
	insertMap(hashTable, secondWord, 1);
	insertMap(hashTable, secondWord, 20);

	if (atMap(hashTable, firstWord) == 10)
	{
		printf("Hash table insert() - Replaced value1 at pre-existing key passed \n");
	}

	if (atMap(hashTable, secondWord) == 20)
	{
		printf("Hash table insert() - Replaced value2 at pre-existing key passed \n");
	}
}

void testHashInsert_IncrementsCount()
{
	printf("\n");
	struct hashMap *hashTable;
	int tableSize = 10;

	hashTable = createMap(tableSize);

	char *firstWord = "hello";
	char *secondWord = "bye";

	insertMap(hashTable, firstWord, 1);

	if (size(hashTable) == 1)
	{
		printf("Hash table insert() - Count test for key1 passed\n");
	}

	insertMap(hashTable, secondWord, 1);

	if (size(hashTable) == 2)
	{
		printf("Hash table insert() - Count test for key1 passed\n");
	}
}

void testHashInsert_ResizeHashTable()
{
	printf("\n");
	struct hashMap *hashTable;
	int tableSize = 10;

	hashTable = createMap(tableSize);

	char *firstWord = "hello";
	char *secondWord = "bye";
	char *thirdWord = "saw";
	char *fourthWord = "the";
	char *fifthWord = "valley";
	char *sixthWord = "sun";
	char *seventhWord = "bun";
	char *eightWord = "fun";
	char *ninthWord = "run";

	insertMap(hashTable, firstWord, 1);
	insertMap(hashTable, secondWord, 1);
	insertMap(hashTable, thirdWord, 1);
	insertMap(hashTable, fourthWord, 1);
	insertMap(hashTable, fifthWord, 1);
	insertMap(hashTable, sixthWord, 1);
	insertMap(hashTable, seventhWord, 1);
	insertMap(hashTable, eightWord, 1);
	insertMap(hashTable, ninthWord, 1);

	if (capacity(hashTable) == 23)
	{
		printf("Hash table insert() - resizing to size 23 passed\n");
	}
	else
	{
		printf("Hash table insert() - resizing FAILED!!!\n");
	}

	printMap(hashTable);
}

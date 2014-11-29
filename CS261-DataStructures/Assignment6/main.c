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
void testHashEmptyBuckets();
void testHashTableLoad();
void testHashRemove_FromSingleLinkBuckets();
void testHashRemove_FromMultiLinkBuckets();

/*FIXME
 * Changed value type for atMap(). mention at turn in
 * */

int main (int argc, const char * argv[]) {
	setvbuf(stdout, NULL, _IONBF, BUFSIZ);
	const char* filename;
	struct hashMap *hashTable;
	int tableSize = 10;
	clock_t timer;
	FILE *fileptr;

	//KEVIN test code
//	testHash();

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
        filename = "input3.txt"; /*specify your input text file here*/

    printf("opening file: %s\n", filename);

	timer = clock();

	hashTable = createMap(tableSize);

    /*... concordance code goes here ...*/
	char *curWord;
	fileptr = fopen(filename, "r");
	assert(fileptr != 0);

	curWord = getWord(fileptr);
	int existingValueToIncrement;

	while(curWord != 0)
	{

		if (!containsKey(hashTable, curWord))
		{
			insertMap(hashTable, curWord, 1);
		}
		else
		{
			existingValueToIncrement = (int)atMap(hashTable, curWord);
			existingValueToIncrement++;
			insertMap(hashTable, curWord, existingValueToIncrement);
		}

		curWord = getWord(fileptr);
	}
	fclose(fileptr);
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
	printf("Value:%d",(ValueType)v);
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
	testHashEmptyBuckets();
	testHashTableLoad();
	testHashRemove_FromSingleLinkBuckets();
	testHashRemove_FromMultiLinkBuckets();
	printf("\nEnding test hash...\n");
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

	deleteMap(hashTable);
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

	deleteMap(hashTable);
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

	deleteMap(hashTable);
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

	// Test new resized hash table for correct contents
	if (containsKey(hashTable, firstWord))
	{
		printf("Hash table insert() resizing - First contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - First contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, secondWord))
	{
		printf("Hash table insert() resizing - Second contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - Second contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, thirdWord))
	{
		printf("Hash table insert() resizing - third contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - third contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, thirdWord))
	{
		printf("Hash table insert() resizing - third contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - third contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, fourthWord))
	{
		printf("Hash table insert() resizing - fourth contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - fourth contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, fifthWord))
	{
		printf("Hash table insert() resizing - fifth contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - fifth contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, sixthWord))
	{
		printf("Hash table insert() resizing - sixth contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - sixth contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, seventhWord))
	{
		printf("Hash table insert() resizing - seventh contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - seventh contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, eightWord))
	{
		printf("Hash table insert() resizing - eight contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - eight contains() test FAILED!!!\n");
	}

	if (containsKey(hashTable, ninthWord))
	{
		printf("Hash table insert() resizing - ninth contains() test passed\n");
	}
	else
	{
		printf("Hash table insert() resizing - ninth contains() test FAILED!!!\n");
	}

	deleteMap(hashTable);
}

void testHashEmptyBuckets()
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

	if (emptyBuckets(hashTable) == 7)
	{
		printf("EmptyBuckets() test after 3 inserts passed \n");
	}
	else
	{
		printf("EmptyBuckets() test after 3 inserts FAILED!!! \n");
	}

	insertMap(hashTable, fourthWord, 1);
	insertMap(hashTable, fifthWord, 1);
	insertMap(hashTable, sixthWord, 1);

	if (emptyBuckets(hashTable) == 6)
	{
		printf("EmptyBuckets() test after 6 inserts passed \n");
	}
	else
	{
		printf("EmptyBuckets() test after 6 inserts FAILED!!! \n");
	}

	insertMap(hashTable, seventhWord, 1);
	insertMap(hashTable, eightWord, 1);
	insertMap(hashTable, ninthWord, 1);

	if (emptyBuckets(hashTable) == 17)
	{
		printf("EmptyBuckets() test after 9 inserts passed \n");
	}
	else
	{
		printf("EmptyBuckets() test after 9 inserts FAILED!!! \n");
	}

	deleteMap(hashTable);
}

void testHashTableLoad()
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
	printf("Table load after add 1: %f \n", tableLoad(hashTable));
	insertMap(hashTable, secondWord, 1);
	printf("Table load after add 2: %f \n", tableLoad(hashTable));
	insertMap(hashTable, thirdWord, 1);
	printf("Table load after add 3: %f \n", tableLoad(hashTable));
	insertMap(hashTable, fourthWord, 1);
	printf("Table load after add 4: %f \n", tableLoad(hashTable));
	insertMap(hashTable, fifthWord, 1);
	printf("Table load after add 5: %f \n", tableLoad(hashTable));
	insertMap(hashTable, sixthWord, 1);
	printf("Table load after add 6: %f \n", tableLoad(hashTable));
	insertMap(hashTable, seventhWord, 1);
	printf("Table load after add 7: %f \n", tableLoad(hashTable));
	insertMap(hashTable, eightWord, 1);
	printf("Table load after add 8: %f \n", tableLoad(hashTable));
	insertMap(hashTable, ninthWord, 1);
	printf("Table load after add 9(after table resize): %f \n", tableLoad(hashTable));

	deleteMap(hashTable);
}

void testHashRemove_FromSingleLinkBuckets()
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

	// Try removing a non-existent key
	removeKey(hashTable, thirdWord);
	if (size(hashTable) == 2)
	{
		printf("Hash table removeKey() - with nonexistent key passed \n");
	}

	// Remove 1 hash link
	removeKey(hashTable, firstWord);
	if ((size(hashTable) == 1) && (!containsKey(hashTable, firstWord)))
	{
		printf("Hash table removeKey() - remove 1 key passed \n");
	}
	else
	{
		printf("Hash table removeKey() - remove 1 key FAILED \n");
	}

	// Remove 1 hash link
	removeKey(hashTable, secondWord);
	if ((size(hashTable) == 0) && (!containsKey(hashTable, secondWord)))
	{
		printf("Hash table removeKey() - remove 2 key passed \n");
	}
	else
	{
		printf("Hash table removeKey() - remove 2 key FAILED \n");
	}

	deleteMap(hashTable);
}

void testHashRemove_FromMultiLinkBuckets()
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

	insertMap(hashTable, firstWord, 1);
	insertMap(hashTable, secondWord, 1);
	insertMap(hashTable, thirdWord, 1);
	insertMap(hashTable, fourthWord, 1);
	insertMap(hashTable, fifthWord, 1);
	insertMap(hashTable, sixthWord, 1);
	insertMap(hashTable, seventhWord, 1);
	insertMap(hashTable, eightWord, 1);

	// Removing from a bucket with multiple hash links
	removeKey(hashTable, fifthWord);

	if (size(hashTable) == 7)
	{
		printf("Hash table removeKey() - with multiple items in 1 bucket - size check passed \n");
	}
	else
	{
		printf("Hash table removeKey() - with multiple items in 1 bucket - size check FAILED!!!	 \n");
	}

	if (!containsKey(hashTable, fifthWord))
	{
		printf("Hash table removeKey() - with multiple items in 1 bucket - contains check passed \n");
	}
	else
	{
		printf("Hash table removeKey() - with multiple items in 1 bucket - contains check FAILED!!!	 \n");
	}

	deleteMap(hashTable);
}

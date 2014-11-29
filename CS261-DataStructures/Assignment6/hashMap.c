#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "hashMap.h"

/*the first hashing function you can use*/
int stringHash1(char * str)
{
	int i;
	int r = 0;
	for (i = 0; str[i] != '\0'; i++)
		r += str[i];
	return r;
}

/*the second hashing function you can use*/
int stringHash2(char * str)
{
	int i;
	int r = 0;
	for (i = 0; str[i] != '\0'; i++)
		r += (i+1) * str[i]; /*the difference between stringHash1 and stringHash2 is on this line*/
	return r;
}

/* initialize the supplied hashMap struct*/
void _initMap (struct hashMap * ht, int tableSize)
{
	int index;
	if(ht == NULL)
	{
		return;
	}

	ht->table = (hashLink**)malloc(sizeof(hashLink*) * tableSize);
	ht->tableSize = tableSize;
	ht->count = 0;
	for(index = 0; index < tableSize; index++)
	{
		ht->table[index] = NULL;
	}
}

/*
Purpose: Gets the hash number from the hash function.
		 This function determines which hash function
		 to use depending on the definition of HASHING_FUNCTION
		 located in the hashMap.h file
Preconditions: n/a
Parameters: str - a null terminated string to hashify
Returns: a hash number
*/
int _getIndexFromHashFunc(char *str)
{
	if (HASHING_FUNCTION == 1)
	{
		// Use the first hashing function
		return stringHash1(str);
	}
	else
	{
		// Use the second hashing function
		return stringHash2(str);
	}
}

/*
Purpose: Gets the next prime number hash size
Preconditions: hash is not null.
			   hash size is greater than 0
Parameters: ht - pointer to the hash map
Returns: A prime number that is the next size the hash map
		 should resize to.
*/
int _getNextHashSize(struct hashMap *ht)
{
	// Check Preconditions
	assert(ht != 0);

	int currentSize = ht->tableSize;
	assert(currentSize > 0); // Make sure hash table size is greater than 0

	// Double current size and check to see if number is prime.
	int sizeToTest = currentSize * 2;
	int numIsPrime = 0; // 0, means false
	int checkNextNum = 0; // 0, means false
	int i;

	while (!numIsPrime)
	{
		// Check every integer less than the proposed number to
		// 	see if its prime
		for (i = 2; i < sizeToTest; i++)
		{
			if (sizeToTest % i == 0)
			{
				checkNextNum = 1;
				break;
			}
			else
			{
				checkNextNum = 0;
			}
		}

		if (checkNextNum)
		{
			// Did not find prime, increment and try again
			sizeToTest++;
		}
		else
		{
			// Found the prime exit the loop
			numIsPrime = 1;
			break;
		}
	}

	return sizeToTest;
}

/* allocate memory and initialize a hash map*/
hashMap *createMap(int tableSize) {
	assert(tableSize > 0);
	hashMap *ht;
	ht = malloc(sizeof(hashMap));
	assert(ht != 0);
	_initMap(ht, tableSize);
	return ht;
}

/*
	Implementation Notes:
		Note: Before freeing up a hashLink, free the memory occupied by key and value

Purpose: Free all memory used by the buckets.
Preconditions: 1. hash table is not null
Parameters: ht - pointer to a hash map
Returns: n/a
*/
void _freeMap (struct hashMap * ht)
{
	// Check Preconditions
	assert(ht != 0);

	hashLink *currPtr;
	int i;
	for(i = 0; i < ht->tableSize; i++)
	{
		currPtr = ht->table[i];
		while(currPtr != 0)
		{
			hashLink *tempLink = currPtr;
			currPtr = currPtr->next;
			free(tempLink);

			ht->count--;
		}
	}

	free(ht->table);
	ht->table = 0;
}

/* Deallocate buckets and the hash map.*/
void deleteMap(hashMap *ht) {
	assert(ht!= 0);
	/* Free all memory used by the buckets */
	_freeMap(ht);
	/* free the hashMap struct */
	free(ht);
}

/*
Resizes the hash table to be the size newTableSize
Preconditions: 1. hash table is not null
			   2. new table size is greater than 0
Parameters: ht - pointer to a hash map
			newTableSize - integer for size to resize hash map to
Returns: n/a
*/
void _setTableSize(struct hashMap * ht, int newTableSize)
{
	// Check Preconditions
	assert(ht != 0);
	assert(newTableSize > 0);

	// Save old data
	hashLink **oldMap = ht->table;
	int oldSize = ht->tableSize;

	// Allocate new table
	ht->table = (hashLink**)malloc(newTableSize * sizeof(hashLink*));
	assert(ht->table != 0);

	ht->tableSize = newTableSize;
	ht->count = 0;

	// Set all hash elements in new table to null
	int index;
	for(index = 0; index < ht->tableSize; index++)
	{
		ht->table[index] = 0;
	}

	// Copy over old elements into new array
	hashLink *currPtr;

	int i;
	for (i = 0; i < oldSize; i++)
	{
		if (oldMap[i] != 0)
		{
			currPtr = oldMap[i];
			while(currPtr != 0)
			{
				insertMap(ht, currPtr->key, currPtr->value);

				// Free the old hash link and move onto next hash link to copy
				hashLink *tempLink = currPtr;
				currPtr = currPtr->next;
				free(tempLink);
			}
		}
	}
	free(oldMap);
}

/*
 Implementation Notes:
 insert the following values into a hashLink, you must create this hashLink but
 only after you confirm that this key does not already exist in the table. For example, you
 cannot have two hashLinks for the word "taco".

 if a hashLink already exists in the table for the key provided, replace the value of that
 hashLink with the new value and exit the function.

 also, you must monitor the load factor and resize when the load factor is greater than
 or equal LOAD_FACTOR_THRESHOLD (defined in hashMap.h).

Purpose: Inserts a key and value into a hash map
Preconditions: 1. hash table is not null
Parameters: ht - pointer to a hash map
			k - the key to add
			v - the value to add
Returns: n/a
*/
void insertMap (struct hashMap * ht, KeyType k, ValueType v)
{
	// Check Preconditions
	assert(ht != 0);

	if ((ht->count / (double)ht->tableSize) > LOAD_FACTOR_THRESHOLD)
	{
		int nextSize = _getNextHashSize(ht);
		_setTableSize(ht, nextSize);
	}

	// Get hash index based on the key
	int index = _getIndexFromHashFunc(k) % ht->tableSize;
	if (index < 0)
	{
		index += ht->tableSize;
	}

	// Check if hash link exists, if it does then replace the link
	if (containsKey(ht, k) == 1)
	{
		struct hashLink *curPtr = ht->table[index];
		while(curPtr != 0)
		{
			if (strcmp(curPtr->key, k) == 0)
			{
				// Found the key, set the value for the current hash link
				curPtr->value = v;
				return;
			}

			curPtr = curPtr->next;
		}
	}

	// If hash link does not exist, create a new link and
	//	add it to the hash table at index
	struct hashLink *newLink = malloc(sizeof(struct hashLink));
	newLink->key = k;
	newLink->value = v;
	newLink->next = ht->table[index];
	ht->table[index] = newLink;
	ht->count++;
}

/*
 Implementation Note:
 I changed the return type from (ValueType*) to (ValueType) because the value
 type in hashLink is an int and not int*.

 if the supplied key is not in the hashtable return NULL.
 */
/*
Purpose: Gets the value from the hash table at the specified key
Preconditions: Hash map is not null
Parameters: ht - pointer to a hash map
			k - the key to search for
Returns: The value stored at the key.
		 Returns 0 if value is not found.
*/
ValueType atMap (struct hashMap * ht, KeyType k)
{
	// Check Preconditions
	assert(ht != 0);

	// Get hash index based on the key
	int index = _getIndexFromHashFunc(k) % ht->tableSize;
	if (index < 0)
	{
		index += ht->tableSize;
	}

	// Find the key in the hash table
	struct hashLink *curPtr = ht->table[index];
	while(curPtr != 0)
	{
		if (strcmp(curPtr->key, k) == 0)
		{
			// Return the value at the key
			return curPtr->value;
		}

		curPtr = curPtr->next;
	}
	return 0;
}

/*
Purpose: Checks if a key is in a hash table
Preconditions: Hash map is not null
Parameters: ht - pointer to a hash map
			k - the key to search for
Returns: Returns 1, if key is in hash table
		 Returns 0, if key is not in hash table
*/
int containsKey (struct hashMap * ht, KeyType k)
{
	// Check Preconditions
	assert(ht != 0);

	// Get hash index based on the key
	int index = _getIndexFromHashFunc(k) % ht->tableSize;
	if (index < 0)
	{
		index += ht->tableSize;
	}

	struct hashLink *curPtr = ht->table[index];
	while(curPtr != 0)
	{
		if (strcmp(curPtr->key, k) == 0)
		{
			return 1;
		}

		curPtr = curPtr->next;
	}

	return 0;
}

/*
 Implementation Notes:
 find the hashlink for the supplied key and remove it, also freeing the memory
 for that hashlink. it is not an error to be unable to find the hashlink, if it
 cannot be found do nothing (or print a message) but do not use an assert which
 will end your program.
 */
/*
Purpose: Removes the link that has a specific key
Preconditions: Hash map is not null
Parameters: ht - pointer to a hash map
			k - the key to search for
Returns: n/a
*/
void removeKey (struct hashMap * ht, KeyType k)
{
	// Check Preconditions
	assert(ht != 0);

	// Check if key exists in hash table
	if (!containsKey(ht, k))
	{
		printf("Warning: key: %s, was not found for removal \n", k);
		return;
	}

	// Get hash index based on the key
	int index = _getIndexFromHashFunc(k) % ht->tableSize;
	if (index < 0)
	{
		index += ht->tableSize;
	}

	hashLink *currPtr = ht->table[index];
	if (currPtr == 0)
	{
		// This hash bucket is empty, return
		return;
	}
	else if (currPtr->next == 0)
	{
		// This hash bucket only has 1 hash link, so empty the bucket
		if (strcmp(currPtr->key, k) == 0)
		{
			free(ht->table[index]);
			ht->table[index] = 0;

			currPtr = 0;
			ht->count--;
			return;
		}
	}

	// There is multiple hash links in the bucket, need to remove the
	//  link and re-link all the other links correctly
	while(currPtr->next != 0)
	{
		if (strcmp(currPtr->next->key, k) == 0)
		{
			hashLink *tempLink = currPtr->next;
			currPtr->next = currPtr->next->next;
			free(tempLink);
			tempLink = 0;

			ht->count--;
			return;
		}

		currPtr = currPtr->next;
	}
}

/*
Purpose: Gets the number of hashLinks in the table
Preconditions: Hash map is not null
Parameters: ht - pointer to a hash map
Returns: The number of hashLinks in the table
*/
int size (struct hashMap *ht)
{
	// Check Preconditions
	assert(ht != 0);

	return ht->count;
}

/*
Purpose: Gets the number of buckets in the table
Preconditions: Hash map is not null
Parameters: ht - pointer to a hash map
Returns: The number of buckets in the table
*/
int capacity(struct hashMap *ht)
{
	// Check Preconditions
	assert(ht != 0);

	return ht->tableSize;
}

/*
Purpose: Gets the number of empty buckets in the table
Preconditions: Hash map is not null
Parameters: ht - pointer to a hash map
Returns: The number of empty buckets in hash table
*/
int emptyBuckets(struct hashMap *ht)
{
	// Check Preconditions
	assert(ht != 0);

	int numEmptyBuckets = 0;
	int i;

	// Determine how many empty buckets there are in the hash table
	for (i = 0; i < ht->tableSize; i++)
	{
		if (ht->table[i] == 0)
		{
			numEmptyBuckets++;
		}
	}

	return numEmptyBuckets;
}

/*
 Implementation Notes:
 returns the ratio of: (number of hashlinks) / (number of buckets)

 this value can range anywhere from zero (an empty table) to more then 1, which
 would mean that there are more hashlinks then buckets (but remember hashlinks
 are like linked list nodes so they can hang from each other)
 */
/*
Purpose: Gets the ratio of: (number of hashlinks) / (number of buckets)
Preconditions: Hash map is not null
Parameters: ht - pointer to a hash map
Returns: returns the ratio of: (number of hashlinks) / (number of buckets)
*/
float tableLoad(struct hashMap *ht)
{
	// Check Preconditions
	assert(ht != 0);

	// Check that number of buckets is greater than 0, to prevent a
	// 	divide by zero error
	int numOfBuckets = capacity(ht);
	assert(numOfBuckets > 0);

	return (size(ht) / (float)numOfBuckets);
}

void printMap (struct hashMap * ht)
{
	int i;
	struct hashLink *temp;
	for(i = 0;i < capacity(ht); i++)
	{
		temp = ht->table[i];
		if(temp != 0) {
			printf("\nBucket Index %d -> ", i);
		}
		while(temp != 0){
			printf("Key:%s|", temp->key);
			printValue(temp->value);
			printf(" -> ");
			temp=temp->next;
		}
	}

	printf("\n");
}



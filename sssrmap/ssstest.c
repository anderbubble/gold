#include <stdio.h>
#include "sssrmap.h"

int main(int argc, char **argv) {

	SSSRMAPSession *sess;
	SSSRMAPRequest *query;
	SSSRMAPResponse *response;
	SSSRMAPItem *item;
	char *titles[10];
	int i=0, numFields;
	char *queries[2] = {"Object", "User"};
	int numQueries = 2, queryIndex;

	sess = SSSRMAP_allocSession();

	SSSRMAP_connectHost(sess,"127.0.0.1",7112);
	SSSRMAP_setKey(sess,"asdf jkl;");
	for(queryIndex = 0; queryIndex < numQueries; queryIndex++) {
		query = SSSRMAP_allocQuery();
		SSSRMAP_setObject(query,queries[queryIndex]);
		SSSRMAP_setActor(query,"kschmidt");
		//SSSRMAP_addFilter(query,"Name","kschmidt");

		SSSRMAP_sendMessage(sess,query);
		response = SSSRMAP_getResponse(sess);
		if ( response == 0 ) {
			printf("error getting results\n");
			exit(1);
		}

		item = SSSRMAP_fetchItem(response);
		if ( item == 0 ) {
			printf("No Items\n");
			exit(0);
		}
		printf("%s\n",queries[queryIndex]);
		numFields = SSSRMAP_getFieldNames(item,titles,10);
		for(i=0;i < numFields;i++)
			printf("%18s\t",titles[i]);
		printf("\n");
		do {
			for(i=0;i < numFields;i++)
				printf("%18s\t",SSSRMAP_getField(item, titles[i]));
			printf("\n");
		} while(item = SSSRMAP_fetchItem(response));
		SSSRMAP_freeResponse(response);
		SSSRMAP_freeQuery(query);
	}
	SSSRMAP_freeSession(sess);
	return (0);
}

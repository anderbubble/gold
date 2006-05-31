#ifndef SSSRMAP_H
#define SSSRMAP_H

#include <libxml/xmlmemory.h>

#define SSSRMAPNS NULL

struct NVNode {char *name; char *value; struct NVNode  *next;};

struct SSSRMAPRequest_t;

typedef struct SSSRMAPRequest_t {
	xmlChar *actor;
	xmlChar *id;
	xmlNodePtr request;
	xmlChar *object;
	xmlNodePtr (*getRequest)(struct SSSRMAPRequest_t *);
	void *childStruct;
} SSSRMAPRequest;

void SSSRMAP_setActor(SSSRMAPRequest *this, char *actor);
void SSSRMAP_setObject(SSSRMAPRequest *this, char *object);

struct SSSRMAPQuery {
	struct NVNode  *head;
};
SSSRMAPRequest *SSSRMAP_allocQuery();
void SSSRMAP_freeQuery(SSSRMAPRequest *this);
void SSSRMAP_addFilter(SSSRMAPRequest *this, char *name, char *value);
xmlNodePtr SSSRMAP_Query_getRequest(SSSRMAPRequest *this);

struct SSSRMAPItem_t;

typedef struct SSSRMAPItem_t {
	struct NVNode *head;
	struct NVNode *curField;
	struct SSSRMAPItem_t *next;
} SSSRMAPItem;
char *SSSRMAP_getField(SSSRMAPItem *this,char *name);
int SSSRMAP_getFieldNames(SSSRMAPItem *this,char **names,int size);
char *SSSRMAP_getNextFieldName(SSSRMAPItem *this);

typedef struct SSSRMAPResponse_t {
	char *statusValue;
	char *statusCode;
	int count;
	SSSRMAPItem *head;
	SSSRMAPItem *cur;
} SSSRMAPResponse;
SSSRMAPItem *SSSRMAP_fetchItem(SSSRMAPResponse *this);
void SSSRMAP_freeResponse(SSSRMAPResponse *this);

typedef struct SSSRMAPSession_t {
	int filedes;
	int printPretty;
	char *hostname;
	char *key;
	xmlDocPtr doc;
	xmlNodePtr envelope;
} SSSRMAPSession;
SSSRMAPSession *SSSRMAP_allocSession();
void SSSRMAP_freeSession(SSSRMAPSession *this);
int SSSRMAP_connectFiledes(SSSRMAPSession *this, int filedes);
int SSSRMAP_connectHost(SSSRMAPSession *this, char *host, int port);
int SSSRMAP_initiate(SSSRMAPSession *this);
void SSSRMAP_setKey(SSSRMAPSession *this,char *key);
int SSSRMAP_sendMessage(SSSRMAPSession *this, SSSRMAPRequest *req);
void SSSRMAP_setPrintPretty(SSSRMAPSession *this, int pretty);
SSSRMAPResponse *SSSRMAP_getResponse(SSSRMAPSession *this);

#endif

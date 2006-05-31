#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <resolv.h>
#include <libxml/xmlmemory.h>
#include <string.h>
#include <openssl/bio.h>
#include <openssl/sha.h>
#include <openssl/hmac.h>

#include "sssrmap.h"

#define SSSRMAPNS NULL

static int base64(char *unenc, int isize, char *enc, int osize) {
        BIO *b64, *out;
        int count;
        char *outbuf;

        b64 = BIO_new(BIO_f_base64());
        out = BIO_new(BIO_s_mem());
        b64 = BIO_push(b64, out);

        BIO_write(b64, unenc, isize);
        BIO_flush(b64);
        count = BIO_get_mem_data(out, &outbuf);

	if (count > osize)
		count = osize;
        memmove(enc, outbuf, count);

        enc[count-1] = '\0';

        BIO_free_all(b64);

        return count-1;
}

void ERROR(const char *error)
{
	fprintf(stderr,error);
}

int SSSRMAP_connectFiledes(SSSRMAPSession *this, int filedes)
{
	this->filedes = filedes;
	this->hostname = "file-descriptor";
	return 0;
}

int SSSRMAP_connectHost(SSSRMAPSession *this, char *host, int port)
{
	struct sockaddr_in addr;
	struct hostent *gServer;

	this->hostname = strdup(host);

	if((gServer = gethostbyname(host)) == NULL) {
		herror("connecting to server");
		return -1;
	}

	if(gServer->h_addr_list[0] != NULL) {
		memset(&(addr), 0, sizeof(addr));
		addr.sin_family = AF_INET;
		addr.sin_port = htons(port);
		memcpy(&addr.sin_addr.s_addr,gServer->h_addr_list[0],sizeof(gServer->h_addr_list[0]));
		this->filedes = socket(PF_INET,SOCK_STREAM,0);
		connect(this->filedes,(struct sockaddr *)&addr,sizeof(addr));

		return 0;
	} else {
		fprintf(stderr,"connecting to server: no addresses for host\n");
		return -1;
	}
}

int SSSRMAP_initiate(SSSRMAPSession *this)
{
	char header[1024];
	/*char hostname[256];*/
	int numWritten;
	int result;

	/*gethostname(hostname, sizeof(hostname));*/
	numWritten = snprintf(header, sizeof(header), "POST /SSSRMAP3 HTTP/1.1\r\nContent-Type: text/xml; charset=\"utf-8\"\r\nTransfer-Encoding: chunked\r\n\r\n");
	if (numWritten == -1) {
		ERROR("error building session header\n");
		return -1;
	}
	result = write(this->filedes, header, numWritten);
	if (-1 == result) {
		ERROR("error initiating session\n");
		return -1;
	}
	return 0;
}

void SSSRMAP_setPrintPretty(SSSRMAPSession *this, int pretty)
{
	this->printPretty = pretty;
}

void SSSRMAP_setKey(SSSRMAPSession *this,char *key)
{
	this->key = strdup(key);
}

int SSSRMAP_sendMessage(SSSRMAPSession *this, SSSRMAPRequest *req)
{
	xmlChar *buf;
	xmlNodePtr body;
	xmlNodePtr sig;
	xmlNodePtr cur;
	xmlNodePtr request;
	xmlBufferPtr bodybuf;
	const xmlChar *bodyBufContent;
	int bodybuflen;
	int bufsize;
	char outbuf[256];
	int outsize;

        unsigned char encoded[20];
        unsigned char digbuf[256];
        char sigbuf[256];
        char md[EVP_MAX_MD_SIZE];
        unsigned int md_len;
        SHA_CTX ctx;

	body = xmlNewNode(SSSRMAPNS,(xmlChar *)"Body");
	xmlAddChild(this->envelope,body);
	request = req->getRequest(req);
	xmlAddChild(body,request);
	
	/*Calculate signatures of the message body*/
	bodybuf = xmlBufferCreate();
	bodybuflen = xmlNodeDump(bodybuf,this->doc,body,1,this->printPretty);
	bodyBufContent = xmlBufferContent(bodybuf);
        SHA1_Init(&ctx);
        SHA1_Update(&ctx,bodyBufContent,bodybuflen);
        SHA1_Final(encoded,&ctx);
        base64((char *)encoded,sizeof(encoded),(char *)digbuf,sizeof(digbuf));

        HMAC(EVP_sha1(),(const unsigned char *)this->key,strlen(this->key),encoded,sizeof(encoded),(unsigned char *)md,&md_len);
        base64(md,md_len,sigbuf,sizeof(sigbuf));

	/*add the signature to the request*/
	sig = xmlNewNode(SSSRMAPNS,(xmlChar *)"Signature");

	cur = xmlNewNode(SSSRMAPNS,(xmlChar *)"DigestValue");
	xmlNodeSetContent(cur,(xmlChar *)digbuf);
	xmlAddChild(sig,cur);

	cur = xmlNewNode(SSSRMAPNS,(xmlChar *)"SignatureValue");
	xmlNodeSetContent(cur,(xmlChar *)sigbuf);
	xmlAddChild(sig,cur);

	cur = xmlNewNode(SSSRMAPNS,(xmlChar *)"SecurityToken");
        xmlSetProp(cur,(xmlChar *)"type", (xmlChar *)"Symmetric");
	xmlAddChild(sig,cur);
	xmlAddChild(this->envelope,sig);


	xmlDocDumpFormatMemory(this->doc,&buf,&bufsize,this->printPretty);
	if (-1 == bufsize) {
		ERROR("error building envelope\n");
		return -1;
	}

        SSSRMAP_initiate(this);

	outsize = snprintf(outbuf,sizeof(outbuf),"%X\r\n",bufsize);
	write(this->filedes,outbuf,outsize);

	write(this->filedes,(char *)buf,bufsize);

	outsize = snprintf(outbuf,sizeof(outbuf),"\r\n");
	write(this->filedes,outbuf,outsize);

	write(this->filedes,"0\r\n",3);

	xmlUnlinkNode(request);
	xmlFreeNode(request);

	xmlBufferFree(bodybuf);
	xmlFree(buf);
	return 0;
}

SSSRMAPResponse *SSSRMAP_getResponse(SSSRMAPSession *this)
{
	char messagebuf[1024*1024];
	char *cur=NULL;
	unsigned int numread=0;
	char msgrcved = 0;
	unsigned int msglen = 0;
	unsigned int msgread = 0;
	int temp;
	xmlDocPtr doc;
	SSSRMAPResponse *retval;
	xmlNodePtr root,curNode, child;

	while(!msgrcved) {
		temp = read(this->filedes, messagebuf+numread, sizeof(messagebuf)-numread);
		if (-1 == temp) {
			perror("getResponse");
			exit(1);
		}
		numread += temp;
		messagebuf[numread] = '\0';
		if((cur = strstr(messagebuf,"\r\n\r\n"))) {
			cur += 4;
			msgrcved = 1;
		}
	}
	msgrcved = sscanf(cur,"%x\r\n",&msglen);
	while (!msgrcved || msgrcved == -1) {
		numread += read(this->filedes, messagebuf+numread, sizeof(messagebuf)-numread);
		messagebuf[numread] = '\0';
		msgrcved = sscanf(cur,"%x\r\n",&msglen);
	}
	while(*cur != '\n')
		cur += 1;
	cur += 1;

	while(msglen > (numread - (cur - messagebuf)))
		numread += read(this->filedes, messagebuf+numread, sizeof(messagebuf)-numread);

	numread += msgread;
	messagebuf[numread] = '\0';

	doc = xmlReadMemory(cur,msglen, "noname.xml", NULL, 0);
	
	retval = (SSSRMAPResponse *)malloc(sizeof(SSSRMAPResponse));
	
	root = xmlDocGetRootElement(doc);
	curNode = root->children->children->children;
	for(curNode = root->children->children->children;curNode;curNode = curNode->next) {
		if(!strcmp((char *)curNode->name, "Status")) {
			for(child = curNode->children;child;child = child->next) {
				if(!strcmp((char *)child->name,"Value"))
					retval->statusValue = strdup((char *)child->children->content);
				else if(!strcmp((char *)child->name,"Code"))
					retval->statusCode = strdup((char *)child->children->content);
			}
		}
		else if(!strcmp((char *)curNode->name, "Count")) {
			retval->count = atoi((char *)curNode->children->content);
		}
		else if(!strcmp((char *)curNode->name, "Data")) {
			SSSRMAPItem *tail = NULL,*cur;
			struct NVNode *curField;
			xmlNodePtr dataChild;

			retval->head = NULL;
			for(child = curNode->children;child;child = child->next) {
				cur = (SSSRMAPItem *)malloc(sizeof(SSSRMAPItem));
				cur->next = NULL;
				if (NULL == retval->head)
					retval->head = cur;

				cur->head = NULL;
				for(dataChild = child->children;dataChild;dataChild = dataChild->next){
					curField = (struct NVNode *)malloc(sizeof(struct NVNode));
					if(dataChild->name)
						curField->name = strdup((char *)dataChild->name);
					else
						curField->name = NULL;
					if(dataChild->children && dataChild->children->content)
						curField->value = strdup((char *)dataChild->children->content);
					else
						curField->value = NULL;
					curField->next = cur->head;
					cur->head = curField;
				}
				if (NULL != tail)
					tail->next = cur;
				tail = cur;
				
			}
		}
	}
	retval->cur = retval->head;
	xmlFreeDoc(doc);
	return retval;
}
void SSSRMAP_freeResponse(SSSRMAPResponse *this)
{
	SSSRMAPItem *curItem;
	struct NVNode *curField;
	free(this->statusValue);
	free(this->statusCode);
	while(this->head) {
		curItem = this->head;
		while(curItem->head) {
			curField = curItem->head;
			curItem->head = curItem->head->next;
			free(curField->name);
			free(curField->value);
			free(curField);
		}
		this->head = curItem->next;
		free(curItem);
	}
	free(this);
}

SSSRMAPSession *SSSRMAP_allocSession()
{
	SSSRMAPSession *this = (SSSRMAPSession *)malloc(sizeof(SSSRMAPSession));
	this->filedes = 0;
	this->printPretty = 0;
	this->hostname = NULL;
	this->doc = xmlNewDoc((xmlChar *)"1.0");
	this->envelope = xmlNewNode(SSSRMAPNS,(xmlChar *)"Envelope");
	xmlDocSetRootElement(this->doc,this->envelope);
	return this;
}

void SSSRMAP_freeSession(SSSRMAPSession *this)
{
	free(this->hostname);
	free(this->key);
	xmlFreeDoc(this->doc);
	free(this);
}


static SSSRMAPRequest *SSSRMAP_allocRequest()
{
	SSSRMAPRequest *this = (SSSRMAPRequest *)malloc(sizeof(SSSRMAPRequest));
	this->actor = NULL;
	this->id = NULL;
	this->object = (xmlChar *)"Job";
	this->childStruct = NULL;
	return this;
}

static void SSSRMAP_freeRequest(SSSRMAPRequest *this)
{
	if(this->actor)
		free(this->actor);
	if(this->id)
		free(this->id);
	if(this->object)
		free(this->object);
	free(this);
}

void SSSRMAP_setActor(SSSRMAPRequest *this, char *actor)
{
	this->actor = (xmlChar *)strdup(actor);
}

void SSSRMAP_setObject(SSSRMAPRequest *this, char *object)
{
	this->object = (xmlChar *)strdup(object);
}


SSSRMAPRequest *SSSRMAP_allocQuery()
{
	SSSRMAPRequest *this = SSSRMAP_allocRequest();
	this->childStruct = malloc(sizeof(struct SSSRMAPQuery));
	((struct SSSRMAPQuery *)(this->childStruct))->head = NULL;
	this->getRequest = SSSRMAP_Query_getRequest;
	return this;
}

void SSSRMAP_freeQuery(SSSRMAPRequest *this)
{
	struct NVNode *cur = ((struct SSSRMAPQuery *)(this->childStruct))->head;
	while(cur) {
		((struct SSSRMAPQuery *)(this->childStruct))->head = cur->next;
		free(cur->name);
		free(cur->value);
		free(cur);
		cur = ((struct SSSRMAPQuery *)(this->childStruct))->head;
	}
	free(this->childStruct);
	SSSRMAP_freeRequest(this);
}

void SSSRMAP_addFilter(SSSRMAPRequest *this, char *name, char *value)
{
	struct NVNode *cur = (struct NVNode *)malloc(sizeof(struct NVNode));
	cur->name = strdup(name);
	cur->value = strdup(value);
	cur->next = ((struct SSSRMAPQuery *)(this->childStruct))->head;
	((struct SSSRMAPQuery *)(this->childStruct))->head = cur;
}

xmlNodePtr SSSRMAP_Query_getRequest(SSSRMAPRequest *this)
{
	xmlNodePtr xmlcur;
	xmlChar id[16];
	long int rndid;
	struct NVNode *cur = ((struct SSSRMAPQuery *)(this->childStruct))->head;
	xmlNodePtr request = xmlNewNode(SSSRMAPNS,(xmlChar *)"Request");

	srandom(time(NULL));
	rndid = random();
	snprintf((char *)id,sizeof(id),"%ld",rndid);
	xmlSetProp(request, (xmlChar *)"id", id);
	xmlSetProp(request,(xmlChar *)"action", (xmlChar *)"Query");
	if(this->actor)
		xmlSetProp(request,(xmlChar *)"actor", (xmlChar *)this->actor);

	xmlcur = xmlNewNode(SSSRMAPNS,(xmlChar *)"Object");
	xmlNodeSetContent(xmlcur,(xmlChar *)this->object);
	xmlAddChild(request,xmlcur);
	while(cur) {
		xmlcur = xmlNewNode(SSSRMAPNS,(xmlChar *)"Where");
		xmlSetProp(xmlcur,(xmlChar *)"name",(xmlChar *)cur->name);
		xmlNodeSetContent(xmlcur,(xmlChar *)cur->value);
		xmlAddChild(request,xmlcur);
		cur = cur->next;
	}
	return request;
}

SSSRMAPItem *SSSRMAP_fetchItem(SSSRMAPResponse *this)
{
	SSSRMAPItem *retval;
	retval = this->cur;
	if(this->cur != NULL)
		this->cur = this->cur->next;
	return retval;
}

char *SSSRMAP_getField(SSSRMAPItem *this,char *name)
{
	struct NVNode *cur = this->head;
	while(cur != NULL && strcmp(name, cur->name))
		cur = cur->next;
	return cur->value;
}

int SSSRMAP_getFieldNames(SSSRMAPItem *this,char **names,int size)
{
	struct NVNode *cur = this->head;
	int entryNum = 0;
	while(--size && cur) {
		names[entryNum++] = cur->name;
		cur = cur->next;
	}
	names[entryNum] = NULL;
	return entryNum;
}

char* SSSRMAP_getNextFieldName(SSSRMAPItem *this)
{
	char *fieldName;
	if (!this->curField)
		return NULL;
	fieldName = this->curField->name;
	this->curField = this->curField->next;
	return fieldName;
}

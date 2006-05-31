import _sssrmap

class request(object):
	def __init__(self):
		self._request = None

	def setActor(self, actor):
		_sssrmap.SSSRMAP_setActor(self._request,actor)

	def setObject(self, object):
		_sssrmap.SSSRMAP_setObject(self._request,object)
		
class query(request):
	def __init__(self):
		self._request = _sssrmap.SSSRMAP_allocQuery()

	def __del__(self):
		_sssrmap.SSSRMAP_freeQuery(self._request)
	
	def addFilter(self, name, value):
		_sssrmap.SSSRMAP_addFilter(self._request, name, value)

class response(object):
	def __init__(self, response):
		self._response = response
	
	def __del__(self):
		_sssrmap.SSSRMAP_freeResponse(self._response)
	
	def fetchItem(self):
		item = {}
		tempItem = _sssrmap.SSSRMAP_fetchItem(self._response);
		name = _sssrmap.SSSRMAP_getNextFieldName(tempItem);
		while(name):
			item[name] = _sssrmap.SSSRMAP_getField(tempItem, name)
			name = _sssrmap.SSSRMAP_getNextFieldName(tempItem);

	def fetchItems(self):
		yield fetchItem()
class session(object):
	def __init__(self):
		self._session = _sssrmap.SSSRMAP_allocSession()

	def __del__(self):
		_sssrmap.SSSRMAP_freeSession(self._session)

	def connectHost(self, hostname, port):
		_sssrmap.SSSRMAP_connectHost(self._session, hostname, port)

	def connectFile(self, file):
		try:
			_sssrmap.SSSRMAP_connectFiledes(self._session, file.fileno)
		except AttributeError:
			_sssrmap.SSSRMAP_connectFiledes(self._session, file)

	def setKey(self, key):
		_sssrmap.SSSRMAP_setKey(self._session, key)

	def sendMessage(self, request):
		_sssrmap.SSSRMAP_sendMessage(self._session, request._request)

	def printPretty(self, pretty):
		_sssrmap.SSSRMAP_printPretty(self._session, pretty)

	def getResponse(self):
		tempresponse = _sssrmap.SSSRMAP_getResponse(self._session)
		return response(tempresponse)

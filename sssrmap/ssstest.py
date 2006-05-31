#!/usr/bin/python
import sssrmap

sess = sssrmap.session()
sess.connectHost("localhost",7112)
sess.setKey("asdf jkl;")
query = sssrmap.query()
query.setObject("User")
query.setActor("kschmidt")
query.addFilter("Name", "kschmidt")
sess.sendMessage(query)
resp = sess.getResponse()
print resp.fetchItem()


#! /bin/python

import sys, os, pwd, string

############################################################################
# Object class
############################################################################

# Object Class
class Object:
  """a request object (corresponds to an Object Element in SSSRMAP)"""

  # Constructor
  def __init__(self, **arg):
    """object = Object(name=name, alias=alias, join=join)"""

    # name
    if arg.has_key('name'):
      self.name = arg['name']
    else:
      self.name = ""

    # alias
    if arg.has_key('alias'):
      self.alias = arg['alias']
    else:
      self.alias = ""

    # join
    if arg.has_key('join'):
      self.join = arg['join']
    else:
      self.join = ""

  # Get the object name
  def getName(self):
    """name = object.getName()"""
    return self.name

  # Get the object alias
  def getAlias(self):
    """alias = object.getAlias()"""
    return self.alias

  # Get the object join
  def getJoin(self):
    """join = object.getJoin()"""
    return self.join

  # Set the object name
  def setName(self, name):
    """object = object.setName(name)"""
    self.name = name
    return self

  # Set the object alias
  def setAlias(self, alias):
    """object = object.setAlias(alias)"""
    self.alias = alias
    return self

  # Set the object join
  def setJoin(self, join):
    """object = object.setJoin(join)"""
    self.join = join
    return self

  # Convert object to printable string
  def toString(self):
    """str = object.toString()"""
    str = "("
    str += self.name
    str += ", "
    str += self.alias
    str += ", "
    str += self.join
    str += ")"
    return str


############################################################################
# Selection class
############################################################################

# Selection Class
class Selection:
  """an object property to be returned in a query (corresponds to a Get Element in SSSRMAP)"""

  # Constructor
  def __init__(self, **arg):
    """selection = Selection(name=name, op=op, object=object)"""

    # name
    if arg.has_key('name'):
      self.name = arg['name']
    else:
      self.name = ""

    # operator
    if arg.has_key('op'):
      self.op = arg['op']
    else:
      self.op = ""

    # object
    if arg.has_key('object'):
      self.object = arg['object']
    else:
      self.object = ""

  # Get the selection name
  def getName(self):
    """name = selection.getName()"""
    return self.name

  # Get the selection operator
  def getOperator(self):
    """op = selection.getOperator()"""
    return self.op

  # Get the selection object
  def getObject(self):
    """object = selection.getObject()"""
    return self.object

  # Set the selection name
  def setName(self, name):
    """selection = selection.setName(name)"""
    self.name = name
    return self

  # Set the selection operator
  def setOperator(self, op):
    """selection = selection.setOperator(op)"""
    self.op = op
    return self

  # Set the selection object
  def setObject(self, object):
    """selection = selection.setObject(object)"""
    self.object = object
    return self

  # Convert selection to printable string
  def toString(self):
    """str = selection.toString()"""
    str = "("
    str += self.name
    str += ", "
    str += self.op
    str += ", "
    str += self.object
    str += ")"
    return str


############################################################################
# Assignment class
############################################################################

# Assignment Class
class Assignment:
  """an object property to be assigned (corresponds to a Set Element in SSSRMAP)"""

  # Constructor
  def __init__(self, **arg):
    """assignment = Assignmemt(name=name, value=value, op=op)"""

    # name
    if arg.has_key('name'):
      self.name = arg['name']
    else:
      self.name = ""

    # value
    if arg.has_key('value'):
      self.value = arg['value']
    else:
      self.value = ""

    # operator
    if arg.has_key('op'):
      self.op = arg['op']
    else:
      self.op = ""

  # Get the assignment name
  def getName(self):
    """name = assignment.getName()"""
    return self.name

  # Get the assignment value
  def getValue(self):
    """value = assignment.getValue()"""
    return self.value

  # Get the assignment operator
  def getOperator(self):
    """op = assignment.getOperator()"""
    return self.op

  # Set the assignment name
  def setName(self, name):
    """assignment = assignment.setName(name)"""
    self.name = name
    return self

  # Set the assignment value
  def setValue(self, value):
    """assignment = assignment.setValue(value)"""
    self.value = value
    return self

  # Set the assignment operator
  def setOperator(self, op):
    """assignment = assignment.setOperator(op)"""
    self.op = op
    return self

  # Convert assignment to printable string
  def toString(self):
    """str = assignment.toString()"""
    str = "("
    str += self.name
    str += ", "
    str += self.value
    str += ", "
    str += self.op
    str += ")"
    return str


############################################################################
# Condition class
############################################################################

# Condition Class
class Condition:
  """a condition used to determine which objects are acted upon (corresponds to a Where Element in SSSRMAP)"""

  # Constructor
  def __init__(self, **arg):
    """condition = Condition(name=name, value=value, op=op)"""

    # name
    if arg.has_key('name'):
      self.name = arg['name']
    else:
      self.name = ""

    # value
    if arg.has_key('value'):
      self.value = arg['value']
    else:
      self.value = ""

    # operator
    if arg.has_key('op'):
      self.op = arg['op']
    else:
      self.op = ""

    # conjunction
    if arg.has_key('conj'):
      self.conj = arg['conj']
    else:
      self.conj = ""

    # group
    if arg.has_key('group'):
      self.group = arg['group']
    else:
      self.group = 0

    # object
    if arg.has_key('object'):
      self.object = arg['object']
    else:
      self.object = ""

    # subject
    if arg.has_key('subject'):
      self.subject = arg['subject']
    else:
      self.subject = ""

  # Get the condition name
  def getName(self):
    """name = condition.getName()"""
    return self.name

  # Get the condition value
  def getValue(self):
    """value = condition.getValue()"""
    return self.value

  # Get the condition operator
  def getOperator(self):
    """op = condition.getOperator()"""
    return self.op

  # Get the condition conjunction
  def getConjunction(self):
    """conj = condition.getConjunction()"""
    return self.conj

  # Get the condition group
  def getGroup(self):
    """group = condition.getGroup()"""
    return self.group

  # Get the condition object
  def getObject(self):
    """object = condition.getObject()"""
    return self.object

  # Get the condition subject
  def getSubject(self):
    """subject = condition.getSubject()"""
    return self.subject

  # Set the condition name
  def setName(self, name):
    """condition = condition.setName(name)"""
    self.name = name
    return self

  # Set the condition value
  def setValue(self, value):
    """condition = condition.setValue(value)"""
    self.value = value
    return self

  # Set the condition operator
  def setOperator(self, op):
    """condition = condition.setOperator(op)"""
    self.op = op
    return self

  # Set the condition conjunction
  def setConjunction(self, conj):
    """condition = condition.setConjunction(conj)"""
    self.conj = conj
    return self

  # Set the condition group
  def setGroup(self, group):
    """condition = condition.setGroup(group)"""
    self.group = group
    return self

  # Set the condition object
  def setObject(self, object):
    """condition = condition.setObject(object)"""
    self.object = object
    return self

  # Set the condition subject
  def setSubject(self, subject):
    """condition = condition.setSubject(subject)"""
    self.subject = subject
    return self

  # Convert condition to printable string
  def toString(self):
    """str = condition.toString()"""
    str = "("
    str += self.name
    str += ", "
    str += self.value
    str += ", "
    str += self.op
    str += ", "
    str += self.conj
    str += ", "
    str += self.group
    str += ", "
    str += self.object
    str += ", "
    str += self.subject
    str += ")"
    return str


############################################################################
# Option class
############################################################################

# Option Class
class Option:
  """a request processing option (corresponds to an Option Element in SSSRMAP)"""

  # Constructor
  def __init__(self, **arg):
    """option = Option(name=name, value=value, op=op)"""

    # name
    if arg.has_key('name'):
      self.name = arg['name']
    else:
      self.name = ""

    # value
    if arg.has_key('value'):
      self.value = arg['value']
    else:
      self.value = ""

    # operator
    if arg.has_key('op'):
      self.op = arg['op']
    else:
      self.op = ""

  # Get the option name
  def getName(self):
    """name = option.getName()"""
    return self.name

  # Get the option value
  def getValue(self):
    """value = option.getValue()"""
    return self.value

  # Get the option operator
  def getOperator(self):
    """op = option.getOperator()"""
    return self.op

  # Set the option name
  def setName(self, name):
    """option = option.setName(name)"""
    self.name = name
    return self

  # Set the option value
  def setValue(self, value):
    """option = option.setValue(value)"""
    self.value = value
    return self

  # Set the option operator
  def setOperator(self, op):
    """option = option.setOperator(op)"""
    self.op = op
    return self

  # Convert option to printable string
  def toString(self):
    """str = option.toString()"""
    str = "("
    str += self.name
    str += ", "
    str += self.value
    str += ", "
    str += self.op
    str += ")"
    return str


############################################################################
# Request class
############################################################################

# Request Class
class Request:
  """an SSSRMAP request"""

  # Constructor
  def __init__(self, **arg):
    """request = Request(action=action, actor=actor, object=name || objects=objects, selections=selections, assignments=assignments, conditions=conditions, options=options, chunking=chunking, chunkSize=chunkSize)"""

    # action
    if arg.has_key('action'):
      self.action = arg['action']
    else:
      self.action = ""

    # actor
    if arg.has_key('actor'):
      self.actor = arg['actor']
    else:
      self.actor = pwd.getpwuid(os.getuid())[0]

    # objects
    if arg.has_key('object'):
      self.objects = [ Object(name=arg['object']) ]
    elif arg.has_key('objects'):
      self.objects = arg['objects']
    else:
      self.objects = []

    # selections
    if arg.has_key('selections'):
      self.selections = arg['selections']
    else:
      self.selections = []

    # assignments
    if arg.has_key('assignments'):
      self.assignments = arg['assignments']
    else:
      self.assignments = []

    # conditions
    if arg.has_key('conditions'):
      self.conditions = arg['conditions']
    else:
      self.conditions = []

    # options
    if arg.has_key('options'):
      self.options = arg['options']
    else:
      self.options = []

    # chunking
    if arg.has_key('chunking'):
      self.chunking = arg['chunking']
    else:
      self.chunking = 0

    # chunk size
    if arg.has_key('chunkSize'):
      self.chunkSize = arg['chunkSize']
    else:
      self.chunkSize = 1000

  # Get the request action
  def getAction(self):
    """action = request.getAction()"""
    return self.action

  # Get the request actor
  def getActor(self):
    """actor = request.getActor()"""
    return self.actor

  # Get the request objects
  def getObjects(self):
    """objects = request.getObjects()"""
    return self.objects

  # Get the first request object
  def getObject(self):
    """object = request.getObject()"""
    if len(self.objects) > 0:
      return self.objects[0]
    else:
      return ""

  # Get the request selections
  def getSelections(self):
    """selections = request.getSelections()"""
    return self.selections

  # Get the request assignments
  def getAssignments(self):
    """assignments = request.getAssignments()"""
    return self.assignments

  # Get an assignment value by name
  def getAssignmentValue(self, name):
    """value = request.getAssignmentValue(name)"""
    for assignment in self.assignments:
      if assignment.getName() == name:
        return assignment.getValue()
    return ""

  # Get the request conditions
  def getConditions(self):
    """conditions = request.getConditions()"""
    return self.conditions

  # Get a condition value by name
  def getConditionValue(self, name):
    """value = request.getConditionValue(name)"""
    for condition in self.conditions:
      if condition.getName() == name:
        return condition.getValue()
    return ""

  # Get the request options
  def getOptions(self):
    """options = request.getOptions()"""
    return self.options

  # Get an option value by name
  def getOptionValue(self, name):
    """value = request.getOptionValue(name)"""
    for option in self.options:
      if options.getName() == name:
        return options.getValue()
    return ""

  # Get the request chunking
  def getChunking(self):
    """boolean = request.getChunking()"""
    return self.chunking

  # Get the request chunk size
  def getChunkSize(self):
    """size = request.getChunkSize()"""
    return self.chunkSize

  # Set the request action
  def setAction(self, action):
    """request = request.setAction(action)"""
    self.action = action
    return self

  # Set the request actor
  def setActor(self, actor):
    """request = request.setActor(actor)"""
    self.actor = actor
    return self

  # Set the request objects from a list
  def setObjects(self, objects):
    """request = request.setObjects(objects)"""
    self.objects = objects
    return self

  # Set a request object
  def setObject(self, name):
    """request = request.setObject(name)"""
    self.objects.append(Object(name=name))
    return self

  # Set the request selections from a list
  def setSelections(self, selections):
    """request = request.setSelections(selections)"""
    self.selections = selections
    return self

  # Set a request selection
  def setSelection(self, selection):
    """request = request.setSelection(selection)"""
    self.selections.append(selection)
    return self

  # Set the request assignments from a list
  def setAssignments(self, assignments):
    """request = request.setAssignments(assignments)"""
    self.assignments = assignments
    return self

  # Set a request assignment
  def setAssignment(self, assignment):
    """request = request.setAssignment(assignment)"""
    self.assignments.append(assignment)
    return self

  # Set the request conditions from a list
  def setConditions(self, conditions):
    """request = request.setConditions(conditions)"""
    self.conditions = conditions
    return self

  # Set a request condition
  def setCondition(self, condition):
    """request = request.setCondition(condition)"""
    self.conditions.append(condition)
    return self

  # Set the request options from a list
  def setOptions(self, options):
    """request = request.setOptions(options)"""
    self.options = options
    return self

  # Set a request option
  def setOption(self, option):
    """request = request.setOption(option)"""
    self.options.append(option)
    return self

  # Set the request chunking
  def setChunking(self, chunking):
    """request = request.setChunking(boolean)"""
    self.chunking = chunking
    return self

  # Set the request chunk size
  def setChunkSize(self, chunkSize):
    """request = request.setChunkSize(boolean)"""
    self.chunkSize = chunkSize
    return self

  # Convert request to printable string
  def toString(self):
    """str = request.toString()"""
    str = "("
    str += self.action
    str += ", "
    str += self.actor
    str += ", "
    str += "[" + string.join(map((lambda object: object.toString()), self.objects), ", ") + "]"
    str += ", "
    str += "[" + string.join(map((lambda selection: selection.toString()), self.selections), ", ") + "]"
    str += ", "
    str += "[" + string.join(map((lambda assignment: assignment.toString()), self.assignments), ", ") + "]"
    str += ", "
    str += "[" + string.join(map((lambda condition: conditions.toString()), self.conditions), ", ") + "]"
    str += ", "
    str += "[" + string.join(map((lambda option: options.toString()), self.options), ", ") + "]"
    return str
    

############################################################################
# Response class
############################################################################

# Response Class
class Response:
  """an SSSRMAP response"""

  # Constructor
  def __init__(self, **arg):
    """response = Response(actor=actor, status=status, code=code, message=message, count=count, chunkNum=chunkNum, chunkSize=chunkSize)"""

    # actor
    if arg.has_key('actor'):
      self.actor = arg['actor']
    else:
      self.actor = pwd.getpwuid(os.getuid())[0]

    # status
    if arg.has_key('status'):
      self.status = arg['status']
    else:
      self.status = "Failure"

    # code
    if arg.has_key('code'):
      self.code = arg['code']
    else:
      self.code = "999"

    # message
    if arg.has_key('message'):
      self.message = arg['message']
    else:
      self.message = ""

    # count
    if arg.has_key('count'):
      self.count = arg['count']
    else:
      self.count = -1

    # chunk number
    if arg.has_key('chunkNum'):
      self.chunkNum = arg['chunkNum']
    else:
      self.chunkNum = 1

    # chunk max
    if arg.has_key('chunkMax'):
      self.chunkMax = arg['chunkMax']
    else:
      self.chunkMax = 0

  # Get the response actor
  def getActor(self):
    """actor = response.getActor()"""
    return self.actor

  # Get the response status
  def getStatus(self):
    """status = response.getStatus()"""
    return self.status

  # Get the response code
  def getCode(self):
    """code = response.getCode()"""
    return self.code

  # Get the response message
  def getMessage(self):
    """message = response.getMessage()"""
    return self.message

  # Get the response count
  def getCount(self):
    """count = response.getCount()"""
    return self.count

  # Get the response chunk number
  def getChunkNum(self):
    """num = response.getChunkNum()"""
    return self.chunkNum

  # Get the response chunk maximum
  def getChunkMax(self):
    """max = response.getChunkMax()"""
    return self.chunkMax

  # Set the response actor
  def setActor(self, actor):
    """response = response.setActor(actor)"""
    self.actor = actor
    return self

  # Set the response status
  def setStatus(self, status):
    """response = response.setStatus(status)"""
    self.status = status
    return self

  # Set the response code
  def setCode(self, code):
    """response = response.setCode(code)"""
    self.code = code
    return self

  # Set the response message
  def setMessage(self, message):
    """response = response.setMessage(message)"""
    self.message = message
    return self

  # Set the response count
  def setCount(self, count):
    """response = response.setCount(count)"""
    self.count = count
    return self

  # Set the response chunk number
  def setChunkNum(self, chunkNum):
    """response = response.setChunkNum(num)"""
    self.chunkNum = chunkNum
    return self

  # Set the response chunk maximum
  def setChunkMax(self, chunkMax):
    """response = response.setChunkMax(max)"""
    self.chunkMax = chunkMax
    return self

  # Convert response to printable string
  def toString(self):
    """str = response.toString()"""
    str = "("
    str += self.actor
    str += ", "
    str += self.status
    str += ", "
    str += self.code
    str += ", "
    str += self.message
    str += ", "
    str += self.count
    str += ", "
    str += self.chunkNum
    str += ", "
    str += self.chunkMax
    return str
    

# Unit test driver
if __name__ == "__main__":
    request = Request(action="Query", object="User")
    #request.setSelection(Selection(name="Name")).setSelection(Selection(name="PhoneNumber"))
    #request.setAssignment(Assignment(name="Name", value="Value"))
    print request.toString()





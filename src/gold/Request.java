/******************************************************************************
 *                                                                            *
 *                          Copyright (c) 2003, 2004                          *
 *                 Pacific Northwest National Laboratory,                     *
 *                        Battelle Memorial Institute.                        *
 *                            All rights reserved.                            *
 *                                                                            *
 ******************************************************************************
 *                                                                            *
 *    Redistribution and use in source and binary forms, with or without      *
 *    modification, are permitted provided that the following conditions      *
 *    are met:                                                                *
 *                                                                            *
 *    · Redistributions of source code must retain the above copyright        *
 *    notice, this list of conditions and the following disclaimer.           *
 *                                                                            *
 *    · Redistributions in binary form must reproduce the above copyright     *
 *    notice, this list of conditions and the following disclaimer in the     *
 *    documentation and/or other materials provided with the distribution.    *
 *                                                                            *
 *    · Neither the name of Battelle nor the names of its contributors        *
 *    may be used to endorse or promote products derived from this software   *
 *    without specific prior written permission.                              *
 *                                                                            *
 *    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS     *
 *    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT       *
 *    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       *
 *    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE          *
 *    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,     *
 *    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,    *
 *    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;        *
 *    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER        *
 *    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT      *
 *    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN       *
 *    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         *
 *    POSSIBILITY OF SUCH DAMAGE.                                             *
 *                                                                            *
 ******************************************************************************/

package gold;

import java.util.*;
import java.net.Socket;

import org.jdom.*;

import org.apache.log4j.*;

import gold.*;

public class Request implements Constants, Cloneable
{
  // private String _object = new String(); // A string
  private LinkedList _objects = new LinkedList(); // A List of Objects
  private String _action = new String(); // A string
  private String _actor = new String(); // A string
  private LinkedList _selections = new LinkedList(); // A List of Selections
  private LinkedList _assignments = new LinkedList(); // A List of Assignments
  private LinkedList _conditions = new LinkedList(); // A List of Conditions
  private LinkedList _options = new LinkedList(); // A List of Options
  private LinkedList _data = new LinkedList(); // A List of Data
  private boolean _override = false; // A boolean
  private boolean _chunking = Boolean.valueOf(Config.getProperty("response.chunked", RESPONSE_CHUNKING)).booleanValue(); // A boolean
  private int _chunkSize = Integer.parseInt(Config.getProperty("response.chunkSize", RESPONSE_CHUNKSIZE));
  
  static Logger log = Logger.getLogger(gold.Request.class);

  // Empty Constructor
  public Request()
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }
  }

  // Basic Constructor
  public Request(String object, String action)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + object + ", " + action + ")");
    }
    _objects.add(new Object(object));
    //_object = object;
    _action = action;
  }

  // Authenticated Constructor
  public Request(String object, String action, String actor)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + object + ", " + action + ", " + actor + ")");
    }
    _objects.add(new Object(object));
    //_object = object;
    _action = action;
    _actor = actor;
  }

  // Old General Constructor
  public Request(String object, String action, LinkedList selections, LinkedList assignments, LinkedList conditions, LinkedList options, LinkedList data)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + object + ", " + action + ", " + selections + ", " + assignments + ", " + conditions + ", " + data + ")");
    }
    _objects.add(new Object(object));
    //_object = object;
    _action = action;
    _selections = selections;
    _assignments = assignments;
    _conditions = conditions;
    _options = options;
    _data = data;
  }

  // Authenticated General Constructor
  public Request(String object, String action, String actor, LinkedList selections, LinkedList assignments, LinkedList conditions, LinkedList options, LinkedList data)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + object + ", " + action + ", " + actor + ", " + selections + ", " + assignments + ", " + conditions + ", " + data + ")");
    }
    //_object = object;
    _objects.add(new Object(object));
    _action = action;
    _actor = actor;
    _selections = selections;
    _assignments = assignments;
    _conditions = conditions;
    _options = options;
    _data = data;
  }

  // Override inherited clone() to make it public
  public java.lang.Object clone() throws CloneNotSupportedException
  {  
    return super.clone();
  }

  // Accessors

  // Get the objects List
  public LinkedList getObjects()
  {
    return new LinkedList(_objects);
  }

  // Gets the request object
  public String getObject()
  {
    Iterator objectItr = _objects.iterator();
    if (objectItr.hasNext())
    {
      return ((Object)objectItr.next()).getName();
    }
    return (String)null;
    //return _object;
  }
    
  // Get the request action
  public String getAction()
  {
    return _action;
  }

  // Get the request actor
  public String getActor()
  {
    return _actor;
  }

  // Get the selections List
  public LinkedList getSelections()
  {
    return new LinkedList(_selections);
  }

  // Get a selection by name
  public Selection getSelection(String name)
  {
    Iterator selectionItr = _selections.iterator();
    while (selectionItr.hasNext())
    {
      Selection selection = (Selection)selectionItr.next();
      if (selection.getName().equals(name))
      {
        return selection;
      }
    }
    return (Selection)null;
  }

  // Get the assignments List
  public LinkedList getAssignments()
  {
    return new LinkedList(_assignments);
  }

  // Get an assignment by name
  public Assignment getAssignment(String name)
  {
    Iterator assignmentItr = _assignments.iterator();
    while (assignmentItr.hasNext())
    {
      Assignment assignment = (Assignment)assignmentItr.next();
      if (assignment.getName().equals(name))
      {
        return assignment;
      }
    }
    return (Assignment)null;
  }

  // Get an assignment value by name
  public String getAssignmentValue(String name)
  {
    Iterator assignmentItr = _assignments.iterator();
    while (assignmentItr.hasNext())
    {
      Assignment assignment = (Assignment)assignmentItr.next();
      if (assignment.getName().equals(name))
      {
        return assignment.getValue();
      }
    }
    return (String)null;
  }

  // Get the conditions List
  public LinkedList getConditions()
  {
    return new LinkedList(_conditions);
  }

  // Get a condition by name
  public Condition getCondition(String name)
  {
    Iterator conditionItr = _conditions.iterator();
    while (conditionItr.hasNext())
    {
      Condition condition = (Condition)conditionItr.next();
      if (condition.getName().equals(name))
      {
        return condition;
      }
    }
    return (Condition)null;
  }

  // Get a condition value by name
  public String getConditionValue(String name)
  {
    Iterator conditionItr = _conditions.iterator();
    while (conditionItr.hasNext())
    {
      Condition condition = (Condition)conditionItr.next();
      if (condition.getName().equals(name))
      {
        return condition.getValue();
      }
    }
    return (String)null;
  }

  // Get the options List
  public LinkedList getOptions()
  {
    return new LinkedList(_options);
  }

  // Get an option by name
  public Option getOption(String name)
  {
    Iterator optionItr = _options.iterator();
    while (optionItr.hasNext())
    {
      Option option = (Option)optionItr.next();
      if (option.getName().equals(name))
      {
        return option;
      }
    }
    return (Option)null;
  }

  // Get an option value by name
  public String getOptionValue(String name)
  {
    Iterator optionItr = _options.iterator();
    while (optionItr.hasNext())
    {
      Option option = (Option)optionItr.next();
      if (option.getName().equals(name))
      {
        return option.getValue();
      }
    }
    return (String)null;
  }

  // Get request data (list of data)
  public LinkedList getData()
  {
     return new LinkedList(_data);
  }

  // Get request data element
  public Element getDataElement()
  {
    Element data = new Element("Data");
    Iterator dataItr = _data.iterator();
    while (dataItr.hasNext())
    {
      Element datum = ((Datum)dataItr.next()).getElement();
      data.addContent(datum);
    }
     return data;
  }

  // Get the value of the named property in the first datum
  public String getDatumValue(String name)
  {
    String value = (String)null;
    Iterator dataItr = _data.iterator();
    if (dataItr.hasNext())
    {
      Element datum = ((Datum)dataItr.next()).getElement();
      value = datum.getChildText(name);
    }
     return value;
  }

  // Gets the override
  public boolean getOverride()
  {
    return _override;
  }
    
  // Gets the chunking flag
  public boolean getChunking()
  {
    return _chunking;
  }
    
  // Gets the chunk size
  public int getChunkSize()
  {
    return _chunkSize;
  }
    
  public String toString()
  {
    String data = (String)null;
    Vector v = new Vector();
    //v.add(_object);
    v.add(_action);
    v.add(_actor);
    v.add(_objects);
    v.add(_selections);
    v.add(_assignments);
    v.add(_conditions);
    v.add(_options);
    v.add(_data);
    v.add(String.valueOf(_chunking));
    v.add(String.valueOf(_chunkSize));
    return v.toString();
  }

  // Mutators

  // Set the objects from a List
  public void setObjects(LinkedList objects)
  {
    _objects = new LinkedList(objects);
  }

  // Set the request object
  public void setObject(String object)
  {
    _objects.add(new Object(object));
    //_object = object;
  }

  // Set the request action
  public void setAction(String action)
  {
    _action = action;
  }

  // Set the request actor
  public void setActor(String actor)
  {
    _actor = actor;
  }

  // Set the selections from a List
  public void setSelections(LinkedList selections)
  {
    _selections = new LinkedList(selections);
  }

  // Set a selection by selection
  public void setSelection(Selection selection)
  {
    _selections.add(selection);
  }

  // Set a selection by name only
  public void setSelection(String name)
  {
    _selections.add(new Selection(name));
  }

  // Set a selection by name and op
  public void setSelection(String name, String op)
  {
    _selections.add(new Selection(name, op));
  }

  // Set the assignments from a List
  public void setAssignments(LinkedList assignments)
  {
    _assignments = new LinkedList(assignments);
  }

  // Set an assignment by assignment
  public void setAssignment(Assignment assignment)
  {
    _assignments.add(assignment);
  }

  // Set an assignment by name and value
  public void setAssignment(String name, String value)
  {
    _assignments.add(new Assignment(name, value));
  }

  // Set an assignment by name, value and op
  public void setAssignment(String name, String value, String op)
  {
    _assignments.add(new Assignment(name, value, op));
  }

  // Set the conditions from a List
  public void setConditions(LinkedList conditions)
  {
    _conditions = new LinkedList(conditions);
  }

  // Set a condition by condition
  public void setCondition(Condition condition)
  {
    _conditions.add(condition);
  }

  // Set a condition by name and value
  public void setCondition(String name, String value)
  {
    _conditions.add(new Condition(name, value));
  }

  // Set a condition by name, value and op
  public void setCondition(String name, String value, String op)
  {
    _conditions.add(new Condition(name, value, op));
  }

  // Set a condition by name, value, op, conj and group
  public void setCondition(String name, String value, String op, String conj, String group)
  {
    _conditions.add(new Condition(name, value, op, conj, group));
  }

  // Set the options from a List
  public void setOptions(LinkedList options)
  {
    _options = new LinkedList(options);
  }

  // Set an option by option
  public void setOption(Option option)
  {
    _options.add(option);
  }

  // Set an option by name only
  public void setOption(String name)
  {
    _options.add(new Option(name));
  }

  // Set an option by name and value
  public void setOption(String name, String value)
  {
    _options.add(new Option(name, value));
  }

  // Set an option by name, value and operator
  public void setOption(String name, String value, String op)
  {
    _options.add(new Option(name, value, op));
  }

  // Set request data (list of data)
  public void setData(LinkedList data)
  {
    _data = new LinkedList(data);
  }

  // Set request data element
  public void setDataElement(Element data)
  {
    Iterator dataItr = data.getChildren().iterator();
    while (dataItr.hasNext())
    {
      _data.add(new Datum((Element)dataItr.next()));
    }
  }

  // Set the override
  public void setOverride(boolean override)
  {
    _override = override;
  }

  // Set the chunking flag
  public void setChunking(boolean chunking)
  {
    _chunking = chunking;
  }

  // Set the chunk size
  public void setChunkSize(int chunkSize)
  {
    _chunkSize = chunkSize;
  }

  // Add a request datum
  public void setDatum(Datum datum)
  {
    _data.add(datum);
  }

  // Obtain Response
  public Response getResponse()
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    Document envelope;
    Response response;
    Chunk replyChunk, messageChunk;

    // Instantiate a new Chunk
    messageChunk = new Chunk();

    // Append the request to the message
    if (log.isDebugEnabled())
    {
      log.debug("Appending request to message chunk");
    }
    messageChunk.setRequest(this);
    if (log.isDebugEnabled())
    {
      log.debug("Message chunk built");
    }

    // Obtain the reply chunk
    if (log.isDebugEnabled())
    {
      log.debug("Obtaining reply chunk from server");
    }
    try
    {
      replyChunk = messageChunk.getChunk();
    }
    catch(GoldException ge)
    {
      return new Response().failure(ge.getCode(), "Failed obtaining reply chunk: " + ge.getMessage());
    }
    if (log.isDebugEnabled())
    {
      log.debug("Obtained reply chunk");
    }

    // Extract the response from the reply chunk
    if (log.isDebugEnabled())
    {
      log.debug("Extracting response from the reply chunk");
    }
    response = replyChunk.getResponse();
    if (log.isDebugEnabled())
    {
      log.debug("Reply chunk parsed. Generated Response: " + response.toString());
    }

    // Return response object
    return response;
  } // end getResponse

}

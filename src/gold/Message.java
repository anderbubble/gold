/******************************************************************************
 *                                                                            *
 *                          Copyright (c) 2003, 2004                          *
 *                        Battelle Memorial Institute.                        *
 *                            All rights reserved.                            *
 *                                                                            *
 ******************************************************************************
 *                                                                            *
 *    Redistribution and use in source and binary forms, with or without      *
 *    modification, are permitted provided that the following conditions      *
 *    are met:                                                                *
 *                                                                            *
 *    - Redistributions of source code must retain the above copyright        *
 *    notice, this list of conditions and the following disclaimer.           *
 *                                                                            *
 *    - Redistributions in binary form must reproduce the above copyright     *
 *    notice, this list of conditions and the following disclaimer in the     *
 *    documentation and/or other materials provided with the distribution.    *
 *                                                                            *
 *    - Neither the name of Battelle nor the names of its contributors        *
 *    may be used to endorse or promote products derived from this software   *
 *    without specific prior written permission.                              *
 *                                                                            *
 *    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS     *
 *    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT       *
 *    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       *
 *    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE          *
 *    U.S. GOVERNMENT OR THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR    *
 *    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  *
 *    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE       *
 *    GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS           *
 *    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER    *
 *    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR         *
 *    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF  *
 *    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                              *
 *                                                                            *
 ******************************************************************************/

package gold;

import java.util.*;
import java.io.*;
import java.net.*;

import org.jdom.*;
import org.jdom.input.SAXBuilder;

import org.apache.log4j.*;

import gold.*;

public class Message implements Constants, Cloneable
{
  private Socket _connection = (Socket) null;
  private Chunk _chunk = (Chunk) null;
  private Reader _input = (Reader) null;
  private Writer _output = (Writer) null;
  private int _chunkNum = 0;
  private int _chunkMax = 0;
  
  static Logger log = Logger.getLogger(gold.Message.class);
  
  // Empty Constructor
  public Message()
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }
  }

  // Connection Constructor
  public Message(Socket connection)
  {    
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (<socket connection>)");
    }  
 
    _connection = connection;
  }    

  // Override inherited clone() to make it public
  public java.lang.Object clone() throws CloneNotSupportedException
  {  
    return super.clone();
  }

  // Serialize message to a printable string
  public String toString()
  {
    Vector v = new Vector();
    v.add(_connection);
    v.add(_input);
    v.add(_output);
    v.add(String.valueOf(_chunkNum));
    v.add(String.valueOf(_chunkNum));
    return v.toString();
  }


  // Close a connection
  public void disconnect() throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    try
    {
      _output.write("0\r\n");
      _output.flush();
      _connection.close();
    }
    catch (IOException e)
    {
      throw new GoldException("200", "Failed disconnecting: " + e.getMessage());
    }

    return;
  } // End disconnect


  // Send the chunk
  public Socket sendChunk(Chunk chunk) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + chunk.toString() + ")");
    }

    // Set the message chunk
    _chunk = chunk;

    InetAddress server;
    String serverHost = Config.getProperty("server.host",SERVER_HOST);
    String serverPort = Config.getProperty("server.port",SERVER_PORT);
    int port = 0;

    try
    {
      port = Integer.parseInt(serverPort);
    }
    catch (NumberFormatException e)
    {
      log.warn("Bad port number: " + serverPort + ". Using 7112 instead.");
      System.out.println(e);
    }

    try
    {
      server = InetAddress.getByName(serverHost);
    }
    catch (UnknownHostException e)
    {
      System.err.println("ERROR: Could not locate default host "
        + serverHost);
      System.err.println("Check to make sure you're connected to the Internet and that DNS is functioning");
      // Rethrow exception
      throw new GoldException("212", e.getMessage());
    }

    try
    {
      _connection = new Socket(server, port);
    }
    catch (IOException e)
    {
      throw new GoldException("224", e.getMessage());
    }

    // Increment the chunk number
    _chunkNum++;

    try
    {
      // Send the header if this is the first chunk
      if (_chunkNum <= 1)
      {
        _output = new OutputStreamWriter(_connection.getOutputStream(),"8859_1");
      
        // Generate HTTP header
        String header = "POST /SSSRMAP3 HTTP/1.1\r\n";
        header += "Content-Type: text/xml; charset=\"utf-8\"\r\n";
        header += "Transfer-Encoding: chunked\r\n";

        // Write out header
        if (log.isDebugEnabled())
        {
          log.debug("Writing out HTTP header:\n" + header);
        }
        _output.write(header + "\r\n");
      }

      // Convert chunk XML to String
      String payload = marshallChunk(chunk);

      // Write out payload for this chunk
      if (log.isDebugEnabled())
      {
        log.debug("Writing out XML payload:\n" + payload);
      }
      String chunkSize = Integer.toHexString(payload.length()).toUpperCase();
      _output.write(chunkSize + "\r\n");
      _output.write(payload);
      _output.flush();

      // This will always be the last chunk
      // Send final bytes
      _output.write("0\r\n");
      _output.flush();

      return _connection;
    }
    catch (IOException e)
    {
      // Rethrow Exception
      throw new GoldException("224", "Failed sending chunk: " + e.getMessage());
    }

  } // End sendChunk


  // Returns a reply (with same connection as invoking message)
  public Reply getReply() throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    Reply reply = new Reply(_connection);

    return reply;
  } // end getReply


  // Get the payload (marshall the chunk object into an XML string)
  public String marshallChunk(Chunk chunk) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + chunk.toString() + ")");
    }

    // Create the envelope
    Element root = new Element("Envelope");

    // Add the envelope to a new document
    Document doc = new Document(root);

    // Create the body
    Element body = new Element("Body");

    // Add the body to the envelope
    root.addContent(body);

    // Append request if defined
    Request intRequest = chunk.getRequest();
    if (intRequest != null)
    {
      // Create a new external request
      Element extRequest = new Element("Request");
  
      // Set chunking attribute as necessary
      if (Boolean.valueOf(Config.getProperty("response.chunking", RESPONSE_CHUNKING)).booleanValue())
      {
        extRequest.setAttribute("chunking", "True");
      }
  
      //// Add object attribute to external request
      //String object = intRequest.getObject();
      //if (! object.equals(""))
      //{
      //  Element extObject = new Element("Object");
      //  extObject.addContent(object);
      //  extRequest.addContent(extObject);
      //}
      //else
      //{
      //  log.error("object not specified in request");
      //  throw new GoldException("311", "object not specified in request");
      //}
  
      // Add objects to external request
      Iterator objectItr = intRequest.getObjects().iterator();
      if (objectItr.hasNext())
      {
        while (objectItr.hasNext())
        {
          Object intObject = (Object)objectItr.next();
          String name = intObject.getName();
          String alias = intObject.getAlias();
          String join = intObject.getJoin();
          Element extObject = new Element("Object");
          if (alias != null && ! alias.equals(""))
          { extObject.setAttribute("alias", alias); }
          if (join != null && ! join.equals(""))
          { extObject.setAttribute("join", join); }
          extObject.addContent(name);
          extRequest.addContent(extObject);
        }
      }
      else
      {
        log.error("no object specified in request");
        throw new GoldException("311", "object not specified in request");
      }
  
      // Add action attribute to external request
      String action = intRequest.getAction();
      if (! action.equals(""))
      {
        extRequest.setAttribute("action", action);
      }
      else
      {
        log.error("action not specified in request");
        throw new GoldException("312", "action not specified in request");
      }
  
      // Add actor attribute to external request
      String actor = intRequest.getActor();
      if (! actor.equals(""))
      {
        extRequest.setAttribute("actor", actor);
      }
      else
      {
        log.error("actor not specified in request");
        throw new GoldException("312", "action not specified in request");
      }
  
      // Add chunking attribute if desired
      if (intRequest.getChunking())
      {
        extRequest.setAttribute("chunking", "True");
      }
  
      // Add options to external request
      Iterator optionItr = intRequest.getOptions().iterator();
      while (optionItr.hasNext())
      {
        Option intOption = (Option)optionItr.next();
        String name = intOption.getName();
        String value = intOption.getValue();
        String op = intOption.getOperator();
        Element extOption = new Element("Option");
        extOption.setAttribute("name", name);
        if (value != null && ! value.equals(""))
        {
          if (name.endsWith("Time"))
          {
            value = toMFT(value);
          }
          extOption.addContent(value);
        }
        if (op != null && ! op.equals(""))
        { extOption.setAttribute("op", op); }
        extRequest.addContent(extOption);
      }
  
      // Add selections to external request
      Iterator selectionItr = intRequest.getSelections().iterator();
       while (selectionItr.hasNext())
       {
        Selection intSelection = (Selection)selectionItr.next();
        String name = intSelection.getName();
        String op = intSelection.getOperator();
        String object = intSelection.getObject();
        String alias = intSelection.getAlias();
        Element extSelection = new Element("Get");
        extSelection.setAttribute("name", name);
         if (op != null && ! op.equals(""))
        { extSelection.setAttribute("op", op); }
         if (object != null && ! object.equals(""))
        { extSelection.setAttribute("object", object); }
         if (alias != null && ! alias.equals(""))
        { extSelection.setAttribute("alias", alias); }
        extRequest.addContent(extSelection);
      }
  
      // Add assignments to external request
      Iterator assignmentItr = intRequest.getAssignments().iterator();
      while (assignmentItr.hasNext())
      {
        Assignment intAssignment = (Assignment)assignmentItr.next();
        String name = intAssignment.getName();
        String value = intAssignment.getValue();
        String op = intAssignment.getOperator();
        Element extAssignment = new Element("Set");
        extAssignment.setAttribute("name", name);
        if (value != null && ! value.equals(""))
        {
          if (name.endsWith("Time"))
          {
            value = toMFT(value);
          }
          extAssignment.addContent(value);
        }
        if (op != null && ! op.equals("") && ! op.equals("assign"))
        { extAssignment.setAttribute("op", op); }
        extRequest.addContent(extAssignment);
      }
  
      // Add conditions to external request
      Iterator conditionItr = intRequest.getConditions().iterator();
      while (conditionItr.hasNext())
      {
        Condition intCondition = (Condition)conditionItr.next();
        String name = intCondition.getName();
        String value = intCondition.getValue();
        String op = intCondition.getOperator();
        String conj = intCondition.getConjunction();
        String group = intCondition.getGroup();
        String object = intCondition.getObject();
        String subject = intCondition.getSubject();
        Element extCondition = new Element("Where");
        extCondition.setAttribute("name", name);
        if (value != null && ! value.equals(""))
        {
          if (name.endsWith("Time"))
          {
            value = toMFT(value);
          }
          extCondition.addContent(value);
        }
        if (op != null && ! op.equals("") && ! op.equals("eq"))
        { extCondition.setAttribute("op", op); }
        if (conj != null && ! conj.equals(""))
        { extCondition.setAttribute("conj", conj); }
        if (group != null && ! group.equals(""))
        { extCondition.setAttribute("group", group); }
        if (object != null && ! object.equals(""))
        { extCondition.setAttribute("object", object); }
        if (subject != null && ! subject.equals(""))
        { extCondition.setAttribute("subject", subject); }
         extRequest.addContent(extCondition);
      }
  
      // Add data to external request
      Element intData = intRequest.getDataElement();
      if (intData.getChildren().size() > 0)
      {
        Element extData = (Element)intData.clone();
        extRequest.addContent(extData);
      }
  
      // Add the request to the body
      body.addContent(extRequest);
    }

    // Sign the document if required
    if (chunk.getAuthentication())
    {
      try
      {
        chunk.sign(doc);
      }
      catch (GoldException ge)
      {
        throw new GoldException("422", "Failed signing message: (" + ge.getMessage() + ").");
      }
    }

    // Encrypt the document if required
    if (chunk.getEncryption())
    {
      try
      {
        chunk.encrypt(doc);
      }
      catch (GoldException ge)
      {
        throw new GoldException("432", "Failed encrypting message: (" + ge.getMessage() + ").");
      }
    }

    // Return the payload
    String payload = (String) null;
    if (doc != null)
    {
      CanonicalXMLOutputter xmlout = new CanonicalXMLOutputter();
      payload = xmlout.outputString(doc);
    }
    return payload;
  }

  // To Message Format Time
  // Converts from human readable time to epoch time
  public static String toMFT(String dateTime)
  {
    if (dateTime.equals("-infinity"))
    {
      return "0";
    }
    else if (dateTime.equals("infinity"))
    {
      return "2147483647";
    }
    else if (dateTime.equals("now"))
    {
      return String.valueOf(System.currentTimeMillis() / 1000);
    }
    else
    {
      java.util.Date date;
      java.text.SimpleDateFormat format;

      format = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      date = format.parse(dateTime, new java.text.ParsePosition(0));
      if (date != null)
      {
        return String.valueOf(date.getTime() / 1000);
      }
      format = new java.text.SimpleDateFormat("yyyy-MM-dd");
      date = format.parse(dateTime, new java.text.ParsePosition(0));
      if (date != null)
      {
        return String.valueOf(date.getTime() / 1000);
      }
      return dateTime;
    }
  }

}

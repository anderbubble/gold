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
import java.net.*;
import java.io.*;
import java.sql.*;
import java.security.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import java.util.zip.*;

import org.jdom.*;
import org.jdom.input.SAXBuilder;

import org.apache.log4j.*;

import gold.*;

public class Reply implements Constants, Cloneable
{
  private Socket _connection = (Socket) null;
  private Chunk _chunk = (Chunk) null;
  private Reader _input = (Reader) null;
  private Writer _output = (Writer) null;
  private boolean _chunking = true;

  static Logger log = Logger.getLogger(gold.Reply.class);

  // Empty Constructor
  public Reply()
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }
  }

  // Connection Constructor
  public Reply(Socket connection)
  {   
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (<socket connection>)");
    } 
 
    _connection = connection;
  }   

  // Reinitialize the reply
  public void initialize(Socket connection)
  {
    _connection = connection;
    _input = (Reader) null;
    _output = (Writer) null;
  }

  // Override inherited clone() to make it public
  public java.lang.Object clone() throws CloneNotSupportedException
  {
    return super.clone();
  }

  // Serialize reply to a printable string
  public String toString()
  {
    Vector v = new Vector();
    v.add(_connection);
    v.add(_chunk);
    v.add(_input);
    v.add(_output);
    v.add(String.valueOf(_chunking));
    return v.toString();
  }


  // Receive the chunk over connection
  public Chunk receiveChunk() throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    int bytesExpected = 0;
    int c;

    try
    {
      // Receive the header if this is the first chunk
      if (_chunk == null)
      {
        String version = "";
        String contentType = "text/xml";
        String contentLength = "";
        String transferEncoding = "";
        StringBuffer headerLineBuf;
        String headerLine;
        String headerProperty;
  
        _input = new InputStreamReader(
          new BufferedInputStream(
          _connection.getInputStream()), "ASCII");
  
        // Read in the HTTP response line
        headerLineBuf = new StringBuffer();
        while (true)
        {
          c = _input.read(); 
          if (c == '\n') { break; }
          if (c == -1)
          {
            log.error("Unexpected End Of File received while parsing HTTP request line");
            throw new GoldException("242", "Unexpected End Of File received while parsing HTTP response line");
          }
          if (c != '\r') { headerLineBuf.append((char) c); }
        }
        headerLine = headerLineBuf.toString();
        if (log.isDebugEnabled())
        {
          log.debug("Read HTTP Request Line: " + headerLine);
        }
  
        StringTokenizer reqTok = new StringTokenizer(headerLine);
        String requestMethod = reqTok.nextToken();
        if (requestMethod.startsWith("HTTP"))
        {
          if (reqTok.hasMoreTokens())
          {
            // Read in Code
            String code = reqTok.nextToken();
            if (! code.equals("200"))
            {
              log.error("Expecting an HTTP Response 200 but received: " + code);
              throw new GoldException("240", "Expected HTTP Response 200 but received: " + code);
            }
          }
        }
        else
        {
          log.error("Invalid HTTP Response Line: " + headerLine);
          throw new GoldException("242", "Invalid HTTP Response Line: " + headerLine);
        }
  
        // Process remaining header lines
        while (true)
        {
          // Read in a header line
          headerLineBuf = new StringBuffer();
          while (true)
          {
            c = _input.read();
            if (c == '\n') { break; }
            if (c == -1)
            {
              log.error("Unexpected End Of File received while parsing HTTP header");
              throw new GoldException("246", "Unexpected End Of File received while parsing HTTP header");
            }
            if (c != '\r') { headerLineBuf.append((char) c); }
          }
          headerLine = headerLineBuf.toString();
          if (log.isDebugEnabled())
          {
            log.debug("Read HTTP Header Line: " + headerLine);
          }
  
          reqTok = new StringTokenizer(headerLine);
  
          // Grab header property name
          if (reqTok.hasMoreTokens())
          {
            headerProperty = reqTok.nextToken();
          }
          // Bail out of header if encounter an empty line
          else { break; }
  
          // Extract Content-Type from header
          if (headerProperty.toLowerCase().equals("content-type:"))
          {
            if (reqTok.hasMoreTokens())
            {
              contentType = reqTok.nextToken(" \t\n\r;");
            }
          }
  
          // Extract Content-Length from header
          if (headerProperty.toLowerCase().equals("content-length:"))
          {
            if (reqTok.hasMoreTokens())
            {
              contentLength = reqTok.nextToken();
            }
          }
  
          // Extract Transfer-Encoding from header
          if (headerProperty.toLowerCase().equals("transfer-encoding:"))
          {
            if (reqTok.hasMoreTokens())
            {
              transferEncoding = reqTok.nextToken();
            }
          }

        } // end while
  
        // Check for valid Content-Type
        if (! contentType.equals("text/xml"))
        {
          log.error("Unsupported Content-Type: " + contentType);
          throw new GoldException("242", "Unsupported Content-Type: " + contentType);
        }
  
        // Check for chunked Transfer-Encoding
        if (! transferEncoding.equals("chunked"))
        {
          log.error("Either Content-Length or chunked Transfer-Encoding must be specified");
          throw new GoldException("242", "Either Content-Length or chunked Transfer-Encoding must be specified");
        }
      }

      // Extract byte count from chunk
      // Read in Chunk Size
      StringBuffer chunkSizeBuf = new StringBuffer();
      String chunkSizeString; 
      while (true)
      {
        c = _input.read();
        if (c == '\n') { break; }
        if (c == -1)
        {
          log.error("Unexpected End Of File received while parsing chunk size");
          throw new GoldException("246", "Unexpected End Of File received while parsing chunk size");
        }
        if (c != '\r') { chunkSizeBuf.append((char) c); }
      }
      chunkSizeString = chunkSizeBuf.toString();
      if (log.isDebugEnabled())
      {
        log.debug("Read HTTP Chunk Size: " + chunkSizeString);
      }

      // Check for valid chunk size
      try
      {
        bytesExpected = Integer.parseInt(chunkSizeString, 16);
      }
      catch (NumberFormatException nfe)
      {
        log.error("Invalid Chunk Size: " + chunkSizeString);
        throw new GoldException("242", "Invalid Chunk Size: " + chunkSizeString);
      }

      if (log.isDebugEnabled())
      {
        log.debug("Chunk byte count: " + String.valueOf(bytesExpected));
      }

      // Initialize payload
      char[] bytes = new char[bytesExpected];

      // Read in payload
      int bytesRead;
      int bytesReceived = 0;
      while (bytesReceived < bytesExpected)
      {
        bytesRead = _input.read(bytes, bytesReceived, bytesExpected-bytesReceived);
        bytesReceived += bytesRead;
      }

      String payload = new String(bytes);
      if (log.isDebugEnabled())
      {
        log.debug("Received reply payload:\n" + payload);
      }

      Chunk chunk = unmarshallChunk(payload);
      _chunk = chunk;

      return chunk;
    } // end try
    catch (Exception e)
    {
      throw new GoldException("226", e.getMessage());
    }
        
  } // end receiveChunk


  // Set the payload (unmarshall the XML string into a chunk object)
  public Chunk unmarshallChunk(String payload) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + payload + ")");
    }

    Chunk chunk = new Chunk();
    Document doc;
    try
    {
      SAXBuilder builder = new SAXBuilder();
      doc = builder.build(new StringReader(payload));
    }
    catch (Exception e)
    {
      throw new GoldException("302", "Failed parsing message: (" + e.getMessage() + ").");
    }
    
    // Decrypt the document if required
    if (chunk.getEncryption())
    {
      try
      {
        chunk.decrypt(doc);
      }
      catch (GoldException ge)
      {
        throw new GoldException("434", "Failed decrypting message: (" + ge.getMessage() + ").");
      }
    }

    // Authenticate the document if required
    if (chunk.getAuthentication())
    {
      try
      {
        chunk.authenticate(doc);
      }
      catch (GoldException ge)
      {
        throw new GoldException("424", "Failed authenticating message: (" + ge.getMessage() + ").");
      }
    }

//    // Protect against crashes by empty responses
//    if (doc == null)
//    {
//      // set a response that says "Empty reply received";
//      return chunk;
//    }
     
    Response intResponse = new Response();

    try
    {
      // Initiate response
      Element root = doc.getRootElement();
      Element extResponse;

      // Fail if root element is wrong
      if (! root.getName().equals("Envelope"))
      {
        log.error("The reply is malformed\nThe root element is " + root.getName() + " but should be Envelope");
        throw new GoldException("242", "The reply is malformed\nThe root element is" + root.getName() + " but should be Envelope");
      }

      // Parse out the body
      Element body = root.getChild("Body");
      if (body == null)
      {
        log.error("No body found in the reply\nEnvelope should have a Body element");
        throw new GoldException("242", "No body found in the reply\nEnvelope should have a Body element");
      }

      // Fail if there are no responses
      Iterator respItr = body.getChildren("Response").iterator();
      if (respItr.hasNext())
      {
        extResponse = (Element)respItr.next();
      }
      else
      {
        log.error("No responses found in the reply body\nBody should have at least one child Response");
        throw new GoldException("244", "No responses found in the reply body\nBody should have at least one child Response");
      }

      // Set chunkNum if present
      String chunkNumString = extResponse.getAttributeValue("chunkNum");
      if (chunkNumString != null)
      {
        int chunkNum = Integer.parseInt(chunkNumString);
        intResponse.setChunkNum(chunkNum);
      }

      // Set chunkMax if present
      String chunkMaxString = extResponse.getAttributeValue("chunkMax");
      if (chunkMaxString != null)
      {
        int chunkMax = Integer.parseInt(chunkMaxString);
        intResponse.setChunkMax(chunkMax);
      }

      // Fail if status is absent
      Element status = extResponse.getChild("Status");
      if (status == null)
      {
        log.error("Status not specified in response");
        throw new GoldException("322", "Status not specified in response");
      }

      // Fail if return code is absent
      Element code = status.getChild("Code");
      if (code == null)
      {
        log.error("Return code not specified in response");
        throw new GoldException("322", "Return code not specified in response");
      }
      intResponse.setCode(code.getText());

      // Set status
      Element value = status.getChild("Value");
      if (value != null)
      {
        intResponse.setStatus(value.getText());
      }
      else if (code.getText().equals("000"))
      {
        intResponse.setStatus("Success");
      }
      else
      {
        intResponse.setStatus("Failure");
      }

      // Set message if existent
      Element message = status.getChild("Message");
      if (message != null)
      {
        intResponse.setMessage(message.getText());
      }

      // Set count if existent
      Element count = extResponse.getChild("Count");
      if (count != null)
      {
        intResponse.setCount(Integer.parseInt(count.getText()));
      }

      // Set data if existent
      Element extData = extResponse.getChild("Data");
      if (extData != null)
      {
        Element intData = (Element)extData.clone();
        intData.setNamespace(null);
        Iterator objItr = intData.getChildren().iterator();
        while (objItr.hasNext())
        {
          Element objNode = (Element)objItr.next();
          Iterator attrItr = objNode.getChildren().iterator();
          while (attrItr.hasNext())
          {
            Element attrNode = (Element)attrItr.next();
            if (attrNode.getName().endsWith("Time"))
            {
              String dateTime = attrNode.getText();
              dateTime = toHRT(dateTime);
              attrNode.setText(dateTime);
            }
          }
        }
        intResponse.setDataElement(intData);
      }

      // Link the chunk to the response
      chunk.setResponse(intResponse);

      return chunk;
    }
    catch (GoldException ge)
    {
      log.error(ge.toString());
      throw ge;
    }
    
  }

  // To Human Readable Time
  // Converts from epoch time to Human readable time format
  public static String toHRT(String epoch)
  {
    if (epoch.equals("0"))
    {
      return "-infinity";
    }
    else if (epoch.equals("2147483647"))
    {
      return "infinity";
    }
    else
    {
      try
      {
        long seconds = Long.parseLong(epoch);
        java.util.Date date = new java.util.Date(seconds * 1000);
        java.text.SimpleDateFormat format = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        StringBuffer dateTime = format.format(date, new StringBuffer(), new java.text.FieldPosition(0));
        return String.valueOf(dateTime);
      }
      catch (NumberFormatException nfe)
      {
        return epoch;
      }
    }
  }

} // end class Reply

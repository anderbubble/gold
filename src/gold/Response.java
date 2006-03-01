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
import java.io.*;

import org.jdom.*;

import org.apache.log4j.*;

import gold.*;

public class Response implements Constants , Cloneable
{
  private static List _pool = new LinkedList();

  // Response instance variables
  private String _actor = System.getProperty("user.name");
  private String _status = "Unknown";
  private String _code = "999";
  private String _message = new String();
  private int _count = -1;
  private LinkedList _data = new LinkedList(); // A List of Data
  private int _chunkNum = 1; // An integer
  private int _chunkMax = 0; // An integer

  static Logger log = Logger.getLogger(gold.Response.class);

  // Constructors

  // Empty Constructor
  public Response()
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }
  }

  // Override inherited clone() to make it public
  public java.lang.Object clone() throws CloneNotSupportedException
  {
    return super.clone();
  }

  // Accessors

  // Get response actor
  public String getActor()
  {
    return _actor;
  }

  // Get response status
  public String getStatus()
  {
    return _status;
  }

  // Get response return code
  public String getCode()
  {
    return _code;
  }

  // Get response message
  public String getMessage()
  {
    return _message;
  }

  // Get response count
  public int getCount()
  {
    return _count;
  }

  // Get response data (list of data)
  public LinkedList getData()
  {
    return new LinkedList(_data);
  }

  // Get response data vector
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

  // Determine whether this is the first chunk
  public int getChunkNum()
  {
    return _chunkNum;
  }

  // Determine whether more chunks are forthcoming
  public int getChunkMax()
  {
    return _chunkMax;
  }

  public String toString()
  {
    String data = (String)null;
    Vector v = new Vector();
    v.add(_status);
    v.add(_code);
    v.add(_message);
    v.add(String.valueOf(_count));
    v.add(_data);
    return v.toString();
  }

  // Mutators

  // Set response actor
  public void setActor(String actor)
  {
    _actor = actor;
  }

  // Set response status
  public void setStatus(String status)
  {
    _status = status;
  }

  // Set response return code
  public void setCode(String code)
  {
    _code = code;
  }

  // Set response message
  public void setMessage(String message)
  {
    _message = message;
  }

  // Set response count
  public void setCount(int count)
  {
    _count = count;
  }

  // Set response data (list of Datum)
  public void setData(LinkedList data)
  {
    _data = new LinkedList(data);
  }

  // Set response data element
  public void setDataElement(Element data)
  {
    Iterator dataItr = data.getChildren().iterator();
    while (dataItr.hasNext())
    {
      _data.add(new Datum((Element)dataItr.next()));
    }
  }

  // Add a response datum
  public void setDatum(Datum datum)
  {
    _data.add(datum);
  }

  // Set chunk number
  public void setChunkNum(int chunkNum)
  {
    _chunkNum = chunkNum;
  }

  // Increment chunk number
  public void incChunkNum()
  {
    _chunkNum++;
  }

  // Set chunk maximum
  public void setChunkMax(int chunkMax)
  {
    _chunkMax = chunkMax;
  }

  // Prepare failure response
  public Response failure(String code, String message)
  {
    setStatus("Failure");
    setCode(code);
    setCount(-1);
    setMessage(message);
    return this;
  }

  // Prepare failure response
  public Response failure(String message)
  {
    return failure("999", message);
  }

  // Prepare failure response
  public Response failure(GoldException ge)
  {
    String code = ge.getCode();
    String message = ge.getMessage();
    if (code != null)
    {
      return failure(code, message);
    }
    else if (message != null)
    {
      return failure(message);
    }
    else
    {
      return failure("Internal error encountered: " + ge.toString());
    }
  }

  // Prepare successful response for Create, Modify and Delete Requests
  public Response success(int count, String message)
  {
    setStatus("Success");
    setCode("000");
    setMessage(message);
    setCount(count);
    return this;
  }

  // Prepare successful response for non-count Requests
  public Response success(String message)
  {
    setStatus("Success");
    setCode("000");
    setMessage(message);
    return this;
  }

  // Prepare successful response for Query Requests
  public Response success(int count, Element data)
  {
    return success(count, data, null);
  }

  // Prepare successful general response
  public Response success(int count, Element data, String message)
  {
    setStatus("Success");
    setCode("000");
    setCount(count);
    setDataElement(data);
    setMessage(message);
    return this;
  }

} // end class Response

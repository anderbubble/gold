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

import java.io.*;
import java.text.*;
import java.util.*;
import java.util.regex.*;

import org.jdom.input.SAXBuilder;
import org.jdom.Document;
import org.jdom.Element;

import org.apache.log4j.*;

import gold.*;

public class GoldClient implements Constants
{
  static Logger log = Logger.getLogger(GoldClient.class);

  public static void main(String[] argv)
  {
    String args = new String();

    // Initialize Gold (read config files)
    try
    {
      Gold.initialize();
    }
    catch (GoldException ge)
    {
      System.err.println("Failure detected during Gold initialization: (" + ge.getCode() + ") " + ge.getMessage());
      return;
    }

    // Log client invocation
    if (log.isInfoEnabled())
    {
      log.info("invoked with arguments: (" + Arrays.asList(argv) + ")");
    }

    // Parse Command Line Arguments
    if (! parseArgs(argv))
    {
      System.err.println(_usage);
      return;
    }

    // Use command line command if provided
    if (_command != null)
    {
      // Process command and display results
      handleCommand(_command);
      return;
    }

    // otherwise read from STDIN
    else
    {
      BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
      
      // Display prompt
      System.out.print("gold> ");

      try
      {
        while ((_command = in.readLine()) != null)
        {
          // Trim leading and trailing whitespace
          _command = _command.trim();

          // Allow the user to quit the interactive shell
          if (_command.equals("quit"))
          {
            return;
          }

          // Process command and display results
          handleCommand(_command);

          System.out.print("gold> ");
        }
      }
      catch (IOException e)
      {
        System.err.println(e);
      }
    }

  } // End main

  // Parse Command Line Arguments
  private static boolean parseArgs(String[] argv)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + Arrays.asList(argv) + ")");
    }

    for (int ai = 0; ai < argv.length; ai++)
    {
      if (argv[ai].startsWith("-"))
      {
        flags:
        for (int oi = 1; oi < argv[ai].length(); oi++)
        {
          char c = argv[ai].charAt(oi);
          switch(c)
          {
            // Help
            case 'h':
              return false;
          
            // Debug
            case 'd':
              ConsoleAppender screen = (ConsoleAppender)Logger.getRoot().getAppender("Screen");
              if (screen == null)
              {
                log.addAppender(new ConsoleAppender(new PatternLayout("%d{yyyy-MM-dd HH:mm:ss.SSS} %-5p %C.%M [%F:%L]  %m%n")));
              }
              else
              {
                log.setLevel(Level.DEBUG);
                screen.setThreshold(Level.DEBUG);
              }
              break;
          
            // Verbose
            case 'v':
              _verbose = true;
              break;

            // Quiet
            case 'q':
              _verbose = false;
              break;

            // Raw
            case 'r':
              _raw = true;
              break;

            default:
              System.err.println("Invalid option: -" + c);
              return false;

          } // end switch
        }
      }
      else
      {
        _command = argv[ai];
        for (ai++; ai < argv.length; ai++)
        {
          _command += " " + argv[ai];
        }
      }
      
    }
    
    return true;

  } // end parseArgs


  // Build the Request from the command, then obtain and display the Response
  private static void handleCommand(String _command)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + _command + ")");
    }

    Request request;
    Response response;

    try
    {
      request = buildRequest(_command);
      if (request == null) { return; }
      if (log.isInfoEnabled())
      {
        log.info("sending request: (" + request.toString() + ")");
      }
      //response = request.getResponse();

      //Message message = new Message(Gold.TOKEN_PASSWORD, "scottmo", "4fruit");
      Chunk messageChunk = new Chunk(Gold.TOKEN_SYMMETRIC,null,Gold.AUTH_KEY);
      messageChunk.setRequest(request);
      Message message = new Message();
      message.sendChunk(messageChunk);
      Reply reply = message.getReply();
      while (true)
      {
        Chunk replyChunk = reply.receiveChunk();
        response = replyChunk.getResponse();

        if (log.isInfoEnabled())
        {
          log.info("received response chunk: (" + response.toString() + ")");
        }

        displayResponse(response);
        int chunkNum = response.getChunkNum();
        int chunkMax = response.getChunkMax();
        if (chunkMax != -1 && chunkNum >= chunkMax)
        {
          break;
        }
      }
    }
    catch (GoldException ge)
    {
      response = new Response().failure(ge);
      displayResponse(response);
    }
    catch (Exception e)
    {
      response = new Response().failure(new GoldException("820", e.getMessage()));
      displayResponse(response);
    }
  } // end handleCommand


  // Build Request from Command String
  private static Request buildRequest(String _command) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + _command + ")");
    }

    Pattern pattern;
    Matcher matcher;
    boolean found;
    int index = 0;
    String object;
    String action;
    String name;
    String value;
    String op;
    String conj;
    String groupString;
    int group;
    
     // Strip off trailing comments
     pattern = Pattern.compile("([^#\\\"]+|\\\"[^\\\"]*\\\")*");
     matcher = pattern.matcher(_command);
     found = matcher.find(index);
     if (found)
     {
       _command = matcher.group();
     }

    // Return null if command string is empty
    if (_command.equals(""))
    {
      return (Request)null;
    }

    // Instantiate request
    Request request = new Request();

    // Add actor to Request
    String actor = System.getProperty("ACTOR", "nobody");
    request.setActor(actor);
    
    // Peel off leading whitespace
    pattern = Pattern.compile("\\s+");
    matcher = pattern.matcher(_command);
    found = matcher.find(index);
    if (found && matcher.start() == index)
    {
      index = matcher.end();
    }
      
    // Peel off object
    pattern = Pattern.compile("[\\w,]+");
    matcher = pattern.matcher(_command);
    found = matcher.find(index);
    if (found && matcher.start() == index)
    {
      index = matcher.end();
      object = matcher.group();

      // Add object to Request
      if (log.isDebugEnabled())
      {
        log.debug("adding object (" + object + ") to request");
      }
      request.setObject(object);

      // And peel off trailing whitespace
      pattern = Pattern.compile("\\s+");
      matcher = pattern.matcher(_command);
      found = matcher.find(index);
      if (found && matcher.start() == index)
      {
        index = matcher.end();
      }
    }
    else // No object found
    {
      throw new GoldException("311", "The request object was not specified\n" + _command_form);
    }
      
    // Peel off action
    //pattern = Pattern.compile("((\\w+)?::)?\\w+");
    pattern = Pattern.compile("(::)?\\w+");
    matcher = pattern.matcher(_command);
    found = matcher.find(index);
    if (found && matcher.start() == index)
    {
      index = matcher.end();
      action = matcher.group();

      // Add action to Request
      if (log.isDebugEnabled())
      {
        log.debug("adding action ("+ action + ") to request");
      }
      request.setAction(action);

      // And peel off trailing whitespace
      pattern = Pattern.compile("\\s+");
      matcher = pattern.matcher(_command);
      found = matcher.find(index);
      if (found && matcher.start() == index)
      {
        index = matcher.end();
      }
    }
    else // No action found
    {
      throw new GoldException("312", "The request action was not specified\n" + _command_form);
    }
      
    // Process the remaining options
    while (true)
    {

      // Are we at the end?
      if (index == _command.length()) { break; }

      group = 0;
      groupString = "";
      value = "";

      // Peel off conjunction
      pattern = Pattern.compile("[|&][|&!]");
      matcher = pattern.matcher(_command);
      found = matcher.find(index);
      if (found && matcher.start() == index)
      {
        index = matcher.end();
        String tokConj = matcher.group();

        if (tokConj.equals("&&"))
        { conj = "And"; }
        else if (tokConj.equals("||"))
        { conj = "Or"; }
        else if (tokConj.equals("&!"))
        { conj = "AndNot"; }
        else if (tokConj.equals("|!"))
        { conj = "OrNot"; }
        else
        {
          throw new GoldException("310", "Invalid conjunction: (" + tokConj + ")\n" + _command_form);
        }

        // Peel off any whitespace after conjunction
        pattern = Pattern.compile("\\s+");
        matcher = pattern.matcher(_command);
        found = matcher.find(index);
        if (found && matcher.start() == index)
        {
          index = matcher.end();
        }
      }
      else
      {
        conj="";
      }

      // Peel off grouping
      pattern = Pattern.compile("\\(+");
      matcher = pattern.matcher(_command);
      found = matcher.find(index);
      if (found && matcher.start() == index)
      {
        index = matcher.end();
        group += matcher.group().length();

        // Peel off any whitespace after grouping
        pattern = Pattern.compile("\\s+");
        matcher = pattern.matcher(_command);
        found = matcher.find(index);
        if (found && matcher.start() == index)
        {
          index = matcher.end();
        }
      }

      // Peel off the name
      pattern = Pattern.compile("[\\w\\.]+");
      matcher = pattern.matcher(_command);
      found = matcher.find(index);
      if (found && matcher.start() == index)
      {
        index = matcher.end();
        name = matcher.group();

        // Peel off any whitespace after name
        pattern = Pattern.compile("\\s+");
        matcher = pattern.matcher(_command);
        found = matcher.find(index);
        if (found && matcher.start() == index)
        {
          index = matcher.end();
        }
      }
      else
      {
        pattern = Pattern.compile("\\S+");
        matcher = pattern.matcher(_command);
        found = matcher.find(index);
        throw new GoldException("317", "Invalid option name: (" + matcher.group() + ")\n" + _command_form);
      }

      // Peel off operator
      pattern = Pattern.compile(":!|[-+=<>!~:]=?");
      matcher = pattern.matcher(_command);
      found = matcher.find(index);
      if (found && matcher.start() == index)
      {
        index = matcher.end();
        String tokOp = matcher.group();

        if (tokOp.equals("="))
        { op = "Assign"; }
        else if (tokOp.equals("=="))
        { op = "EQ"; }
        else if (tokOp.equals(">"))
        { op = "GT"; }
        else if (tokOp.equals("<"))
        { op = "LT"; }
        else if (tokOp.equals(">="))
        { op = "GE"; }
        else if (tokOp.equals("<="))
        { op = "LE"; }
        else if (tokOp.equals("!="))
        { op = "NE"; }
        else if (tokOp.equals("~"))
        { op = "Match"; }
        else if (tokOp.equals("+="))
        { op = "Inc"; }
        else if (tokOp.equals("-="))
        { op = "Dec"; }
        else if (tokOp.equals(":="))
        { op = "Option"; }
        else if (tokOp.equals(":!"))
        { op = "NotOption"; }
        else
        {
          throw new GoldException("310", "Invalid operator: (" + tokOp + ")\n" + _command_form);
        }

        // Peel off any whitespace after operator
        pattern = Pattern.compile("\\s+");
        matcher = pattern.matcher(_command);
        found = matcher.find(index);
        if (found && matcher.start() == index)
        {
          index = matcher.end();
        }

        // Only peel off value if operator found
        pattern = Pattern.compile("([\\w\\.,]+)|\\\"([ !#-~\\(\\)]*)\\\"");
        matcher = pattern.matcher(_command);
        found = matcher.find(index);
        if (found && matcher.start() == index)
        {
          index = matcher.end();
          if (matcher.group(1) != null) { value = matcher.group(1); }
          else { value = matcher.group(2); }
  
            // Peel off any whitespace after value
            pattern = Pattern.compile("\\s+");
            matcher = pattern.matcher(_command);
            found = matcher.find(index);
            if (found && matcher.start() == index)
            {
              index = matcher.end();
            }
          }
          else
          {
          pattern = Pattern.compile(".*");
          matcher = pattern.matcher(_command);
          found = matcher.find(index);
          throw new GoldException("317", "Invalid value: (" + matcher.group() + ")\n" + _command_form);
         }

      }
      else
      {
        op="";
      }

      // Peel off ungrouping
      pattern = Pattern.compile("\\)+");
      matcher = pattern.matcher(_command);
      found = matcher.find(index);
      if (found && matcher.start() == index)
      {
        index = matcher.end();
        group -= matcher.group().length();

        // Peel off any whitespace after grouping
        pattern = Pattern.compile("\\s+");
        matcher = pattern.matcher(_command);
        found = matcher.find(index);
        if (found && matcher.start() == index)
        {
          index = matcher.end();
        }
      }

      // Convert group to string
      if (group < 0)
      {
        groupString = String.valueOf(group);
      }
      else if (group > 0)
      {
        groupString = "+" + String.valueOf(group);
      }

      // Update request object with option
      if (op.equals("Option") || op.equals("NotOption"))
      {
        // If this is a selection parameter
        if  (name.equals("Show"))
        {
          StringTokenizer selectionTok = new StringTokenizer(value, ",");
          while (selectionTok.hasMoreTokens())
          {
            String selection = selectionTok.nextToken();
            String selectionName = null;
            String selectionOp = null;
            int selectionIndex = 0;
            Matcher selectionMatcher;
            Pattern selectionPattern;

            // Break out operator and selection
              selectionPattern = Pattern.compile("([\\w\\.]+$)|(\\w+)\\(([\\w\\.]+)\\)");
            selectionMatcher = selectionPattern.matcher(selection);
            found = selectionMatcher.find(selectionIndex);
              if (found && selectionMatcher.start() == selectionIndex)
              {
               selectionIndex = selectionMatcher.end();
              if (selectionMatcher.group(1) != null)
              {
                selectionName = selectionMatcher.group(1);
              }
              else if (selectionMatcher.group(2) != null && selectionMatcher.group(3) != null)
              {
                selectionOp = selectionMatcher.group(2);
                selectionName = selectionMatcher.group(3);
              }
              else
              {
                throw new GoldException("317", "Invalid selection: (" + selectionMatcher.group() + ")\n" + _command_form);
              }
              // Add the Selection
              if (log.isDebugEnabled())
              {
                log.debug("adding selection (" + selection + ") to request");
              }
              request.setSelection(selectionName, selectionOp);
              }
          }
        }

        // Update request object with data
        else if (name.equals("Data"))
        {
            try
            {
              SAXBuilder builder = new SAXBuilder();
              Document doc = builder.build(new StringReader("<Data>" + value + "</Data>"));
              Element data = doc.getRootElement();
              request.setDataElement(data);
            }
            catch (Exception e)
            {
              System.err.println("Cannot convert data to XML: " + e);
            }
        }
        
        else if (op.equals("NotOption"))
        {
          if (log.isDebugEnabled())
          {
            log.debug("adding option (" + name + ", " + value + ", not) to request");
          }
           request.setOption(name, value, "Not");
        }
        else
        {
          if (log.isDebugEnabled())
          {
            log.debug("adding option (" + name + ", " + value + ") to request");
          }
           request.setOption(name, value);
        }
      }
        
      // Update request object with assignment
      else if (op.equals("Assign") || op.equals("Inc") ||  op.equals("Dec"))
      {
        if (log.isDebugEnabled())
        {
          log.debug("adding assignment (" + name + ", " + value + ") to request");
        }
         request.setAssignment(name, value, op);
      }
        
      // Update request object with condition
      else
      {
        if (log.isDebugEnabled())
        {
          log.debug("adding condition (" + name + ", " + op + ", " + value + ", " + conj + ", " + groupString + ") to request");
        }
         request.setCondition(name, value, op, conj, groupString);
      }

    } // end while

    return request;

  } // end buildRequest


  // Display response
  private static void displayResponse(Response response)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + response + ")");
    }
    int col;

    // Check for failure
    if (response.getStatus().equals("Failure"))
    {
      System.err.println("Command Failed with return code: " + response.getCode());
      System.err.println("Message: " + response.getMessage());
      return;
    }

    int chunkNum = response.getChunkNum();
    int chunkMax = response.getChunkMax();
    Element data = response.getDataElement();

    // For cooked mode, build metadata construct and print column labels
    if (! _raw && chunkNum == 1 && data != null)
    {
      Iterator dataItr = data.getChildren().iterator();
      if (dataItr.hasNext())
      {
        col = 0;
        Element row = (Element)dataItr.next();
        Iterator rowItr = row.getChildren().iterator();
        while (rowItr.hasNext())
        {
          col++;
          Element column = (Element)rowItr.next();
      //    if (col+1 > _metadata.size())
      //    {
      //      _metadata.insertElementAt(new HashMap(), col);
      //    }
      //    if (((HashMap)_metadata.elementAt(col)).get("type") == null)
      //    {
      //      ((HashMap)_metadata.elementAt(col)).put("type","varchar");
      //    }
      //    if (((HashMap)_metadata.elementAt(col)).get("width") == null)
      //    {
      //      ((HashMap)_metadata.elementAt(col)).put("width","20");
      //    }
      //    if (((HashMap)_metadata.elementAt(col)).get("name") == null)
      //    {
      //      ((HashMap)_metadata.elementAt(col)).put("name","field" + (col+1));
      //    }
          prettyPrint(col-1, column.getName());
        }
        System.out.println();
      }

      // Print dividers
      dataItr = data.getChildren().iterator();
      if (dataItr.hasNext())
      {
        col = -1;
        Element row = (Element)dataItr.next();
        Iterator rowItr = row.getChildren().iterator();
        while (rowItr.hasNext())
        {
          rowItr.next();
          col++;
          prettyPrint(col, "----------------------------------------------------------------------------------------------------");
        }
        System.out.println();
      }
    }

    boolean newline = false;
    if (data != null)
    {
      Iterator dataItr = data.getChildren().iterator();
      // Display data
      while (dataItr.hasNext())
      {
        if (! _raw && (chunkNum == chunkMax || chunkMax == 0))
        {
          newline = true;
        }
        col = -1;
        Element row = (Element)dataItr.next();
        Iterator rowItr = row.getChildren().iterator();
        while (rowItr.hasNext())
        {
          col++;
          Element column = (Element)rowItr.next();
          String value = column.getText();

          // Convert time to human readable format
          if (value.indexOf("Time") != -1)
          {
            try
            {
              long epoch = Long.parseLong(value);         
              if (epoch == 0)                       
              {
                value = "-infinity";
              }
              else if (epoch == 2147483647)
              {
                value = "infinity";
              }                                         
              else
              {
                java.util.Date date = new java.util.Date(epoch * 1000);
                value = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(date);
              }
            }
            catch (NumberFormatException nfe)
            {
              // Pass it through -- perhaps it is already in HRT
            }
          }

          if (_raw)
          {
            if (col > 0)
            {
              System.out.print(";");
            }
            System.out.print(value);
          }
          else
          {
            prettyPrint(col, value);
          }
        }
        System.out.println();
      }
      if (newline || _raw)
      {
        System.out.println();
        newline = false;
      }
  
    }  // end if data exists
  
    if (_verbose)
    {
      if (newline)
      {
        System.out.println();
      }

//      // Display count if included
//      int count = response.getCount();
//      if (count > -1)
//      {
//        System.out.println("Count: " + count);
//      }
  
      // Display message if included
      String message = response.getMessage();
      if (! message.equals(""))
      {
        System.out.println("Message: " + response.getMessage());
      }
    } // end if verbose
    if (response.getStatus().equals("Warning"))
    {
      System.err.println("Warning (" + response.getCode() + "): " + response.getMessage());
    }
  } // end displayResponse


  // Pretty Print
  // Later should use metadata to format width etc.
  private static void prettyPrint(int col, String printString)
  {
    StringBuffer buf = new StringBuffer(printString);

    // Add space between columns
    if (col > 0)
    {
      System.out.print(" ");
    }

    // Determine desired field width
    //int width = Integer.parseInt((String)((HashMap)_metadata.elementAt(col)).get("width"));
    int width = 20;

    // Truncate printString if needed
    if (buf.length() > width)
    {
      buf.setLength(width);
    }

    // Create blank pad
    StringBuffer blanks = new StringBuffer();
    for (int i = 0; i < width - buf.length(); i++)
    {
      blanks.append(" ");
    }

    // Prepend or append blanks for right or left justification and print
    //if (((String)((HashMap)_metadata.elementAt(col)).get("type")).indexOf("int") != -1)
    //{
    //  System.out.print(blanks.toString() + buf.toString());
    //}
    //else
    //{
      System.out.print(buf.toString() + blanks.toString());
    //}
  
  }


  private static String _command = null;
  private static boolean _raw = false;
  private static boolean _verbose = false;
  private static int _width = 20;
  private static Vector _metadata = new Vector();
  private static final String _command_form = "Command must be of the form: <object> <action> [[<conj>][(*]<keyword>[<op><value>][)*]]*";
  private static final String _usage = "Usage: gold [-dhqrv] [command]";
}


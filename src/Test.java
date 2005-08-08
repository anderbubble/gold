import java.io.*;
import java.util.*;
import java.text.*;

public class Test {

public static void main(String [] args) throws Exception
{
  String epoch;
  
  epoch = "0";
  System.out.println(epoch + " => " + toHRT(epoch));
  epoch = "2147483647";
  System.out.println(epoch + " => " + toHRT(epoch));
  epoch = "1107220248";
  System.out.println(epoch + " => " + toHRT(epoch));
  epoch = "1107158400";
  System.out.println(epoch + " => " + toHRT(epoch));
  epoch = "Goober squats";
  System.out.println(epoch + " => " + toHRT(epoch));

//  String dateTime;

//  dateTime = "-infinity";
//  System.out.println(dateTime + " => " + toMFT(dateTime));
//  dateTime = "infinity";
//  System.out.println(dateTime + " => " + toMFT(dateTime));
//  dateTime = "now";
//  System.out.println(dateTime + " => " + toMFT(dateTime));
//  dateTime = "2005-01-31 17:10:48";
//  System.out.println(dateTime + " => " + toMFT(dateTime));
//  dateTime = "2005-01-31";
//  System.out.println(dateTime + " => " + toMFT(dateTime));
//  dateTime = "2005-01-31 zoohicky";
//  System.out.println(dateTime + " => " + toMFT(dateTime));
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
        Date date = new Date(seconds * 1000);
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        StringBuffer dateTime = format.format(date, new StringBuffer(), new FieldPosition(0));
        return String.valueOf(dateTime);
      }
      catch (NumberFormatException nfe)
      {
        return epoch;
      }
    }
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
    Date date;
    SimpleDateFormat format;

    format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    date = format.parse(dateTime, new ParsePosition(0));
    if (date != null)
    {
      return String.valueOf(date.getTime() / 1000);
    }
    format = new SimpleDateFormat("yyyy-MM-dd");
    date = format.parse(dateTime, new ParsePosition(0));
    if (date != null)
    {
      return String.valueOf(date.getTime() / 1000);
    }
    return dateTime;
  }
}

}


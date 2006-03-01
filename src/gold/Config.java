/******************************************************************************
 *                                                                            *
 *                             Copyright (c) 2003                             *
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

import java.io.*;
import java.util.Properties;

import gold.Constants;

public class Config implements Constants
{

	private static Properties properties = new Properties();

	// Assume reading standard client config if unspecified
	public static boolean readConfig()
	{
		return readConfig(System.getProperty("GOLD_HOME") + "/etc/gold.conf");
	}

	// Read and Parse Config File Parameters
	public static boolean readConfig(String fileName)
	{
		try
    {
      FileInputStream fis = new FileInputStream(fileName);
			properties.load(fis);

			return true;
    }
    catch (IOException e)
    {
			System.err.println("Error reading config file: " + e);
    }
		return false;
	}

	// Write Properties to specified file
	public static boolean writeConfig(String fileName)
	{
		try
    {
			FileOutputStream fos = new FileOutputStream(fileName);
			properties.store(fos, "Gold Config File");

			return true;
    }
    catch (IOException e)
    {
			System.err.println("Error writing config file: " + e);
    }
		return false;
	}

	// Get Property
	public static String getProperty(String key)
	{
		return properties.getProperty(key);
	}

	// Get Config Property or its default
	public static String getProperty(String key, String defaultkey)
	{
		return properties.getProperty(key, defaultkey);
	}

	// Set Config Property
	public static String setProperty(String key, String value)
	{
		return (String)properties.setProperty(key, value);
	}

}

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

public interface Constants
{

	// Shared Constants

  /** Server Host */
  public static final String SERVER_HOST = "localhost";

	/** Server Port */
  public static final String SERVER_PORT = "7112";

	/** Use Service Directory ? */
  public static final String SERVICE_DIRECTORY = "false";

	/** Service Directory Host */
  public static final String SERVICE_DIRECTORY_HOST = "localhost";

	/** Service Directory Port */
  public static final String SERVICE_DIRECTORY_PORT = "7000";

	/** Response Chunking */
  public static final String RESPONSE_CHUNKING = "true";

	/** Response ChunkSize */
  public static final String RESPONSE_CHUNKSIZE = "1000";

  /** Super User */
  public static final String SUPER_USER = "gold";

	/** Whether authentication is performed by default */
	public static final String SECURITY_AUTHENTICATION = "true";

	/** Whether encryption is performed by default */
	public static final String SECURITY_ENCRYPTION = "false";

	/** Symmetric Security Token Type */
	public static final String TOKEN_SYMMETRIC = "Symmetric";

	/** Asymmetric Security Token Type */
	public static final String TOKEN_ASYMMETRIC = "Asymmetric";

	/** Known Password Security Token Type */
	public static final String TOKEN_PASSWORD = "Password";

	/** ClearText Password Security Token Type */
	public static final String TOKEN_CLEARTEXT = "Cleartext";

	/** Kerberos Security Token Type */
	public static final String TOKEN_KERBEROS = "Kerberos5";

	/** GSI Security Token Type */
	public static final String TOKEN_GSI = "X509v3";

	/** JDBC Driver */
	public static final String DB_DRIVER = "org.postgresql.Driver";

	/** JDBC Datasource */
	public static final String DB_DATASOURCE = "jdbc:postgresql:gold";
}

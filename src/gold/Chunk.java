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
import java.io.*;
import java.net.*;
import java.security.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import java.util.zip.*;

import org.jdom.*;
import org.jdom.input.SAXBuilder;

import org.apache.log4j.*;

import gold.*;

public class Chunk implements Constants, Cloneable
{
  private String _tokenType = Gold.TOKEN_SYMMETRIC;
  private String _tokenName;
  private String _tokenValue;
  private Request _request;
  private Response _response;
  private boolean _authentication = false;
  private boolean _encryption = false;
  
  static Logger log = Logger.getLogger(gold.Chunk.class);
  
  // Empty Constructor
  public Chunk()
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    // Set authentication and encryption according to policy
    if (Boolean.valueOf(Config.getProperty("security.authentication", SECURITY_AUTHENTICATION)).booleanValue())
    {
      _authentication = true;
    }
    if (Boolean.valueOf(Config.getProperty("security.encryption", SECURITY_ENCRYPTION)).booleanValue())
    {
      _encryption = true;
    }
  }

  // Typed Constructor
  public Chunk(String tokenType, String tokenName, String tokenValue)
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (" + tokenType + ", " + tokenName + ", <tokenValue>)");
    }

    // Instantiate a new chunk
    _tokenType = tokenType;
    _tokenName = tokenName;
    _tokenValue = tokenValue;

    // Set authentication and encryption according to policy
    if (Boolean.valueOf(Config.getProperty("security.authentication", SECURITY_AUTHENTICATION)).booleanValue())
    {
      _authentication = true;
    }
    if (Boolean.valueOf(Config.getProperty("security.encryption", SECURITY_ENCRYPTION)).booleanValue())
    {
      _encryption = true;
    }
  }

  // Override inherited clone() to make it public
  public java.lang.Object clone() throws CloneNotSupportedException
  {  
    return super.clone();
  }

  // Get the request
  public Request getRequest()
  {
    return _request;
  }

  // Get the response
  public Response getResponse()
  {
    return _response;
  }

  // Get the token type
  public String getTokenType()
  {
    return _tokenType;
  }

  // Get authentication value
  public boolean getAuthentication()
  {
    return _authentication;
  }

  // Get encryption value
  public boolean getEncryption()
  {
    return _encryption;
  }

  // Set the request
  public Chunk setRequest(Request request)
  {
    _request = request;
    return this;
  }

  // Set the response
  public Chunk setResponse(Response response)
  {
    _response = response;
    return this;
  }

  // Set the tokenType
  public void setTokenType(String tokenType)
  {   
    _tokenType = tokenType; 
  }

  // Set authentication value
  public void setAuthentication(boolean authentication)
  {   
    _authentication = authentication; 
  }

  // Set encryption value
  public void setEncryption(boolean encryption)
  {   
    _encryption = encryption; 
  }

  // Serialize chunk to a printable string
  public String toString()
  {
    Vector v = new Vector();
    v.add(_tokenType);
    v.add(_tokenName);
    v.add("<tokenValue>");
    v.add(_request);
    v.add(_response);
    v.add(String.valueOf(_authentication));
    v.add(String.valueOf(_encryption));
    return v.toString();
  }


  // Sign the chunk
  public void sign(Document doc) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (<envelope>)");
    }

    // Step 1)  Check the security token

    // Unknown token type
    if (_tokenType.equals(Gold.TOKEN_SYMMETRIC))
    {
      if (_tokenValue == null)
      {
        _tokenValue = Gold.AUTH_KEY;
      }
    }
    else if (_tokenType.equals(Gold.TOKEN_PASSWORD))
    {
      if (_tokenName == null)
      {
        _tokenName = _request.getActor();
      }
    }
    else
    {
      log.error("Unsupported Security Token Type: " + _tokenType);
      throw new GoldException("422", "Unsupported Security Token Type: " + _tokenType);
    }

    if (_tokenValue.length() == 0)
    {
      log.error("Security Token cannot be zero length");
      throw new GoldException("422", "Security Token cannot be zero length");
    }
    if (log.isDebugEnabled())
    {
      log.debug("The security token type is: " + _tokenType);
      //log.debug("The security token value is: " + _tokenValue);
    }

    // Step 2)  Canonicalize the body into a String

    try
    {
      Element root = doc.getRootElement();
      Element body = root.getChild("Body");
      CanonicalXMLOutputter xmlout = new CanonicalXMLOutputter();
      String bodyText = xmlout.outputString(body);
      if (bodyText == null || bodyText.equals(""))
      {
        log.error("Message body cannot be empty");
        throw new GoldException("422", "Message body cannot be empty");
      }
      if (log.isDebugEnabled())
      {
        log.debug("The canonicalized body text is: " + bodyText);
      }
  
      // Step 3)  Perform the digest
  
      String digestString;
      byte[] digest;
      try
      {
        MessageDigest md = MessageDigest.getInstance("sha-1");
        md.update(bodyText.getBytes());
        digest = md.digest();
        digestString = Base64.encode(digest);
        if (log.isDebugEnabled())
        {
          log.debug("The base64-encoded message digest is: " + digestString);
        }
      }
      catch (Exception e)
      {
        log.error("Unable to create message digest: (" + e.getMessage() + ")");
        throw new GoldException("422", "Unable to create message digest: (" + e.getMessage() + ")");
      }
  
      // Step 4)  Generate MAC
      
      String macString;
      try
      {
        SecretKey key = new SecretKeySpec(_tokenValue.getBytes(), "HmacSHA1");
        Mac m = Mac.getInstance("HmacSHA1");
        m.init(key);
        m.update(digest);
        byte[] mac = m.doFinal();
        macString = Base64.encode(mac);
        if (log.isDebugEnabled())
        {
          log.debug("The base64-encoded MAC is: " + macString);
        }
      }
      catch (Exception e)
      {
        log.error("Unable to generate message MAC: (" + e.getMessage() + ")");
        throw new GoldException("422", "Unable to generate message MAC: (" + e.getMessage() + ")");
      }
  
      // Step 5)  Add Signature to chunk    
  
      Element signature = new Element("Signature");
      Element digestValue = new Element("DigestValue");
      digestValue.addContent(digestString);
      signature.addContent(digestValue);
      Element signatureValue = new Element("SignatureValue");
      signatureValue.addContent(macString);
      signature.addContent(signatureValue);
      Element securityToken = new Element("SecurityToken");
      securityToken.setAttribute("type", _tokenType);
      Element request = body.getChild("Request");
      if (_tokenName != null) { securityToken.setAttribute("name", _tokenName); }
      signature.addContent(securityToken);
      root.addContent(signature);
  //Log.logEntry(9, "The signature is: " + xmlout.outputString(signature));
    }
    catch (Exception e)
    {
      throw new GoldException("420", e.getMessage());
    }
  } // End sign


  // Encrypt the chunk
  public void encrypt(Document doc) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: (<envelope>)");
    }

    // Step 1)  Check the security token

    // Unknown token type
    if (! _tokenType.equals(Gold.TOKEN_SYMMETRIC) && ! _tokenType.equals(Gold.TOKEN_PASSWORD))
    {
      log.error("Unsupported Security Token Type: " + _tokenType);
      throw new GoldException("432", "Unsupported Security Token Type: " + _tokenType);
    }

    if (_tokenValue.length() == 0)
    {
      log.error("Security Token cannot be zero length");
      throw new GoldException("432", "Security Token cannot be zero length");
    }
    if (log.isDebugEnabled())
    {
      log.debug("The security token type is: " + _tokenType);
      //log.debug("The security token value is: " + _tokenValue);
    }

    // Step 2)  Generate 192-bit random session key (with 64-bit IV)

    try
    {
      //SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
      //byte randomBytes[] = new byte[24];
      //random.nextBytes(randomBytes);
      //SecretKey sessionKey = new SecretKeySpec(randomBytes, "DESede");
      KeyGenerator keygen = KeyGenerator.getInstance("DESede");
      SecretKey sessionKey = keygen.generateKey();
      if (log.isDebugEnabled())
      {
        log.debug("The base64-encoded session key is: " + Base64.encode(sessionKey.getEncoded()));
      }
      //byte[] iv = new byte[8];
      //random.nextBytes(iv);
  //Log.logEntry(9, "The base64-encoded IV is: " + Base64.encode(iv));
  
      // Step 3)  Encrypt the signature and body with the session key
  
      // Build the plaintext
      Element root = doc.getRootElement();
      CanonicalXMLOutputter xmlout = new CanonicalXMLOutputter();
      String plainText = new String();
      Element signature = root.getChild("Signature");
      if (signature != null)
      {
        plainText += xmlout.outputString(signature);
      }
      Element body = root.getChild("Body");
      if (body == null)
      {
        log.error("No message body found");
        throw new GoldException("436", "No message body found");
      }
      plainText += xmlout.outputString(body);
  //Log.logEntry(9, "The plaintext is: " + plainText);
  
      // Initialize the cipher and extract the IV
      Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
      //Security.addProvider(new org.mozilla.jss.JSSProvider());
      //Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
      cipher.init(Cipher.ENCRYPT_MODE, sessionKey);
      byte[] iv = cipher.getIV();
  //Log.logEntry(9, "The base64-encoded IV is: " + Base64.encode(iv));
  
      // Compress the plaintext
      byte[] uncompressedData = plainText.getBytes();
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      GZIPOutputStream zos = new GZIPOutputStream(baos);
      zos.write(uncompressedData);
      zos.flush();
      zos.finish();
      zos.close();
      byte[] compressedData = baos.toByteArray();
  
      // Encrypt and encode the CipherValue payload
      byte[] cipherPayload = new byte[8 + cipher.getOutputSize(compressedData.length)];
      byte[] cipherData = cipher.doFinal(compressedData);
      for (int i = 0; i < 8; i++) { cipherPayload[i] = iv[i]; }
      for (int i = 0; i < cipherData.length; i++) { cipherPayload[i+8] = cipherData[i]; }
      String cipherText = Base64.encode(cipherPayload);
      if (log.isDebugEnabled())
      {
        log.debug("The base64-encoded ciphertext is: " + cipherText);
      }
  
  //    // Reverse it to verify
  //    byte[] recoveredPayload = Base64.decode(cipherText);
  //    byte[] retrievedIv = new byte[8];
  //    for (int i = 0; i < 8; i++) { retrievedIv[i] = recoveredPayload[i]; }
  //    IvParameterSpec ivSpec = new IvParameterSpec(retrievedIv);
  //    byte[] retrievedCipherData = new byte[recoveredPayload.length-8];
  //    for (int i = 0; i < recoveredPayload.length-8; i++) { retrievedCipherData[i] = recoveredPayload[i+8]; }
  //    cipher.init(Cipher.DECRYPT_MODE, sessionKey, ivSpec);
  //    byte[] recoveredData = cipher.doFinal(retrievedCipherData);
  //
  //    ByteArrayInputStream bais = new ByteArrayInputStream(recoveredData);
  //    GZIPInputStream zis = new GZIPInputStream(bais);
  //    baos = new ByteArrayOutputStream();
  //    int c = -1;
  //    while ((c = zis.read()) != -1) {
  //    baos.write(c);
  //    }       
  //    baos.flush();
  //    byte[] recoveredUncompressedData = baos.toByteArray();
  //    String recoveredText = new String(recoveredUncompressedData);
  //Log.logEntry(9, "The recovered plaintext is: " + recoveredText);
  
      // Step 4)  Encrypt the session key with the security token
  
      // Pad the token
      byte[] paddedTokenBytes = new byte[24];
      byte[] tokenBytes = _tokenValue.getBytes();
      for (int i = 0; i < tokenBytes.length; i++)
      {
        paddedTokenBytes[i] = tokenBytes[i]; 
      }
  
      // Represent the key being wrapped (WK) as a 24 octet sequence
      // sessionKey is already in the correct format -- fix up key encryption key
      byte[] kek = new byte[24];
      for (int i = 0; i < paddedTokenBytes.length; i++) { kek[i] = paddedTokenBytes[i]; }
      for (int i = paddedTokenBytes.length; i < 24; i++) { kek[i] = 0; }
      SecretKey keyEncryptionKey = new SecretKeySpec(kek, "DESede");
  //Log.logEntry(9, "Token length is: " + _tokenValue.length());
  //Log.logEntry(9, "Token is: " + _tokenValue);
  //Log.logEntry(9, "Key Encryption Key length is: " + kek.length);
  //Log.logEntry(9, "Key Encryption Key is: " + Base64.encode(kek));
      byte[] wk = sessionKey.getEncoded();
  //Log.logEntry(9, "Session Key (WK) length is: " + wk.length);
  //Log.logEntry(9, "Session Key (WK) is: " + Base64.encode(wk));
  
      // Compute the CMS key checksum and call this CKS
      MessageDigest md = MessageDigest.getInstance("sha-1");
      md.update(wk);
      byte[] cks = md.digest();
  //Log.logEntry(9, "CKS is: " + Base64.encode(cks));
  //Log.logEntry(9, "CKS length is: " + cks.length);
  //for (int i = 0; i < 8; i++) { Log.logEntry(9, "CKS[" + i + "]=" + cks[i]); }
  
      // Let WKCKS = WK || CKS, where || is concatenation
      byte[] wkcks = new byte[32];
      for (int i = 0; i < 24; i++) { wkcks[i] = wk[i]; }
      for (int i = 0; i < 8; i++) { wkcks[24+i] = cks[i]; }
  //Log.logEntry(9, "WKCKS is: " + Base64.encode(wkcks));
  //Log.logEntry(9, "WKCKS length is: " + wkcks.length);
  
      // Encrypt WKCKS in CBC mode using KEK as the key and IV as iv -> TEMP1
      cipher = Cipher.getInstance("DESede/CBC/NoPadding");
      cipher.init(Cipher.ENCRYPT_MODE, keyEncryptionKey);
      iv = cipher.getIV();
      byte[] temp1 = cipher.doFinal(wkcks);
  //Log.logEntry(9, "TEMP1 is: " + Base64.encode(temp1));
  //Log.logEntry(9, "TEMP1 length is: " + temp1.length);
  
      // Let TEMP2 = IV || TEMP1
      byte[] temp2 = new byte[40];
      for (int i = 0; i < 8; i++) { temp2[i] = iv[i]; }
      for (int i = 0; i < 32; i++) { temp2[i+8] = temp1[i]; }
  //Log.logEntry(9, "TEMP2 is: " + Base64.encode(temp2));
  //Log.logEntry(9, "TEMP2 length is: " + temp2.length);
  
      // Reverse the order of the octets in TEMP2 and call the result TEMP3
      byte[] temp3 = new byte[40];
      for (int i = 0; i < 40; i++) { temp3[i] = temp2[39-i]; }
  //Log.logEntry(9, "TEMP3 is: " + Base64.encode(temp3));
  //Log.logEntry(9, "TEMP3 length is: " + temp3.length);
  
      // Encrypt TEMP3 in CBC mode using the KEK and an IV of 0x4adda22c79e82105
      byte[] funkyIv = {
        (byte) 0x4a, (byte) 0xdd, (byte) 0xa2, (byte) 0x2c,
        (byte) 0x79, (byte) 0xe8, (byte) 0x21, (byte) 0x05
      };
      IvParameterSpec ivSpec = new IvParameterSpec(funkyIv);
      cipher.init(Cipher.ENCRYPT_MODE, keyEncryptionKey, ivSpec);
      byte[] ek = cipher.doFinal(temp3);
  //Log.logEntry(9, "The encrypted key length is " + ek.length);
  
      String wrappedText = Base64.encode(ek);
      if (log.isDebugEnabled())
      {
        log.debug("The base64-encoded encrypted key is: " + wrappedText);
      }
  
      // Step 5)  Replace envelope contents with encrypted data
  
      root.removeChild("Signature");
      root.removeChild("Body");
  
      Element encryptedData = new Element("EncryptedData");
      Element encryptedKey = new Element("EncryptedKey");
      encryptedKey.addContent(wrappedText);
      encryptedData.addContent(encryptedKey);
      Element cipherValue = new Element("CipherValue");
      cipherValue.addContent(cipherText);
      encryptedData.addContent(cipherValue);
      Element securityToken = new Element("SecurityToken");
      securityToken.setAttribute("type", _tokenType);
      Element request = body.getChild("Request");
      String actor = request.getAttributeValue("actor");
      if (actor != null) { securityToken.setAttribute("name", actor); }
      encryptedData.addContent(securityToken);
      root.addContent(encryptedData);
  //Log.logEntry(9, "The encryped data is: " + xmlout.outputString(encryptedData));
    }
    catch (Exception e)
    {
      throw new GoldException("430", e.getMessage());
    }
  } // End encrypt


  // Decrypt the chunk  
  public void decrypt(Document doc) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    // Step 1)  Extract encrypted data from envelope

    try
    {
      Element root = doc.getRootElement();
      Element encryptedData = root.getChild("EncryptedData");
      if (encryptedData == null)
      {
        _encryption = false; 
        if (log.isDebugEnabled())
        {
          log.debug("Message not encrypted -- No encrypted data element found");
        }
        return;
      }
      else
      {
        _encryption = true; 
      }

      Element encryptedKey = encryptedData.getChild("EncryptedKey");
      if (encryptedKey == null)
      {
        log.error("No encrypted key found");
        throw new GoldException("434", "No encrypted key found");
      }
      String wrappedText = encryptedKey.getText();
      //if (log.isDebugEnabled())
      //{
      //  log.debug("The base64-encoded encrypted key is: " + wrappedText);
      //}

      Element cipherValue = encryptedData.getChild ("CipherValue");
      if (cipherValue == null)
      {
        log.error("No cipher value found");
        throw new GoldException("434", "No cipher value found");
      }
      String cipherText = cipherValue.getText();
      if (log.isDebugEnabled())
      {
        log.debug("The base64-encoded encrypted data is: " + cipherText);
      }

      // Step 2)  Obtain the security token
  
      Element securityToken = encryptedData.getChild("SecurityToken");
      if (securityToken != null)
      {
        _tokenType = securityToken.getAttributeValue("type");
      }
      else
      {
        _tokenType = Gold.TOKEN_SYMMETRIC;
      }
  
      // Symmetric Token
      if (_tokenType.equals(TOKEN_SYMMETRIC))
      {
        _tokenValue = Gold.AUTH_KEY;
      }
  
      // Password Token
      else if (_tokenType.equals(TOKEN_PASSWORD))
      {
        // Extract user name from Security Token
        String user = securityToken.getAttributeValue("name");
        if (user == null)
        {
          log.error("User name must be specified in Password encryption");
          throw new GoldException("434", "User name must be specified in Password encryption");
        }
  
        // Extract encrypted password from database
        //String encryptedPassword = Cache.getPasswordProperty(user, "Password");
        String encryptedPassword = "Look at the line above";
        if (encryptedPassword == null)
        {
          log.error("User does not have a password");
          throw new GoldException("444", "User does not have a password");
        }
  
        // Decrypt password with auth key
        byte[] authBytes = Gold.AUTH_KEY.getBytes();
        byte[] paddedAuthBytes = new byte[24];
        for (int i = 0; i < Gold.AUTH_KEY.length(); i++)
        {
          paddedAuthBytes[i] = authBytes[i];
        }
        SecretKey authKey = new SecretKeySpec(paddedAuthBytes, "DESede");
        byte[] password = Base64.decode(encryptedPassword);
        byte[] iv = new byte[8];
        for (int i = 0; i < 8; i++) { iv[i] = password[i]; }
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        byte[] passwordData = new byte[password.length-8];
        for (int i = 0; i < password.length-8; i++) { passwordData[i] = password[i+8]; }
        Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, authKey, ivSpec);
        byte[] tokenBytes = cipher.doFinal(passwordData);
        _tokenValue = new String(tokenBytes);
  
  //Log.logEntry("token=" + _tokenValue);
      }
  
      // Unknown token type
      else
      {
        log.error("Unsupported Security Token Type: " + _tokenType);
        throw new GoldException("434", "Unsupported Security Token Type: " + _tokenType);
      }
  
      if (_tokenValue == null || _tokenValue.length() == 0)
      {
        log.error("Security Token cannot be zero length");
        throw new GoldException("434", "Security Token cannot be zero length");
      }
      if (log.isDebugEnabled())
      {
        log.debug("The security token type is: " + _tokenType);
        //log.debug("The security token value is: " + _tokenValue);
      }
  
      // Step 3)  Decrypt the session key
  
      // Pad the token
      byte[] paddedTokenBytes = new byte[24];
      byte[] tokenBytes = _tokenValue.getBytes();
      for (int i = 0; i < tokenBytes.length; i++)
      {
        paddedTokenBytes[i] = tokenBytes[i]; 
      }
  
      // Check if length of ciphertext is reasonable for given key type
      byte[] ek = Base64.decode(wrappedText);
  //Log.logEntry(9, "The encrypted key length is " + ek.length);
  //Log.logEntry(9, "The encrypted key is " + Base64.encode(ek));
      if (ek.length != 40)
      {
        log.error("Encrypted key is not 40 octets (" + ek.length + ")");
        throw new GoldException("434", "Encrypted key is not 40 octets (" + ek.length + ")");
      }
      byte[] kek = new byte[24];
      for (int i = 0; i < paddedTokenBytes.length; i++) { kek[i] = paddedTokenBytes[i]; }
      for (int i = paddedTokenBytes.length; i < 24; i++) { kek[i] = 0; }
      SecretKey keyEncryptionKey = new SecretKeySpec(kek, "DESede");
  //Log.logEntry(9, "Token Key length is: " + paddedTokenBytes.length);
  //Log.logEntry(9, "Key Encryption Key length is: " + kek.length);
  //Log.logEntry(9, "Key Encryption Key is: " + Base64.encode(kek));
  //Log.logEntry(9, "Encrypted Key length is: " + ek.length);
  //Log.logEntry(9, "Encrypted Key is: " + Base64.encode(ek));
  
      // Decrypt text with 3DES in CBC mode using KEK and IV as 0x4adda22c79e82105
      Cipher cipher = Cipher.getInstance("DESede/CBC/NoPadding");
      byte[] funkyIv = {
        (byte) 0x4a, (byte) 0xdd, (byte) 0xa2, (byte) 0x2c,
        (byte) 0x79, (byte) 0xe8, (byte) 0x21, (byte) 0x05
      };
      IvParameterSpec ivSpec = new IvParameterSpec(funkyIv);
      cipher.init(Cipher.DECRYPT_MODE, keyEncryptionKey, ivSpec);
      byte[] temp3 = cipher.doFinal(ek);
  //Log.logEntry(9, "TEMP3 is: " + Base64.encode(temp3));
  //Log.logEntry(9, "TEMP3 length is: " + temp3.length);
  
      // Reverse the order of the octets in TEMP3 and call the result TEMP2
      byte[] temp2 = new byte[40];
      for (int i = 0; i < 40; i++) { temp2[i] = temp3[39-i]; }
  //Log.logEntry(9, "TEMP2 is: " + Base64.encode(temp2));
  //Log.logEntry(9, "TEMP2 length is: " + temp2.length);
  
      // Decompose TEMP2 into IV, the first 8 octets, and TEMP1
      byte[] iv = new byte[8];
      for (int i = 0; i < 8; i++) { iv[i] = temp2[i]; }
      byte[] temp1 = new byte[32];
      for (int i = 0; i < 32; i++) { temp1[i] = temp2[i+8]; }
  //Log.logEntry(9, "TEMP1 is: " + Base64.encode(temp1));
  //Log.logEntry(9, "TEMP1 length is: " + temp1.length);
    
      // Decrypt TEMP1 using 3DES in CBC mode using KEK and the IV -> WKCKS
      ivSpec = new IvParameterSpec(iv);
      cipher.init(Cipher.DECRYPT_MODE, keyEncryptionKey, ivSpec);
      byte[] wkcks = cipher.doFinal(temp1);
  //Log.logEntry(9, "WKCKS is: " + Base64.encode(wkcks));
  //Log.logEntry(9, "WKCKS length is: " + wkcks.length);
  
      // Decompose WKCKS. CKS is the last 8 octets and WK are those preceding it
      byte[] wk = new byte[24];
      for (int i = 0; i < 24; i++) { wk[i] = wkcks[i]; }
      byte[] cks = new byte[8];
      for (int i = 0; i < 8; i++) { cks[i] = wkcks[24+i]; }
  //Log.logEntry(9, "WK is: " + Base64.encode(wk));
  //Log.logEntry(9, "WK length is: " + wk.length);
  //Log.logEntry(9, "CKS is: " + Base64.encode(cks));
  //Log.logEntry(9, "CKS length is: " + cks.length);
  //for (int i = 0; i < 8; i++) { Log.logEntry(9, "CKS[" + i + "]=" + cks[i]); }
  
      // Calculate a CMS key checksum over the WK and compare with extracted CKS
      MessageDigest md = MessageDigest.getInstance("sha-1");
      md.update(wk);
      byte[] ccks = md.digest();
  //for (int i = 0; i < 8; i++) { Log.logEntry(9, "CCKS[" + i + "]=" + ccks[i]); }
      for (int i = 0; i < 8; i++) {
        if (ccks[i] != cks[i]) {
          log.error("Key wrap checksum integrity check failed");
          throw new GoldException("434", "Key wrap checksum integrity check failed");
        }
      }
  
      // WK is the wrapped key, extracted for use in data decryption
      SecretKey sessionKey = new SecretKeySpec(wk, "DESede");
      if (log.isDebugEnabled())
      {
        log.debug("The base64-encoded session key is: " + Base64.encode(sessionKey.getEncoded()));
      }
    
      // Step 4)  Decrypt the data with the session key
  
      // Recover the IV and the compressed data
      byte[] cipherPayload = Base64.decode(cipherText);
      iv = new byte[8];
      for (int i = 0; i < 8; i++) { iv[i] = cipherPayload[i]; }
      ivSpec = new IvParameterSpec(iv);
      byte[] cipherData = new byte[cipherPayload.length-8];
      for (int i = 0; i < cipherPayload.length-8; i++) { cipherData[i] = cipherPayload[i+8]; }
      cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
      cipher.init(Cipher.DECRYPT_MODE, sessionKey, ivSpec);
      byte[] compressedData = cipher.doFinal(cipherData);
  
      ByteArrayInputStream bais = new ByteArrayInputStream(compressedData);
      GZIPInputStream zis = new GZIPInputStream(bais);
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      int c = -1;
      while ((c = zis.read()) != -1) {
      baos.write(c);
      }       
      baos.flush();
      byte[] uncompressedData = baos.toByteArray();
      String plainText = new String(uncompressedData);
  //Log.logEntry(9, "The recoved plaintext is: " + plainText);
  
      // Step 5)  Replace encrypted data with envelope contents
  
      root.removeChild("EncryptedData");
  
      CanonicalXMLOutputter xmlout = new CanonicalXMLOutputter();
      String emptyEnvelope = xmlout.outputString(doc);
      String fullEnvelope = emptyEnvelope.substring(0, emptyEnvelope.lastIndexOf("</Envelope>")) + plainText + "</Envelope>";
  
      SAXBuilder builder = new SAXBuilder(false);
      Document newEnvelope = builder.build(new StringReader(fullEnvelope));
      doc.setRootElement(newEnvelope.detachRootElement());
    }
    catch (Exception e)
    {
      throw new GoldException("430", e.getMessage());
    }
  } // End decrypt

  // Authenticate the chunk
  public void authenticate(Document doc) throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    // Step 1)  Extract signature from envelope
    
    Element root = doc.getRootElement();

    // Extract body from envelope
    Element body = root.getChild("Body");
      
    // Extract signature from envelope
    Element signature = root.getChild("Signature");
    if (signature == null)
    {
      _authentication = false;
      if (log.isDebugEnabled())
      {
        log.debug("Message not authenticated -- No signature element found");
      }
      return;
    }
    else
    {
      _authentication = true;
    }

    Element digestValue = signature.getChild("DigestValue");
    if (digestValue == null)
    {
      log.error("No digest value found");
      throw new GoldException("424", "No digest value found");
    }
    String incomingDigest = digestValue.getText();

    Element signatureValue = signature.getChild("SignatureValue");
    if (signatureValue == null)
    {
      log.error("No signature value found");
      throw new GoldException("No signature value found");
    }
    String incomingSignature = signatureValue.getText();

    // Step 2)  Obtain the security token
    
    try
    {
      Element securityToken = signature.getChild("SecurityToken");
      if (securityToken != null)
      {
        _tokenType = securityToken.getAttributeValue("type");
      }
      else
      {
        _tokenType = Gold.TOKEN_SYMMETRIC;
      }
  
      // Symmetric Token type
      if (_tokenType.equals(TOKEN_SYMMETRIC))
      {
        _tokenValue = Gold.AUTH_KEY;
      }
  
      // Password Token
      else if (_tokenType.equals(TOKEN_PASSWORD))
      {
        // Extract user name from Security Token
        String user = securityToken.getAttributeValue("name");
        if (user == null)
        {
          log.error("Token name must be specified in Password authentication");
          throw new GoldException("Token name must be specified in Password authentication");
        }
        // Extract actor from request
        Element request = body.getChild("Request");
        String actor = request.getAttributeValue("actor");
        if (! user.equals(actor))
        {
          log.warn("Actor (" + actor + ") does not equal token name (" + user + ") -- setting actor to token name");
          actor = user;
        }
  
        // Extract encrypted password from database
        //String encryptedPassword = Cache.getPasswordProperty(user, "Password");
        String encryptedPassword = "Look at the line above";
        if (encryptedPassword == null)
        {
          log.error("User does not have a password");
          throw new GoldException("444", "User does not have a password");
        }
  
        // Decrypt password with auth key
        byte[] authBytes = Gold.AUTH_KEY.getBytes();
        byte[] paddedAuthBytes = new byte[24];
        for (int i = 0; i < Gold.AUTH_KEY.length(); i++)
        {
          paddedAuthBytes[i] = authBytes[i];
        }
        SecretKey authKey = new SecretKeySpec(paddedAuthBytes, "DESede");
        byte[] password = Base64.decode(encryptedPassword);
        byte[] iv = new byte[8];
        for (int i = 0; i < 8; i++) { iv[i] = password[i]; }
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        byte[] passwordData = new byte[password.length-8];
        for (int i = 0; i < password.length-8; i++) { passwordData[i] = password[i+8]; }
        Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, authKey, ivSpec);
        byte[] tokenBytes = cipher.doFinal(passwordData);
        _tokenValue = new String(tokenBytes);
  
  //Log.logEntry("tokenValue=" + _tokenValue);
      }
  
      // Unknown token type
      else
      {
        log.error("Unsupported Security Token Type: " + _tokenType);
        throw new GoldException("Unsupported Security Token Type: " + _tokenType);
      }
  
      if (_tokenValue == null || _tokenValue.length() == 0)
      {
        log.error("Security Token cannot be zero length");
        throw new GoldException("Security Token cannot be zero length");
      }
      if (log.isDebugEnabled())
      {
        log.debug("The security token type is: " + _tokenType);
        //log.debug("The security token value is: " + _tokenValue);
      }
  
      // Step 3)  Canonicalize the body into a String
  
      CanonicalXMLOutputter xmlout = new CanonicalXMLOutputter();
      String bodyText = xmlout.outputString(body);
      if (bodyText == null || bodyText.equals(""))
      {
        log.error("Message body cannot be empty");
        throw new GoldException("Message body cannot be empty");
      }
      if (log.isDebugEnabled())
      {
        log.debug("The canonicalized body text is: " + bodyText);
      }
  
      // Step 4)  Perform the digest and check it
  
      MessageDigest md = MessageDigest.getInstance("sha-1");
      md.update(bodyText.getBytes());
      byte[] digest = md.digest();
      String digestString = Base64.encode(digest);
      if (log.isDebugEnabled())
      {
        log.debug("The base64-encoded message digest is: " + digestString);
      }
      if (! digestString.equals(incomingDigest))
      {
        log.error("Integrity check failed -- incoming digest (" + incomingDigest + ") does not match calculated digest (" + digestString + ")");
        throw new GoldException("Integrity check failed -- incoming digest does not match calculated digest");
      }
  
      // Step 5)  Generate the MAC and check it
      
      SecretKey key = new SecretKeySpec(_tokenValue.getBytes(), "HmacSHA1");
      Mac m = Mac.getInstance("HmacSHA1");
      m.init(key);
      m.update(digest);
      byte[] mac = m.doFinal();
      String macString = Base64.encode(mac);
      if (log.isDebugEnabled())
      {
        log.debug("The base64-encoded MAC is: " + macString);
      }
      if (! macString.equals(incomingSignature))
      {
        log.error("Authentication failed -- incoming MAC does not match calculated MAC");
        throw new GoldException("Authentication failed -- incoming MAC does not match calculated MAC");
      }
    }
    catch (Exception e)
    {
      throw new GoldException("420", e.getMessage());
    }
  } // End authenticate


  // Sends the message chunk and receives the reply chunk
  public Chunk getChunk() throws GoldException
  {
    if (log.isDebugEnabled())
    {
      log.debug("invoked with arguments: ()");
    }

    Message message = new Message();
    Reply reply;
    Socket connection;
    Chunk chunk;

    // Send the message
    if (log.isInfoEnabled())
    {
      log.info("Sending the message chunk");
    }
    try
    {
      message.sendChunk(this);
    }
    catch(GoldException ge)
    {
      log.error("Failed sending message chunk: " + ge.getMessage());
      return new Chunk().setResponse(new Response().failure(ge.getCode(), "Failed sending message chunk: " + ge.getMessage()));
    }
    if (log.isDebugEnabled())
    {
      log.debug("Message chunk sent");
    }

    // Obtain a reply
    try
    {
      reply = message.getReply();
    }
    catch(GoldException ge)
    {
      log.error("Failed obtaining reply: " + ge.getMessage());
      return new Chunk().setResponse(new Response().failure(ge.getCode(), "Failed obtaining reply: " + ge.getMessage()));
    }

    // Receive the reply chunk
    if (log.isInfoEnabled())
    {
      log.info("Receiving reply chunk from server");
    }
    try
    {
      chunk = reply.receiveChunk();
    }
    catch(GoldException ge)
    {
      log.error("Failed receiving reply chunk: " + ge.getMessage());
      return new Chunk().setResponse(new Response().failure(ge.getCode(), "Failed receiving reply chunk: " + ge.getMessage()));
    }
    if (log.isDebugEnabled())
    {
      log.debug("Reply chunk received");
    }

    return chunk;
  } // end getChunk

}

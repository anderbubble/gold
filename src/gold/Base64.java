/******************************************************************************
 *                                                                            *
 *                             Copyright (c) 2003                             *
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

import gold.*;

public class Base64 {
  public static String encode(byte[] raw) {
    StringBuffer encoded = new StringBuffer();
    for (int i = 0; i < raw.length; i += 3) {
      encoded.append(encodeBlock(raw, i));
    }
    return encoded.toString();
  }

  protected static char[] encodeBlock(byte[] raw, int offset) {
    int block = 0;
    int slack = raw.length - offset - 1;
    int end = (slack >= 2) ? 2 : slack;
    for (int i = 0; i <= end; i++) {
      byte b = raw[offset + i];
      int neuter = (b < 0) ? b + 256 : b;
      block += neuter << (8 * (2 - i));
    }
    char[] base64 = new char[4];
    for (int i = 0; i < 4; i++) {
      int sixbit = (block >>> (6 * (3 - i))) & 0x3f;
      base64[i] = getChar(sixbit);
    }
    if (slack < 1) base64[2] = '=';
    if (slack < 2) base64[3] = '=';
    return base64;
  }

  protected static char getChar(int sixBit) {
    if (sixBit >= 0 && sixBit <= 25)
      return (char)('A' + sixBit);
    if (sixBit >= 26 && sixBit <= 51)
      return (char)('a' + (sixBit - 26));
    if (sixBit >= 52 && sixBit <= 61)
      return (char)('0' + (sixBit - 52));
    if (sixBit == 62) return '+';
    if (sixBit == 63) return '/';
    return '?';
  }

  public static byte[] decode(String base64) {
    int pad = 0;
    for (int i = base64.length() - 1; base64.charAt(i) == '='; i--)
      pad++;
    int length = base64.length() * 6 / 8 - pad;
    byte[] raw = new byte[length];
    int rawIndex = 0;
    for (int i = 0; i < base64.length(); i += 4) {
      int block = (getValue(base64.charAt(i)) << 18)
          + (getValue(base64.charAt(i + 1)) << 12)
          + (getValue(base64.charAt(i + 2)) << 6)
          + (getValue(base64.charAt(i + 3)));
      for (int j = 0; j < 3 && rawIndex + j < raw.length; j++)
        raw[rawIndex + j] = (byte)((block >> (8 * (2 - j))) & 0xff);
      rawIndex += 3;
    }
    return raw;
  }

  protected static int getValue(char c) {
    if (c >= 'A' && c <= 'Z') return c - 'A';
    if (c >= 'a' && c <= 'z') return c - 'a' + 26;
    if (c >= '0' && c <= '9') return c - '0' + 52;
    if (c == '+') return 62;
    if (c == '/') return 63;
    if (c == '=') return 0;
    return -1;
  }
}


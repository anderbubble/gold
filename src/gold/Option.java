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
 *    � Redistributions of source code must retain the above copyright        *
 *    notice, this list of conditions and the following disclaimer.           *
 *                                                                            *
 *    � Redistributions in binary form must reproduce the above copyright     *
 *    notice, this list of conditions and the following disclaimer in the     *
 *    documentation and/or other materials provided with the distribution.    *
 *                                                                            *
 *    � Neither the name of Battelle nor the names of its contributors        *
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
  
import java.util.Vector;

public class Option
{
  private String _name;
  private String _value;
  //private String _conj;
  private String _op;
    
  // Empty Constructor
  public Option()
  { 
  }

  // Simple Constructor
  public Option(String name)
  { 
    _name = name;
    _value = "True";
  }

  // Normal Constructor
  public Option(String name, String value)
  { 
    _name = name;
    _value = value;
  }

  // Full Constructor
  public Option(String name, String value, String op)
  { 
    _name = name;
    _value = value;
    _op = op;
  }

  // Accessors

  // Get the name
  public String getName()
  {
    return _name;
  }

  // Get the value
  public String getValue()
  {
    return _value;
  }

  // Get the operator
  public String getOperator()
  {
    return _op;
  }

  //// Get the conjunction
  //public String getConjunction()
  //{
  //  return _conj;
  //}

	public String toString()
	{
		Vector v = new Vector();
    v.add(_name);
    v.add(_value);
    v.add(_op);
    return v.toString();
	}

  // Mutators
    
  // Set the name
  public void setName(String name)
  {
    _name = name;
  }

  // Set the value
  public void setValue(String value)
  {
    _value = value;
  }

  // Set the operator
  public void setOperator(String op)
  {
    _op = op;
  }

  //// Set the conjunction
  //public void setConjunction(String conj)
  //{
  //  _conj = conj;
  //}

}


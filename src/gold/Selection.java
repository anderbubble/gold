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
  
import java.util.Vector;

public class Selection
{
	private String _name;
	private String _op;
	private String _object;
	private String _alias;
    
  // Empty Constructor
  public Selection()
  { 
  }

  // Simple Constructor
  public Selection(String name)
  { 
		_name = name;
  }

  // Full Constructor
  public Selection(String name, String op)
  { 
		_name = name;
		_op = op;
  }

  // Join Constructor
  public Selection(String name, String op, String object)
  { 
		_name = name;
		_op = op;
		_object = object;
  }

  // Alias Constructor
  public Selection(String name, String op, String object, String alias)
  { 
		_name = name;
		_op = op;
		_object = object;
		_alias = alias;
  }

  // Accessors

  // Get the name
  public String getName()
  {
    return _name;
  }

  // Get the operator
  public String getOperator()
  {
    return _op;
  }

  // Get the object
  public String getObject()
  {
    return _object;
  }

  // Get the alias
  public String getAlias()
  {
    return _alias;
  }

	public String toString()
	{
		Vector v = new Vector();
		v.add(_name);
		v.add(_op);
		v.add(_object);
		v.add(_alias);
    return v.toString();
	}

  // Mutators
    
  // Set the name
  public void setName(String name)
  {
		_name = name;
  }

  // Set the operator
  public void setOperator(String op)
  {
		_op = op;
  }

  // Set the object
  public void setObject(String object)
  {
		_object = object;
  }

  // Set the alias
  public void setAlias(String alias)
  {
		_alias = alias;
  }

}


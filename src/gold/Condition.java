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

public class Condition
{
  private String _name;
  private String _value;
  private String _op;
  private String _conj;
  private String _group;
  private String _object;
  private String _subject;
    
  // Empty Constructor
  public Condition()
  { 
  }

  // Simple Constructor
  public Condition(String name, String value)
  { 
		_name = name;
		_value = value;
  }

  // General Constructor
  public Condition(String name, String value, String op)
  { 
		_name = name;
		_value = value;
		_op = op;
  }

  // Full Constructor
  public Condition(String name, String value, String op, String conj, String group)
  { 
		_name = name;
		_value = value;
		_op = op;
		_conj = conj;
		_group = group;
  }

  // Join Constructor
  public Condition(String name, String value, String op, String conj, String group, String object)
  { 
		_name = name;
		_value = value;
		_op = op;
		_conj = conj;
		_group = group;
		_object = object;
  }

  // Full Join Constructor
  public Condition(String name, String value, String op, String conj, String group, String object, String subject)
  { 
		_name = name;
		_value = value;
		_op = op;
		_conj = conj;
		_group = group;
		_object = object;
		_subject = subject;
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

  // Get the conjunction
  public String getConjunction()
  {
    return _conj;
  }

  // Get the grouping
  public String getGroup()
  {
    return _group;
  }

  // Get the object
  public String getObject()
  {
    return _object;
  }

  // Get the subject
  public String getSubject()
  {
    return _subject;
  }

	public String toString()
	{
    Vector v = new Vector();
    v.add(_name);
    v.add(_value);
    v.add(_op);
    v.add(_conj);
    v.add(_group);
    v.add(_object);
    v.add(_subject);
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

  // Set the conjunction
  public void setConjunction(String conj)
  {
    _conj = conj;
  }

  // Set the grouping
  public void setGroup(String group)
  {
    _group = group;
  }

  // Set the object
  public void setObject(String object)
  {
    _object = object;
  }

  // Set the subject
  public void setSubject(String subject)
  {
    _subject = subject;
  }

}


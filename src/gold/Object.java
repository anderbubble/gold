/******************************************************************************
 *                                                                            *
 *                             Copyright (c) 2004                             *
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
  
import java.util.Vector;

public class Object
{
  private String _name;
  private String _alias;
  private String _join;
    
  // Empty Constructor
  public Object()
  { 
  }

  // Simple Constructor
  public Object(String name)
  { 
    _name = name;
  }

  // Full Constructor
  public Object(String name, String alias, String join)
  { 
    _name = name;
    _alias = alias;
    _join = join;
  }

  // Accessors

  // Get the name
  public String getName()
  {
    return _name;
  }

  // Get the alias
  public String getAlias()
  {
    return _alias;
  }

  // Get the join
  public String getJoin()
  {
    return _join;
  }

	public String toString()
	{
		Vector v = new Vector();
    v.add(_name);
    return v.toString();
	}

  // Mutators
    
  // Set the name
  public void setName(String name)
  {
    _name = name;
  }

  // Set the alias
  public void setAlias(String alias)
  {
    _alias = alias;
  }

  // Set the join
  public void setJoin(String join)
  {
    _join = join;
  }

}


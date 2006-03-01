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
  
import org.jdom.Element;

public class Datum implements Cloneable
{
  private Element _element;
    
  // String Constructor
  public Datum(String name)
  { 
    _element = new Element(name);
  }

  // Element Constructor
  public Datum(Element element)
  { 
    _element = (Element)element.clone();
  }

 // Override inherited clone() to make it public
  public java.lang.Object clone() throws CloneNotSupportedException
  {
    return super.clone();
  }

  // Accessors

  // Get the datum element
  public Element getElement()
  {
    return (Element)_element.clone();
  }

  // Get the name of the datum
  public String getName()
  {
    return _element.getName();
  }

  // Get the text value of the named datum element
  public String getValue(String name)
  {
    return _element.getChildText(name);
  }

	public String toString()
	{
    if (_element != null)
    {
      CanonicalXMLOutputter xmlout = new CanonicalXMLOutputter();
      return xmlout.outputString(_element);
    }
    return null;

	}

  // Mutators
    
  // Sets the datum from element
  public Datum setElement(Element element)
  { 
    _element = (Element)element.clone();
    return this;
  }

  // Set the name of the datum
  public Datum setName(String name)
  {
    _element.setName(name);
    return this;
  }

  // Add a datum property by name and value
  public Datum setValue(String name, String value)
  {
    Element property = new Element(name);
    property.setText(value);
    _element.addContent(property);
    return this;
  }

  // Appends a new child datum
  public Datum setChild(Datum child)
  {
    _element.addContent(child.getElement());
    return this;
  }

  // Appends an attribute to a datum
  public Datum setAttribute(String name, String value)
  {
    _element.setAttribute(name, value);
    return this;
  }

}


"this is a stubbed declaration of the root class 'Object' which is
 required for other classes to be defined."

class_name Object
class_methods

"instance creation"

  {new}
  | newObject |


  "use inline pascal to create a new object"
  newObject.     "force code generation for this method"
  ` new(l1);
  ` l1^.class_holder := ord(cl_Object);

  ^newObject          "return the new object"

"end of Object class"

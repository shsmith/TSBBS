
{ test.DCL - Made by STP v0.1 (12-Mar-86 S.H.Smith) }


var
   Object_cv: record
   end;

type
   Object_ivptr = ^Object_iv;
   Object_iv = record
      super_iv: byte;
   end;

var
   Resource_cv: record
      ActiveSimulation: objptr;
   end;

type
   Resource_ivptr = ^Resource_iv;
   Resource_iv = record
      super_iv: Object_iv;
      resourceName: objptr;
      pending: objptr;
   end;

type sels = (
      s_named_,
      s_activeSimulation_,
      s_new);

type
   class_ptr = ^class_codes;
   class_codes = (
      cl_Resource,
      cl_Object);

function sendm (sel: sels; s,p1,p2,p3,p4: objptr): objptr;
   forward;


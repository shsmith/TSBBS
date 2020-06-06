
{ test2.PAS - Made by STP v0.1 (12-Mar-86 S.H.Smith) }

{$I stplib.inc - STP library}
{$I test2.DCL - global declarations}

function cf_Object (sel: sels;  s,p1,p2,p3,p4: objptr): objptr;

{local and special variables}
var
   self: Object_ivptr absolute s;
   l0,l1,l2,l3,l4: objptr;

begin
  case sel of
    s_new:  begin
      {method locals: newObject}
      l0 := l1;
 new(l1);
 l1^.class_holder := ord(cl_Object);
      cf_Object := l1;
      exit;
    end;
    
    else
      {message not handled here; pass it to the superclass}
      serror('invalid message selector');
  end;
  
  cf_Object := l0;
end;



function cf_SortedCollection (sel: sels;  s,p1,p2,p3,p4: objptr): objptr;

{local and special variables}
var
   self: SortedCollection_ivptr absolute s;
   l0,l1,l2,l3,l4: objptr;

begin
  case sel of
    s_new:  begin
      cf_SortedCollection := sendm (s_new,s,nil,nil,nil,nil);
      exit;
    end;
    
    else
      {message not handled here; pass it to the superclass}
      l0 := cf_Object(sel,s,p1,p2,p3,p4);
  end;
  
  cf_SortedCollection := l0;
end;



function cf_Resource (sel: sels;  s,p1,p2,p3,p4: objptr): objptr;

{local and special variables}
var
   self: Resource_ivptr absolute s;
   l0,l1,l2,l3,l4: objptr;

begin
  case sel of
    s_activeSimulation_:  begin
      {method parameters: existingSimulation}
      Resource_cv.ActiveSimulation := p1;
    end;
    
    s_addRequest_:  begin
      {method parameters: aDelayedEvent}
      l0 := sendm (s_add_,self^.pending,p1,nil,nil,nil);
      l0 := sendm (s_provideResources,s,nil,nil,nil,nil);
      l0 := sendm (s_stopProcess,Resource_cv.ActiveSimulation,nil,nil,nil,nil);
      l0 := sendm (s_pause,p1,nil,nil,nil,nil);
      l0 := sendm (s_startProcess,Resource_cv.ActiveSimulation,nil,nil,nil,nil);
    end;
    
    s_name:  begin
      cf_Resource := self^.resourceName;
      exit;
    end;
    
    s_provideResources:  begin
      cf_Resource := s;
      exit;
    end;
    
    s_setName_:  begin
      {method parameters: aString}
      self^.resourceName := p1;
      self^.pending := cf_SortedCollection(s_new,nil,nil,nil,nil,nil);
    end;
    
    s_testWith_whileTrue_initialValue:  begin
      {method parameters: aValue condBlock aBlock}
      {method locals: val}
      l0 := l1;
    end;
    
    s_named_:  begin
      {method parameters: resourceName}
      cf_Resource := sendm (s_new,s,nil,nil,nil,nil);
      exit;
    end;
    
    else
      {message not handled here; pass it to the superclass}
      l0 := cf_Object(sel,s,p1,p2,p3,p4);
  end;
  
  cf_Resource := l0;
end;


function  sendm {forward};
var
   object_class:  class_ptr absolute s;
begin
   if s = nil then serror('nil object');
   case object_class^ of
      cl_Resource: 
         sendm := cf_Resource(sel,s,p1,p2,p3,p4);
      cl_SortedCollection: 
         sendm := cf_SortedCollection(sel,s,p1,p2,p3,p4);
      cl_Object: 
         sendm := cf_Object(sel,s,p1,p2,p3,p4);
      else
         serror('invalid object class');
   end;
end;


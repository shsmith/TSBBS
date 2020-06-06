
"test.s - this is a test of the STP Smalltalk --> Pascal translator"
"this is from page 485 of the Smalltalk-80 Language book"

include_file 'object.s'


class_name                    Resource

superclass                    Object

instance_variable_names       pending
                              resourceName

class_variable_names          ActiveSimulation


class_methods

"class initialization"

   {activeSimulation: existingSimulation}
      ActiveSimulation := existingSimulation


"instance creation"

   {named: resourceName}
      ^self new setName: resourceName


"accessing"

   {addRequest: aDelayedEvent}
      pending add: aDelayedRequest.
      self provideResources.
      ActiveSimulation stopProcess.
      aDelayedEvent pause.
      ActiveSimulation startProcess

   {name}
      ^resourceName


"private"

   {provideResources}
      ^self

   {setName: aString}
      resourceName := aString.
      pending := SortedCollectionNew


"language tests"

   {testWith: aBlock  whileTrue: condBlock  initialValue: aValue}
      | val |
      val := aValue.
      (aBlock value) whileTrue: condBlock
                     do: aBlock


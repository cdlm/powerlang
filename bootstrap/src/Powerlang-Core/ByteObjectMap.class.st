Class {
	#name : #ByteObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'bytes'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
ByteObjectMap >> at: index [
	"Return indexed value at given index, starting with 1. This CANNOT be 
	 used for accessing named slots (aka, instance variables), to access 
	 them use #instVarAt:"
	
	self assert: (index between: 1 and: bytes size).
	^bytes at: index
]

{ #category : #accessing }
ByteObjectMap >> at: index put: value [
	"Set indexed value at given `index` to `value`. This CANNOT be used for 
	 setting named slots (aka, instance variables), to access them use 
	 #instVarAt:put:"
	
	self assert: (index between: 1 and: bytes size).
	self assert: (value between: 0 and: 255).
	bytes at: index put: value
]

{ #category : #accessing }
ByteObjectMap >> bodySizeInBytes [
	"Return the size of object body(s) in bytes. 
	 This DOES NOT INCLUDE any passing."
	
	^ self size

]

{ #category : #accessing }
ByteObjectMap >> bytes [
	^ bytes
]

{ #category : #initialization }
ByteObjectMap >> initializeWithDef: anRGBehavior size: size [
	self assert: anRGBehavior notNil.
	self assert: anRGBehavior isBytes.
	self assert: anRGBehavior isVariable.
	
	behaviorDef := anRGBehavior.
	bytes := ByteArray new: size
]

{ #category : #testing }
ByteObjectMap >> isBytes [
	^true
]

{ #category : #accessing }
ByteObjectMap >> size [
	"Return the size if this object, that this, the value of
	 size field in object header. 
	
	 For slot (pointer) objects, this is a number of slots. 
	 For byte objects, this is a number of bytes. "
	
	^ bytes size
]

{ #category : #accessing }
ByteObjectMap >> smallHeaderFlags [
	"Return value of 'flags' field of small header"

	| small |
	
	small := self isSmall ifTrue: [ 16r80 ] ifFalse: [ 0 ].
	^ 1 | 2 | small

]

{ #category : #validation }
ByteObjectMap >> validate [
	super validate.
]
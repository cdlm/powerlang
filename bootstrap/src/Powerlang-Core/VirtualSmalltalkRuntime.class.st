Class {
	#name : #VirtualSmalltalkRuntime,
	#superclass : #Object,
	#instVars : [
		'image',
		'frames',
		'methodCache',
		'symbolCache',
		'smallintBehavior',
		'lastHash',
		'overrides',
		'globals',
		'virtualSpecies'
	],
	#classVars : [
		'Undermessages'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #'class initialization' }
VirtualSmalltalkRuntime class >> initialize [
	"
	self initialize
	"
	Undermessages := #(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: #_uShortAtOffset:put:)
]

{ #category : #services }
VirtualSmalltalkRuntime >> booleanFrom: anObject [
	anObject == image false
		ifTrue: [ ^ false ].
	anObject == image true
		ifTrue: [ ^ true ].
	self error: 'not a boolean'
]

{ #category : #testing }
VirtualSmalltalkRuntime >> builderOf: closure [
	frames
		reverseDo: [ :frame | 
			(frame built: closure)
				ifTrue: [ ^ frame ] ].
	self error: 'home of closure not found'
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> compile: anRGMethod [
	| compiler spec class |
	compiler := SCompiler namespace: globals.
	spec := anRGMethod parent.
	class := self virtualSpeciesFor: spec.
	^ compiler
		forClass: class;
		compile: anRGMethod sourceCode
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> doLookup: aSymbol startingAt: aBehavior [
	| behavior m c smethod |
	behavior := aBehavior.
	[ m := self methodFor: aSymbol in: behavior.
	m
		ifNotNil: [ smethod := self compile: m.
			^ self transferMethodLiterals: smethod ].
	behavior := behavior superclass.
	behavior notNil ] whileTrue.
	^ aBehavior isMeta
		ifTrue: [ c := aBehavior environment at: #Class.
			self doLookup: aSymbol startingAt: c ]
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> false [
	^ image false
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> image: aVirtualSmalltalkImage [
	image := aVirtualSmalltalkImage.
	smallintBehavior := (image classNamed: #SmallInteger) instanceBehavior.
	self
		initializeEmulationOverrides;
		initializeGlobals
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> initialize [
	frames := OrderedCollection new.
	methodCache := Dictionary new.
	symbolCache := IdentityDictionary new.
	overrides := Dictionary new.
	virtualSpecies := OrderedDictionary new.
	globals := VirtualDictionary new
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> initializeEmulationOverrides [
	self
		override: #Species -> #basicNew with: 'basicNew <primitive: New>';
		override: #Species -> #basicNew:
			with: 'basicNew: anInteger <primitive: NewSized>';
		override: #Species -> #new with: 'new <primitive: New>';
		override: #Species -> #new:
			with: 'new: anInteger <primitive: NewSized>';
		override: #Species -> #primitiveNewBytes:
			with: 'primitiveNewBytes: anInteger <primitive: NewBytes>';
		override: #'Float class' -> #new with: 'new <primitive: FloatNew>';
		override: #ProtoObject -> #_size
			with: '_size <primitive: UnderSize>';
		override: #ProtoObject -> #behavior
			with: 'behavior <primitive: Behavior>';
		override: #ProtoObject -> #==
			with: '== anObject <primitive: Equal>';
		override: #ProtoObject -> #primitiveSize
			with: 'primitiveSize <primitive: Size>';
		override: #ProtoObject -> #primitiveAt:
			with: 'primitiveAt: anInteger <primitive: At>';
		override: #ProtoObject -> #primitiveAt:put:
			with: 'primitiveAt: anInteger put: anObject <primitive: AtPut>';
		override: #ProtoObject -> #basicHash
			with: 'basicHash <primitive: Hash>';
		override: #SmallInteger -> #+
			with: '+ anObject <primitive: SMIPlus>';
		override: #SmallInteger -> #-
			with: '- anObject <primitive: SMIMinus>';
		override: #SmallInteger -> #*
			with: '* anObject <primitive: SMITimes>';
		override: #SmallInteger -> #//
			with: '// anObject <primitive: SMIIntDiv>';
		override: #SmallInteger -> #\\
			with: '\\ anObject <primitive: SMIIntQuot>';
		override: #SmallInteger -> #bitAnd:
			with: 'bitAnd: aNumber <primitive: SMIBitAnd>';
		override: #SmallInteger -> #bitXor:
			with: 'bitXor: aNumber <primitive: SMIBitXor>';
		override: #SmallInteger -> #bitShift:
			with: 'bitShift: aNumber <primitive: SMIBitShift>';
		override: #SmallInteger -> #highBit
			with: 'highBit <primitive: SMIHighBit>';
		override: #SmallInteger -> #>
			with: '> anObject <primitive: SMIGreaterThan>';
		override: #SmallInteger -> #>=
			with: '>= anObject <primitive: SMIGreaterEqualThan>';
		override: #SmallInteger -> #=
			with: '= anObject <primitive: SMIEqual>';
		override: #SmallInteger -> #sizeInBytes
			with: 'sizeInBytes <primitive: SMISize>';
		override: #Closure -> #value
			with: 'value <primitive: ClosureValue>';
		override: #Closure -> #evaluateAtomically
			with: 'evaluateAtomically <primitive: ClosureValue>';
		override: #Closure -> #value:
			with: 'value: a1 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #value:value:
			with: 'value: a1 value: 2 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #value:value:value:
			with: 'value: a1 value: a2 value: a3 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #evaluateWith:
			with: 'evaluateWith: arg <primitive: ClosureValueWithArgs>';
		override: #Closure -> #evaluateWith:with:
			with: 'evaluateWith: a1 with: a2 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #whileTrue:
			with: 'whileTrue: aBlock <primitive: ClosureWhileTrue>';
		override: #Closure -> #whileFalse:
			with: 'whileFalse: aBlock <primitive: ClosureWhileFalse>';
		override: #Closure -> #argumentCount
			with: 'argumentCount <primitive: ClosureArgumentCount>';
		override: #String -> #replaceFrom:to:with:startingAt:
			with:
			'replaceFrom: start to: end with: aCollection startingAt: position <primitive: StringReplaceFromToWithStartingAt>';
		override: #'HashTable class' -> #primeFor:
			with: 'primeFor: anInteger <primitive: PrimeFor>'
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> initializeGlobals [
	|  assoc |
	 image classes
		keysAndValuesDo: [ :spec :map | 
			assoc := image newAssociation: spec name asSymbol -> map.
			globals add: assoc ]
]

{ #category : #testing }
VirtualSmalltalkRuntime >> isUndermessage: selector [
	^ Undermessages includes: selector
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> lastHash [
	^ lastHash value value
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> lastHash: anInteger [
	^ lastHash value value: anInteger
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> lookup: aSymbol startingAt: aBehavior [
	^methodCache at: aSymbol -> aBehavior ifAbsentPut: [ self doLookup: aSymbol startingAt: aBehavior ]
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> methodFor: aSymbol in: anRGBehavior [
	overrides at: anRGBehavior->aSymbol ifPresent: [:m | ^m].
	^anRGBehavior methodNamed: aSymbol
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> newClosure: anInteger [
	^image newSlots: #Closure sized: anInteger
]

{ #category : #services }
VirtualSmalltalkRuntime >> newInteger: anInteger [ 
	^image newInteger: anInteger 
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> nil [
	^ image nil
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> override: assoc with: source [
	| species selector method override |
	species := image kernel at: assoc key.
	selector := assoc value.
	method := species methodNamed: selector.
	override := method copy sourceCode: source.
	overrides at: species -> selector put: override
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> popFrame [
	frames removeLast
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> pushFrame: aMethodEvaluator [
	frames addLast: aMethodEvaluator
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> send: aSymbol to: receiver [
	^ self send: aSymbol to: receiver with: {}
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> send: aSymbol to: receiver with: anArray [
	^ self send: aSymbol to: receiver with: anArray super: false
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> send: aSymbol to: receiver with: arguments super: aBoolean [
	| behavior method environment frame |
	(self isUndermessage: aSymbol)
		ifTrue: [ ^ frames last staticSend: aSymbol to: receiver with: arguments ].
	behavior := aBoolean
		ifTrue: [ frames last classBinding superclass spec ]
		ifFalse: [ receiver spec ].
	method := self lookup: aSymbol startingAt: behavior.
	self ASSERT: method notNil.
	environment := image newSlots: #Array sized: method environmentCount.
	frame := MethodEvaluator new
		receiver: receiver;
		arguments: arguments;
		environment: environment;
		method: method;
		system: self.
	^ frame evaluate
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> smallintBehavior [
	^smallintBehavior
]

{ #category : #services }
VirtualSmalltalkRuntime >> symbolFrom: anObjectMap [
	^ symbolCache
		at: anObjectMap
		ifAbsentPut: [ anObjectMap asString asSymbol ]
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> transferLiteral: anObject [
	^image transferLiteral: anObject
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> transferMethodLiterals: method [
	| class |
	method withIndexDo: [:literal :i | 
		class := literal class.
		((class inheritsFrom: ObjectMap)
			or: [ class = SCompiledBlock ])
			ifFalse: [ method at: i put: (image transferLiteralDeep: literal) ] ].
	^ method
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> true [
	^image true
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> unwindUpTo: environment returning: value [
	| frame |
	frames size to: 1 by: -1 do: [ :i | 
		frame := frames at: i.
		frame returning: value.
		(frame isHomeOf: environment)
			ifTrue: [ ^ frames removeLast: frames size - i ]
	 ].
	self error: 'frame not found'
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> virtualClassFor: spec [
	| superclass supervirtual  virtual |
	superclass := spec superclass.
	supervirtual := superclass
		ifNotNil: [ self virtualSpeciesFor: superclass ].
	virtual := VirtualClass new
		spec: spec;
		superclass: supervirtual.
	virtual createClassAssociationsWith: image.
	^ virtualSpecies at: spec put: virtual
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> virtualMetaclassFor: spec [
	| superclass supervirtual class virtual |
	class := self virtualSpeciesFor: spec instanceSide.
	superclass := spec superclass ifNil: image => #Class.
	supervirtual := self virtualSpeciesFor: superclass.
	virtual := VirtualMetaclass new
		spec: spec;
		superclass: supervirtual;
		class: class.
	^ virtualSpecies at: spec put: virtual
]

{ #category : #accessing }
VirtualSmalltalkRuntime >> virtualSpeciesFor: spec [

	virtualSpecies at: spec ifPresent: [ :existing | ^ existing ].
^	spec isMeta ifTrue: [self virtualMetaclassFor: spec] ifFalse: [self virtualClassFor: spec]

]
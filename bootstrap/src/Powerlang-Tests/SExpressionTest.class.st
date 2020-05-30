Class {
	#name : #SExpressionTest,
	#superclass : #TestCase,
	#category : #'Powerlang-Tests'
}

{ #category : #private }
SExpressionTest class >> isTestSelector: selector [
	^(super isTestSelector: selector)
		or: [self templateSelectors includes: selector]
]

{ #category : #private }
SExpressionTest class >> supportMethods [
	^self supportSelectors
		collect: [:selector | (self >> selector) copy classBinding: Object]
]

{ #category : #private }
SExpressionTest class >> supportMethodsUsing: anEnvironment [
	^ self supportMethods collect: [ :method | 
		  | copy |
		  copy := method copy
			          classBinding: Object;
			          yourself.
		  self nativize: copy using: anEnvironment.
		  copy ]
]

{ #category : #private }
SExpressionTest class >> supportSelectors [
	^self selectorsWithCategory: 'support'
]

{ #category : #private }
SExpressionTest class >> templateSelectors [
	| selectors current |
	selectors := OrderedCollection new.
	current := self organization.
	current categories
		select: [:c | c beginsWith: 'templates']
		thenDo: [:c | selectors addAll: (organization
			selectorsFor: c)].
	^selectors sort
]

{ #category : #private }
SExpressionTest class >> testSelectors [
	^super testSelectors asOrderedCollection addAll: self templateSelectors; yourself
]

{ #category : #support }
SExpressionTest >> add: arg1 to: arg2 [
	^arg1 + arg2 
]

{ #category : #templates }
SExpressionTest >> assertCorrectExecutionOfLibrary: filename [
	self assertCorrectExecutionUsing: ' ' loading: filename
]

{ #category : #templates }
SExpressionTest >> assertCorrectExecutionOfTest: aSelector [
	(self nativize: aSelector) halt disassembledAmd64
]

{ #category : #templates }
SExpressionTest >> assertCorrectExecutionUsing: arguments [
	| executor |
	executor := self executeUsing: arguments.
	executor exitCode != 1
		ifTrue: [ 
			self
				assert: false
				description: (self assertionFailureReportForExecution: executor) ]
		ifFalse: [ self assert: true ]
]

{ #category : #generating }
SExpressionTest >> generateMinimalLibraryWithEntryPoint: selector [
	| builder entrypoint |
	builder := #Librarian forBuilding newLibraryBuilder.
	entrypoint := builder
		              filename: self libraryPath asFileReference;
		              addAll:
			              (self class supportMethodsUsing: builder environment);
		              entryPoint: self class >> selector.
	self class nativize: entrypoint using: builder environment.
	builder generate
]

{ #category : #generating }
SExpressionTest >> libraryName [
	^ self class name , '_' , testSelector , '.psl'
]

{ #category : #templates }
SExpressionTest >> libraryPath [
	^'./temp/', self libraryName
]

{ #category : #private }
SExpressionTest >> nativize: aSymbol [
	| method smethod |
	method := self class >> aSymbol.
	smethod := Compiler compile: method sourceCode in: self class.
	^ NativizationEnvironment forTesting newExpressionNativizer 
		  nativeCodeFor: smethod
]

{ #category : #templates }
SExpressionTest >> performTest [
	^ self assertCorrectExecutionOfTest: testSelector asSymbol 
]

{ #category : #templates }
SExpressionTest >> test010_message [
	^1 yourself 
]

{ #category : #templates }
SExpressionTest >> test011_4minus3 [
	^4 - 3 
]

{ #category : #templates }
SExpressionTest >> test011_plus2 [
	^1 + 0 
]

{ #category : #templates }
SExpressionTest >> test020_tempVars [
	| three four |
	three := 3.
	four := 4.
	^four - three 
]

{ #category : #templates }
SExpressionTest >> test030_messageArguments [
	^self add: 1 to: 0 
]

{ #category : #templates }
SExpressionTest >> test100_block [
	^[1] value 
]

{ #category : #templates }
SExpressionTest >> test110_block [
	^[4 - 3] value 
]

{ #category : #templates }
SExpressionTest >> test120_blockNonLocalReturn [
	[^1] value 
]

{ #category : #templates }
SExpressionTest >> test130_blockTemps [
	^[| three four |
		three := 3.
		four := 4.
		four - three] value 
]

{ #category : #templates }
SExpressionTest >> test140_blockArgs [
	^[:arg1 :arg2 | arg2 - arg1] value: 3 value: 4 
]

{ #category : #templates }
SExpressionTest >> test145_blockArgsAndTemps [
	^[:arg | | three |
		three := 3.
		arg - three]
		value: 4 
]

{ #category : #templates }
SExpressionTest >> test150_blockEnvironmentTemps [
	| one |
	one := 1.
	^[one] value 
]

{ #category : #templates }
SExpressionTest >> test151_blockEnvironmentTemps [
	| three |
	three := 3.
	^[| four |
		four := 4.
		four - three] value 
]
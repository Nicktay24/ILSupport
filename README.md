# IL Support
Parses CLI code and merges with your DLL using dnlib. C\# does not provide coding in CLI but this way you can code CLI alongside C\#. I knew there are other implementations but they don't all provide full CLI coding. Using ildasm and ilasm would be too slow to merge with DLL.

## **IMPORTANT NOTICE**
**CLI syntax** is officially fully-documented [here](https://www.ecma-international.org/publications-and-standards/standards/ecma-335/).

**MANDATORY** Format For Floating-Point Literal

All **FLOATING-POINT LITERALS** will be parsed as followed. Many decompilers export different CLI formats for floating-point literals. Therefore, you will have to correct the format to match: _Float32_ and _Float64_.

**ADDED** loading constant field values: _ConstantFieldValue_.

**ADDED** extra format for directives: **.custom**, **.permission**, and **.permissionset**.

**EXCLUDED**: **.permission** _SecAction_ _TypeReference_ ‘(’ _NameValPairs_ ‘)’

### README Syntax
``
::= declares a Custom Format whose name precedes ::= and whose format is defined after.
_Italic_ represents a reference to a Custom Format whose name matches. If this precedes ::= then this is a Custom Format declaration instead of a Custom Format reference.
**Bold** specifies a literal.
‘’ contains a literal character.
| is OR operator.
\[\] marks its contents as optional.
\* specifies zero or more of the preceding item.
_QSTRING_ is double-quoted string.
_SQSTRING_ is single-quoted string.
``

## Added Syntactic Formats
###### _CppFloatLiteral_ ::=
> _RealNumber_ may be the [C++ floating-point literal](https://en.cppreference.com/w/cpp/language/floating_literal).
```
 	_RealNumber_
|	\[ ‘**+**’ | ‘**-**’ \] **inf**
|	\[ ‘**+**’ | ‘**-**’ \] **NaN**
```

###### _Float32_ ::=
```
 	_CppFloatLiteral_
|	float32 ‘**(**’ _Int32Literal_ ‘**)**’
|	float32 ‘**(**’ _UInt32Literal_ ‘**)**’
```

###### _Float64_ ::=
```
 	_CppFloatLiteral_
|	float64 ‘**(**’ _Int64Literal_ ‘**)**’
|	float64 ‘**(**’ _UInt64Literal_ ‘**)**’
```

###### _ConstantFieldValue_ ::=
> _FieldReference_ must be reference to a constant field. The constant will be loaded on compile. Valid for operand of opcodes, ldfld and ldsfld; field constant initialization; and custom attribute argument.
```
 	**const** ‘**(**’ _FieldReference_ ‘**)**’
```

###### _Custom_ ::=
```
 	**.custom** _Ctor_ ‘**=**’ ‘**(**’ [ _Bytes_ ] ‘**)**’
|	**.custom** _Ctor_ ‘**=**’ ‘**{**’ [ _CAArgument_ ]\* [ _CANamedArgument_ ]\* ‘**}**’
```

###### _SecurityDecl_ ::=
```
 	**.permissionset** _SecAction_ ‘**=**’ ‘**(**’ [ _Bytes_ ] ‘**)**’
|	**.permissionset** _SecAction_ ‘**=**’ ‘**{**’ [ _SecDecl_ ]\* ‘**}**’
|	**.permission** _SecAction_ ‘**=**’ ‘**(**’ [ _Bytes_ ] ‘**)**’
|	**.permission** _SecAction_ _SecDecl_
```

###### _SecAction_ ::=
```
 	**ActionNil**
|	**assert**
|	**demand**
|	**deny**
|	**inheritcheck**
|	**linkcheck**
|	**noncasdemand**
|	**noncasinheritance**
|	**noncaslinkdemand**
|	**permitonly**
|	**prejitdenied**
|	**prejitgrant**
|	**request**
|	**reqmin**
|	**reqopt**
|	**reqrefuse**
```

###### _SecDecl_ ::=
```
 	_TypeReferenceOrReflection_ ‘**=**’ ‘**{**’ [ _CANamedArgument_ ]\* ‘**}**’
```

###### _CANamedArgument_ ::=
```
 	**field** _CATypeSig_ _DottedName_ ‘**=**’ _CAArgument_
|	**property** _CATypeSig_ _DottedName_ ‘**=**’ _CAArgument_
```

###### _CATypeSig_ ::=
```
	_CATypeRef_ [ ‘**[**’ ‘**]**’ ]
```

###### _CATypeRef_ ::=
```
 	**bytearray**
|	**bool**
|	**char**
|	**float32**
|	**float64**
|	**string**
|	**object**
|	**type**
|	**enum** [ _TypeReferenceOrReflection_ ]
|	[ **unsigned** ] **int8**
|	**uint8**
|	[ **unsigned** ] **int16**
|	**uint16**
|	[ **unsigned** ] **int32**
|	**uint32**
|	[ **unsigned** ] **int64**
|	**uint64**
```

###### _CAArgument_ ::=
```
 	**object** ‘**(**’ _CAArgument_ ‘**)**’
|	**bytearray** ‘**(**’ [ _Bytes_ ] ‘**)**’
|	_ConstantFieldValue_
|	**enum** [ _TypeReferenceOrReflection_ ] _SzArrayInit_ [ ‘**{**’ [ _EnumVal_ [ ‘**,**’ _EnumVal_ ]\* ] ‘**}**’ ]
|	_TypeVal_
|	**type** _SzArrayInit_ [ ‘**{**’ [ _TypeVal_ [ ‘**,**’ _TypeVal_ ]\* ] ‘**}**’ ]
|	_Char_
|	**char** _SzArrayInit_ [ ‘**{**’ [ _Char_ [ ‘**,**’ _Char_ ]\* ] ‘**}**’ ]
|	_String_
|	**string** _SzArrayInit_ [ ‘**{**’ [ _String_ [ ‘**,**’ _String_ ]\* ] ‘**}**’ ]
|	_Bool_
|	**bool** _SzArrayInit_ [ ‘**{**’ [ _Bool [ ‘**,**’ _Bool ]\* ] ‘**}**’ ]
|	**float32** ‘**(**’ _Float32_ ‘**)**’
|	**float32** _SzArrayInit_ [ ‘**{**’ [ **float32** ‘**(**’ _Float32_ ‘**)**’ [ ‘**,**’ **float32** ‘**(**’ _Float32_ ‘**)**’ ]\* ] ‘**}**’ ]
|	**float64** ‘**(**’ _Float64_ ‘**)**’
|	**float64** _SzArrayInit_ [ ‘**{**’ [ **float64** ‘**(**’ _Float64_ ‘**)**’ [ ‘**,**’ **float64** ‘**(**’ _Float64_ ‘**)**’ ]\* ] ‘**}**’ ]
|	_UInt8_
|	**unsigned int8** _SzArrayInit_ [ ‘**{**’ [ _UInt8_ [ ‘**,**’ _UInt8_ ]\* ] ‘**}**’ ]
|	**uint8** _SzArrayInit_ [ ‘**{**’ [ _UInt8_ [ ‘**,**’ _UInt8_ ]\* ] ‘**}**’ ]
|	_Int8_
|	**int8** _SzArrayInit_ [  ‘**{**’ [ _Int8_ [ ‘**,**’ _Int8_ ]\* ] ‘**}**’ ]
|	_UInt16_
|	**unsigned int16** _SzArrayInit_ [ ‘**{**’ [ _UInt16_ [ ‘**,**’ _UInt16_ ]\* ] ‘**}**’ ]
|	**uint16** _SzArrayInit_ [ ‘**{**’ [ _UInt16_ [ ‘**,**’ _UInt16_ ]\* ] ‘**}**’ ]
|	_Int16_
|	**int16** _SzArrayInit_ [  ‘**{**’ [ _Int16_ [ ‘**,**’ _Int16_ ]\* ] ‘**}**’ ]
|	_UInt32_
|	**unsigned int32** _SzArrayInit_ [ ‘**{**’ [ _UInt32_ [ ‘**,**’ _UInt32_ ]\* ] ‘**}**’ ]
|	**uint32** _SzArrayInit_ [ ‘**{**’ [ _UInt32_ [ ‘**,**’ _UInt32_ ]\* ] ‘**}**’ ]
|	_Int32_
|	**int32** _SzArrayInit_ [  ‘**{**’ [ _Int32_ [ ‘**,**’ _Int32_ ]\* ] ‘**}**’ ]
|	_UInt64_
|	**unsigned int64** _SzArrayInit_ [ ‘**{**’ [ _UInt64_ [ ‘**,**’ _UInt64_ ]\* ] ‘**}**’ ]
|	**uint64** _SzArrayInit_ [ ‘**{**’ [ _UInt64_ [ ‘**,**’ _UInt64_ ]\* ] ‘**}**’ ]
|	_Int64_
|	**int64** _SzArrayInit_ [  ‘**{**’ [ _Int64_ [ ‘**,**’ _Int64_ ]\* ] ‘**}**’ ]
```

###### _SzArrayInit_ ::=
```
	‘**[**’ [ _Int32Literal_ ] ‘**]**’
```

###### _TypeVal_ ::=
```
 	**type** ‘**(**’ _Type_ ‘**)**’
|	**type** ‘**(**’ _TypeReferenceOrReflection_ ‘**)**’
```

###### _EnumVal_ ::=
> Must be the enum underlying type.
```
 	_UInt8_
|	_Int8_
|	_UInt16_
|	_Int16_
|	_UInt32_
|	_Int32_
|	_UInt64_
|	_Int64_
|	_ConstantFieldValue_
```

###### _Bool_ ::=
```
 	**bool** ‘**(**’ **true** | **false** ‘**)**’
|	_ConstantFieldValue_
```

###### _Char_ ::=
```
 	‘**'**’ _CharLiteral_ ‘**'**’
|	**char** ‘**(**’ ‘**'**’ _CharLiteral_ ‘**'**’ ‘**)**’
|	**char** ‘**(**’ _Int32Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _String_ ::=
```
 	_QSTRING_
|	**string** ‘**(**’ _SQSTRING_ ‘**)**’
|	_ConstantFieldValue_
```

###### _TypeReferenceOrReflection_ ::=
```
 	_TypeReference_
|	**bool**
|	**char**
|	**float32**
|	**float64**
|	**string**
|	**object**
|	**void**
|	**typedref**
|	[ **native** ] [ **unsigned** ] **int8**
|	[ **native** ] **uint8**
|	[ **native** ] [ **unsigned** ] **int16**
|	[ **native** ] **uint16**
|	[ **native** ] [ **unsigned** ] **int32**
|	[ **native** ] **uint32**
|	[ **native** ] [ **unsigned** ] **int64**
|	[ **native** ] **uint64**
|	**class** _SQSTRING_
|	**valuetype** _SQSTRING_
> _SQSTRING_ is a single-quoted string containing the assembly-qualified name of the type.
```

###### _Int8_ ::=
```
 	**int8** ‘**(**’ _Int8Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _Int16_ ::=
```
 	**int16** ‘**(**’ _Int16Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _Int32_ ::=
```
 	**int32** ‘**(**’ _Int32Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _Int64_ ::=
```
 	**int64** ‘**(**’ _Int64Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _UInt8_ ::=
```
 	[ **unsigned** ] **int8** ‘**(**’ _UInt8Literal_ ‘**)**’
|	**uint8** ‘**(**’ _UInt8Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _UInt16_ ::=
```
 	[ **unsigned** ] **int16** ‘**(**’ _UInt16Literal_ ‘**)**’
|	**uint16** ‘**(**’ _UInt16Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _UInt32_ ::=
```
 	[ **unsigned** ] **int32** ‘**(**’ _UInt32Literal_ ‘**)**’
|	**uint32** ‘**(**’ _UInt32Literal_ ‘**)**’
|	_ConstantFieldValue_
```

###### _UInt64_ ::=
```
 	[ **unsigned** ] **int64** ‘**(**’ _UInt64Literal_ ‘**)**’
|	**uint64** ‘**(**’ _UInt64Literal_ ‘**)**’
|	_ConstantFieldValue_
```

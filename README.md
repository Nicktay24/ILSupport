# IL Support
Parses CLI code and merges with your DLL using dnlib. C\# does not provide coding in CLI but this way you can code CLI alongside C\#. I knew there are other implementations but they don't all provide full CLI coding. Using ildasm and ilasm would be too slow to merge with DLL.

​**​CLI syntax​**​ is officially fully-documented [here](https://www.ecma-international.org/publications-and-standards/standards/ecma-335/).

## ​**​IMPORTANT NOTICE​**​
### ​**​MANDATORY​**​ Format For Floating-Point Literal
All ​**​floating-point literals​**​ will be parsed as followed. Many decompilers export different CLI formats for floating-point literals. Therefore, you will have to correct the format to match: ​_​Float32​_​ and ​_​Float64​_​.
### ​**​ADDED​**​
- [C++ floating-point literal](https://en.cppreference.com/w/cpp/language/floating​_​literal)
- Loading constant field values: ​_​ConstantFieldValue​_​.
- Extra format for directives: ​**​.custom​**​, ​**​.permission​**​, ​**​.permissionset​**​
### ​**​EXCLUDED​**​
- ​**​.permission​**​ ​_​SecAction​_​ ​_​TypeReference​_​ ‘​**​(​**​’ ​_​NameValPairs​_​ ‘​**​)​**​’
	> Could not figure out how to implement with dnlib but an alternatives are specified in custom format, ​_​SecurityDecl​_​.

### README Syntax
- ::\= declares a Custom Format whose name precedes ::\= and whose format is defined after.
- ​_​Italic​_​ represents a reference to a Custom Format whose name matches. If this precedes ::\= then this is a Custom Format declaration instead of a Custom Format reference.
- ​**​Bold​**​ specifies a literal.
- ‘​​’ contains a literal character.
- \| is OR operator.
- \[\] marks its contents as optional.
- \* specifies zero or more of the preceding item.
- ​_​QSTRING​_​ is double-quoted string.
- ​_​SQSTRING​_​ is single-quoted string.

## Added Syntactic Formats
| ​_​CppFloatLiteral​_​ ::\= |
|--- |
|	​_​RealNumber​_​ |
|\|	\[ ‘​**​+​**​’ \| ‘​**​-​**​’ \] ​**​inf​**​ |
|\|	\[ ‘​**​+​**​’ \| ‘​**​-​**​’ \] ​**​NaN​**​ |
> ​_​RealNumber​_​ may be the [C++ floating-point literal](https://en.cppreference.com/w/cpp/language/floating​_​literal).

| ​_​Float32​_​ ::\= |
|--- |
|	​_​CppFloatLiteral​_​ |
|\|	​**​float32​**​ ‘​**​(​**​’ ​_​Int32Literal​_​ ‘​**​)​**​’ |
|\|	​**​float32​**​ ‘​**​(​**​’ ​_​UInt32Literal​_​ ‘​**​)​**​’ |

| ​_​Float64​_​ ::\= |
|--- |
|	​_​CppFloatLiteral​_​ |
|\|	​**​float64​**​ ‘​**​(​**​’ ​_​Int64Literal​_​ ‘​**​)​**​’ |
|\|	​**​float64​**​ ‘​**​(​**​’ ​_​UInt64Literal​_​ ‘​**​)​**​’ |

| ​_​ConstantFieldValue​_​ ::\= |
|--- |
|	​**​const​**​ ‘​**​(​**​’ ​_​FieldReference​_​ ‘​**​)​**​’ |
> ​_​FieldReference​_​ must be reference to a constant field. The constant will be loaded on compile. Valid for operand of opcodes, ldfld and ldsfld; field constant initialization; and custom attribute argument. Also in the CIL instructions, you may have the operand of ​**​ldsfld​**​ be a field reference to a constant field to load the value of the constant field. E.g. ​**​Ldsfld​**​ and `uint8 uint8::MinValue` will be replaced with ​**​ldc.i4.0​**​. ​**​Ldsfld​**​ and `uint16 uint16::MaxValue` will be replaced with ​**​ldc.i4​**​ and `65535`.

| ​_​Custom​_​ ::\= |
|--- |
|	​**​.custom​**​ ​_​Ctor​_​ ‘​**​\=​**​’ ‘​**​(​**​’ \[ ​_​Bytes​_​ \] ‘​**​)​**​’ |
|\|	​**​.custom​**​ ​_​Ctor​_​ ‘​**​\=​**​’ ‘​**​\{​**​’ \[ ​_​CAArgument​_​ \]\* \[ ​_​CANamedArgument​_​ \]\* ‘​**​\}​**​’ |

| ​_​SecurityDecl​_​ ::\= |
|--- |
|	​**​.permissionset​**​ ​_​SecAction​_​ ‘​**​\=​**​’ ‘​**​(​**​’ \[ ​_​Bytes​_​ \] ‘​**​)​**​’ |
|\|	​**​.permissionset​**​ ​_​SecAction​_​ ‘​**​\=​**​’ ‘​**​\{​**​’ \[ ​_​SecDecl​_​ \]\* ‘​**​\}​**​’ |
|\|	​**​.permission​**​ ​_​SecAction​_​ ‘​**​\=​**​’ ‘​**​(​**​’ \[ ​_​Bytes​_​ \] ‘​**​)​**​’ |
|\|	​**​.permission​**​ ​_​SecAction​_​ ​_​SecDecl​_​ |

| ​_​SecAction​_​ ::\= |
|--- |
|	​**​ActionNil​**​ |
|\|	​**​assert​**​ |
|\|	​**​demand​**​ |
|\|	​**​deny​**​ |
|\|	​**​inheritcheck​**​ |
|\|	​**​linkcheck​**​ |
|\|	​**​noncasdemand​**​ |
|\|	​**​noncasinheritance​**​ |
|\|	​**​noncaslinkdemand​**​ |
|\|	​**​permitonly​**​ |
|\|	​**​prejitdenied​**​ |
|\|	​**​prejitgrant​**​ |
|\|	​**​request​**​ |
|\|	​**​reqmin​**​ |
|\|	​**​reqopt​**​ |
|\|	​**​reqrefuse​**​ |

| ​_​SecDecl​_​ ::\= |
|--- |
| 	​_​TypeReferenceOrReflection​_​ ‘​**​\=​**​’ ‘​**​\{​**​’ \[ ​_​CANamedArgument​_​ \]\* ‘​**​\}​**​’ |

| ​_​CANamedArgument​_​ ::\= |
|--- |
|	​**​field​**​ ​_​CATypeSig​_​ ​_​DottedName​_​ ‘​**​\=​**​’ ​_​CAArgument​_​ |
|\|	​**​property​**​ ​_​CATypeSig​_​ ​_​DottedName​_​ ‘​**​\=​**​’ ​_​CAArgument​_​ |

| ​_​CATypeSig​_​ ::\= |
|--- |
|	​_​CATypeRef​_​ \[ ‘​**​\[​**​’ ‘​**​\]​**​’ \] |

| ​_​CATypeRef​_​ ::\= |
|--- |
|	​**​bytearray​**​ |
|\|	​**​bool​**​ |
|\|	​**​char​**​ |
|\|	​**​float32​**​ |
|\|	​**​float64​**​ |
|\|	​**​string​**​ |
|\|	​**​object​**​ |
|\|	​**​type​**​ |
|\|	​**​enum​**​ \[ ​_​TypeReferenceOrReflection​_​ \] |
|\|	\[ ​**​unsigned​**​ \] ​**​int8​**​ |
|\|	​**​uint8​**​ |
|\|	\[ ​**​unsigned​**​ \] ​**​int16​**​ |
|\|	​**​uint16​**​ |
|\|	\[ ​**​unsigned​**​ \] ​**​int32​**​ |
|\|	​**​uint32​**​ |
|\|	\[ ​**​unsigned​**​ \] ​**​int64​**​ |
|\|	​**​uint64​**​ |

| ​_​CAArgument​_​ ::\= |
|--- |
|	​**​object​**​ ‘​**​(​**​’ ​_​CAArgument​_​ ‘​**​)​**​’ |
|\|	​**​bytearray​**​ ‘​**​(​**​’ \[ ​_​Bytes​_​ \] ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |
|\|	​**​enum​**​ \[ ​_​TypeReferenceOrReflection​_​ \] ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​EnumVal​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​TypeVal​_​ |
|\|	​**​type​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​TypeVal​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​Char​_​ |
|\|	​**​char​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​Char​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​String​_​ |
|\|	​**​string​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​String​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​Bool​_​ |
|\|	​**​bool​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​Bool \]\* ‘​**​}​**​’ \] |
|\|	​**​float32​**​ ‘​**​(​**​’ ​_​Float32​_​ ‘​**​)​**​’ |
|\|	​**​float32​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​**​float32​**​ ‘​**​(​**​’ ​_​Float32​_​ ‘​**​)​**​’ \]\* ‘​**​}​**​’ \] |
|\|	​**​float64​**​ ‘​**​(​**​’ ​_​Float64​_​ ‘​**​)​**​’ |
|\|	​**​float64​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​**​float64​**​ ‘​**​(​**​’ ​_​Float64​_​ ‘​**​)​**​’ \]\* ‘​**​}​**​’ \] |
|\|	​_​UInt8​_​ |
|\|	​**​unsigned int8​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt8​_​ \]\* ‘​**​}​**​’ \] |
|\|	​**​uint8​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt8​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​Int8​_​ |
|\|	​**​int8​**​ ​_​SzArrayInit​_​ \[  ‘​**​{​**​’ \[ ​_​Int8​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​UInt16​_​ |
|\|	​**​unsigned int16​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt16​_​ \]\* ‘​**​}​**​’ \] |
|\|	​**​uint16​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt16​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​Int16​_​ |
|\|	​**​int16​**​ ​_​SzArrayInit​_​ \[  ‘​**​{​**​’ \[ ​_​Int16​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​UInt32​_​ |
|\|	​**​unsigned int32​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt32​_​ \]\* ‘​**​}​**​’ \] |
|\|	​**​uint32​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt32​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​Int32​_​ |
|\|	​**​int32​**​ ​_​SzArrayInit​_​ \[  ‘​**​{​**​’ \[ ​_​Int32​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​UInt64​_​ |
|\|	​**​unsigned int64​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt64​_​ \]\* ‘​**​}​**​’ \] |
|\|	​**​uint64​**​ ​_​SzArrayInit​_​ \[ ‘​**​{​**​’ \[ ​_​UInt64​_​ \]\* ‘​**​}​**​’ \] |
|\|	​_​Int64​_​ |
|\|	​**​int64​**​ ​_​SzArrayInit​_​ \[  ‘​**​{​**​’ \[ ​_​Int64​_​ \]\* ‘​**​}​**​’ \] |

| ​_​SzArrayInit​_​ ::\= |
|--- |
|	‘​**​\[​**​’ \[ ​_​Int32Literal​_​ \] ‘​**​\]​**​’ |

| ​_​TypeVal​_​ ::\= |
|--- |
|	​**​type​**​ ‘​**​(​**​’ ​_​Type​_​ ‘​**​)​**​’ |
|	​**​type​**​ ‘​**​(​**​’ ​_​TypeReferenceOrReflection​_​ ‘​**​)​**​’ |

| ​_​EnumVal​_​ ::\= |
|--- |
|	​_​UInt8​_​ |
|\|	​_​Int8​_​ |
|\|	​_​UInt16​_​ |
|\|	​_​Int16​_​ |
|\|	​_​UInt32​_​ |
|\|	​_​Int32​_​ |
|\|	​_​UInt64​_​ |
|\|	​_​Int64​_​ |
|\|	​_​ConstantFieldValue​_​ |
> ​_​EnumVal​_​ must be the enum underlying type.

| ​_​Bool​_​ ::\= |
|--- |
|	​**​bool​**​ ‘​**​(​**​’ ​**​true​**​ \| ​**​false​**​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​Char​_​ ::\= |
|--- |
|	‘​**​'​**​’ ​_​CharLiteral​_​ ‘​**​'​**​’ |
|\|	​**​char​**​ ‘​**​(​**​’ ‘​**​'​**​’ ​_​CharLiteral​_​ ‘​**​'​**​’ ‘​**​)​**​’ |
|\|	​**​char​**​ ‘​**​(​**​’ ​_​Int32Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​String​_​ ::\= |
|--- |
|	​_​QSTRING​_​ |
|\|	​**​string​**​ ‘​**​(​**​’ ​_​SQSTRING​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​TypeReferenceOrReflection​_​ ::\= |
|--- |
|	​_​TypeReference​_​ |
|\|	​**​bool​**​ |
|\|	​**​char​**​ |
|\|	​**​float32​**​ |
|\|	​**​float64​**​ |
|\|	​**​string​**​ |
|\|	​**​object​**​ |
|\|	​**​void​**​ |
|\|	​**​typedref​**​ |
|\|	\[ ​**​native​**​ \] \[ ​**​unsigned​**​ \] ​**​int8​**​ |
|\|	\[ ​**​native​**​ \] ​**​uint8​**​ |
|\|	\[ ​**​native​**​ \] \[ ​**​unsigned​**​ \] ​**​int16​**​ |
|\|	\[ ​**​native​**​ \] ​**​uint16​**​ |
|\|	\[ ​**​native​**​ \] \[ ​**​unsigned​**​ \] ​**​int32​**​ |
|\|	\[ ​**​native​**​ \] ​**​uint32​**​ |
|\|	\[ ​**​native​**​ \] \[ ​**​unsigned​**​ \] ​**​int64​**​ |
|\|	\[ ​**​native​**​ \] ​**​uint64​**​ |
|\|	​**​class​**​ ​_​SQSTRING​_​ |
|\|	​**​valuetype​**​ ​_​SQSTRING​_​ |
> ​_​SQSTRING​_​ is a single-quoted string containing the assembly-qualified name of the type.

| ​_​Int8​_​ ::\= |
|--- |
|	​**​int8​**​ ‘​**​(​**​’ ​_​Int8Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​Int16​_​ ::\= |
|--- |
|	​**​int16​**​ ‘​**​(​**​’ ​_​Int16Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​Int32​_​ ::\= |
|--- |
|	​**​int32​**​ ‘​**​(​**​’ ​_​Int32Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​Int64​_​ ::\= |
|--- |
|	​**​int64​**​ ‘​**​(​**​’ ​_​Int64Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​UInt8​_​ ::\= |
|--- |
|	​**​unsigned int8​**​ ‘​**​(​**​’ ​_​UInt8Literal​_​ ‘​**​)​**​’ |
|\|	​**​uint8​**​ ‘​**​(​**​’ ​_​UInt8Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​UInt16​_​ ::\= |
|--- |
|	​**​unsigned int16​**​ ‘​**​(​**​’ ​_​UInt16Literal​_​ ‘​**​)​**​’ |
|\|	​**​uint16​**​ ‘​**​(​**​’ ​_​UInt16Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​UInt32​_​ ::\= |
|--- |
|	​**​unsigned int32​**​ ‘​**​(​**​’ ​_​UInt32Literal​_​ ‘​**​)​**​’ |
|\|	​**​uint32​**​ ‘​**​(​**​’ ​_​UInt32Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

| ​_​UInt64​_​ ::\= |
|--- |
|	​**​unsigned int64​**​ ‘​**​(​**​’ ​_​UInt64Literal​_​ ‘​**​)​**​’ |
|\|	​**​uint64​**​ ‘​**​(​**​’ ​_​UInt64Literal​_​ ‘​**​)​**​’ |
|\|	​_​ConstantFieldValue​_​ |

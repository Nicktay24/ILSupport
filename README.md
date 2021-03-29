# **​IL Support​**
### [My Patreon](https://www.patreon.com/nicktay)
Parses CLI code and merges with your DLL using dnlib. C\# does not provide coding in CLI but this way you can code CLI alongside C\#. I knew there are other implementations but they don't all provide full CLI coding. Using ildasm and ilasm would be too slow to merge with DLL. Edited [dnlib.dll](.ILSupport/dnlib.dll) so any other versions of the assembly won't work with [RedSkies.ILSupport.dll](.ILSupport/RedSkies.ILSupport.dll).

**​CLI syntax​** is officially documented [here](https://www.ecma-international.org/publications-and-standards/standards/ecma-335/).

## **​Compatibility​**
- MSBuild support using [RedSkies.ILSupport.targets](.ILSupport/RedSkies.ILSupport.targets).
- C\# \- .NET 5, .NET Core, .NET Framework, Unity, Mono
- For unity projects, set Unity property to true in .csproj file.
```xml
<PropertyGroup>
	<Unity>true</Unity>
</PropertyGroup>
```

## **​How To Use​**
- Download [.ILSupport](.ILSupport) folder. For Mac, download [.ILSupport Mac](.ILSupport Mac) folder.
- Import MSBuild project at the end of .csproj file. Ensure file name of MSBuild project is [RedSkies.ILSupport.targets](.ILSupport/RedSkies.ILSupport.targets).
```xml
<Import Project="RedSkies.ILSupport.targets" />
```
- Create .il file in project. In .csproj file, ensure the .il file is included under IL property in ItemGroup as followed:
```xml
<ItemGroup>
	<IL Include="*.il" />
</ItemGroup>
```
- Write CLI code in .il file, build project, and done!

## **​IMPORTANT​**
### **​MANDATORY Format For Floating-Point Literal​**
- All **​floating-point literals​** will be parsed as followed. Many decompilers export different CLI formats for floating-point literals. Therefore, you will have to correct the format to match: [_Float32_](#float-literals) and [_Float64_](#float-literals).
### **​NOTICE​**
- Reflection type name does not support function pointers.
- **​.custom​** applies custom attributes to the last declaration. Make sure to have each custom attribute below its respective owner.
```
.class
{
	.custom // applies to .class
	.field A
		.custom // applies to .field A
	.field B
		.custom // applies to .field B
		.custom // applies to .field B
	.method
	{
		.custom // applies to .method
		.param
			.custom // applies to .param
			.custom // applies to .param
	}
	.custom // applies to .class
	.field C
		.custom // applies to .field C
		.custom // applies to .field C
}
```
### **​ADDED​**
- [C++ floating-point literal](https://en.cppreference.com/w/cpp/language/floating_literal)
- Loading constant field values: [_ConstantFieldReference_](#constant-field-reference)
- Extra format for directives: ​**​.permission​**​](#permission-declaration), [​**​.permissionset​**​](#permission-declaration), [​**​.vtfixup​**​](#vtfixup-declaration)
### **​EXCLUDED​**
- **​.permission​** _SecAction_ _TypeReference_ ‘​**​(​**​’ _NameValPairs_ ‘​**​)​**​’
	> Use the custom formats specified below: [_SecurityDecl_](#permission-declaration).
- **​.language​**
- **​.namespace​**
- **​.vtable​**
	> Use the custom formats specified below: [_VTFixupDecl_](#vtfixup-declaration).
- **​\#LINE​**

## Syntax For Syntactic Formats Below
- _Italic_ represents a Custom Format whose name matches.
- **​Bold​** specifies a literal.
- ‘​​’ contains a literal character.
- \| is OR operator.
- \[\] marks its contents as optional.
- \* specifies zero or more of the preceding item.
- _QSTRING_ is double-quoted string.
- _SQSTRING_ is single-quoted string.

## Added Syntactic Formats
### Float Literals
| _CppFloatLiteral_ ::\= |
|--- |
|	_RealNumber_ |
|\|	\[ ‘​**​+​**​’ \| ‘​**​-​**​’ \] **​inf​** |
|\|	\[ ‘​**​+​**​’ \| ‘​**​-​**​’ \] **​NaN​** |
> _RealNumber_ is [C++ floating-point literal](https://en.cppreference.com/w/cpp/language/floating_literal).

| _Float32_ ::\= |
|--- |
|	_CppFloatLiteral_ |
|\|	**​float32​** ‘​**​(​**​’ _Int32Literal_ ‘​**​)​**​’ |
|\|	**​float32​** ‘​**​(​**​’ _UInt32Literal_ ‘​**​)​**​’ |

| _Float64_ ::\= |
|--- |
|	_CppFloatLiteral_ |
|\|	**​float64​** ‘​**​(​**​’ _Int64Literal_ ‘​**​)​**​’ |
|\|	**​float64​** ‘​**​(​**​’ _UInt64Literal_ ‘​**​)​**​’ |

### Constant Field Reference
| _ConstantFieldReference_ ::\= |
|--- |
|	**​const​** ‘​**​(​**​’ _FieldReference_ ‘​**​)​**​’ |
> _FieldReference_ must be reference to a constant field. The constant will be loaded on compile. Valid for operand of opcodes, ldfld and ldsfld; field constant initialization; and custom attribute argument. Also in the CIL instructions, you may have the operand of **​ldsfld​** be a field reference to a constant field to load the value of the constant field. E.g. **​Ldsfld​** and `uint8 uint8::MinValue` will be replaced with **​ldc.i4.0​**​. **​Ldsfld​** and `uint16 uint16::MaxValue` will be replaced with **​ldc.i4​** and `65535`.

| _SafeArrayMarshalType_ ::\= |
|--- |
|	**​safearray​** \[ _VariantType_ \] \[ ‘​**​,​**​’ _Type_ \] |
|\|	**​safearray​** \[ _VariantType_ \] \[ ‘​**​,​**​’ _QSTRING_ \] |
> Use _Type_ instead for function pointer signatures.
> _QSTRING_ is a double-quoted string containing the fully-qualified name of the type in Reflection format. Reflection does not support function pointer signatures.

| _DataInit_ ::\= |
|--- |
|	‘​**​\=​**​’ ‘​**​(​**​’ _Bytes_ ‘​**​)​**​’ |
|\|	**​at​** _DataLabel_ |
> _DataLabel_ is a label referencing a **​.data​** directive specifying the metadata tokens.

### VTFixup Declaration
| _VTFixupDecl_ ::\= |
|--- |
|	**​.vtfixup​** \[ ‘​**​\[​**​’ _Int32Literal_ ‘​**​\]​**​’ \] _VTFixupAttr_\* ‘​**​\=​**​’ ‘​**​\{​**​’ _MethodSpec_\* ‘​**​\}​**​’ |
|\|	**​.vtfixup​** \[ ‘​**​\[​**​’ _Int32Literal_ ‘​**​\]​**​’ \] _VTFixupAttr_\* _DataInit_ |
> _Int32Literal_ is the number of metadata tokens.
> It is **RECOMMENDED** to not use **.data** since metadata tokens can change per compile. This is mainly to support ildasm exports.

| _VTFixupAttr_ ::\= |
|--- |
|	**​int32​** |
|\|	**​int64​** |
|\|	**​fromunmanaged​** |
|\|	**​fromunmanaged​retainappdomain** |
|\|	**​callmostderived​** |
> _VTFixupAttr_ must be either **int32** or **int64**, and must be either **fromunmanaged** or **fromunmanagedretainappdomain**.
> **int32** is the default and specifies that each slot contains a 32-bit metadata token. **int64** specifies that each slot contains a 64-bit metadata token.

| _MethodSpec_ ::\= |
|--- |
|	_CallConv_ _Type_ \[ _TypeSpec_ ‘​**​::​**​’ \] _MethodName_ \[ ‘​**​<​**​’ _Type_ \[ ‘​**​,​**​’ _Type_ \]\* ‘​**​>​**​’ \] ‘​**​(​**​’ _Parameters_ ‘​**​)​**​’ |

| _CustomDecl_ ::\= |
|--- |
|	**​.custom​** _Ctor_ ‘​**​\=​**​’ ‘​**​\{​**​’ _CAArgument_\* _CANamedArgument_\* ‘​**​\}​**​’ |
|\|	**​.custom​** _Ctor_ ‘​**​\=​**​’ ‘​**​(​**​’ \[ _Bytes_ \] ‘​**​)​**​’ |

### Permission Declaration
| _SecurityDecl_ ::\= |
|--- |
|	**​.permissionset​** _SecAction_ ‘​**​\=​**​’ ‘​**​\{​**​’ _DeclSecurity_\* ‘​**​\}​**​’ |
|\|	**​.permissionset​** _SecAction_ ‘​**​\=​**​’ ‘​**​(​**​’ \[ _Bytes_ \] ‘​**​)​**​’ |
|\|	**​.permission​** _SecAction_ _DeclSecurity_ |
|\|	**​.permission​** _SecAction_ ‘​**​\=​**​’ ‘​**​(​**​’ \[ _Bytes_ \] ‘​**​)​**​’ |

| _SecAction_ ::\= |
|--- |
|	**​ActionNil​** |
|\|	**​assert​** |
|\|	**​demand​** |
|\|	**​deny​** |
|\|	**​inheritcheck​** |
|\|	**​linkcheck​** |
|\|	**​noncasdemand​** |
|\|	**​noncasinheritance​** |
|\|	**​noncaslinkdemand​** |
|\|	**​permitonly​** |
|\|	**​prejitdenied​** |
|\|	**​prejitgrant​** |
|\|	**​request​** |
|\|	**​reqmin​** |
|\|	**​reqopt​** |
|\|	**​reqrefuse​** |

| _DeclSecurity_ ::\= |
|--- |
| 	_TypeReferenceOrReflectionSQ_ ‘​**​\=​**​’ ‘​**​\{​**​’ _CANamedArgument_\* ‘​**​\}​**​’ |

| _CANamedArgument_ ::\= |
|--- |
|	**​field​** _CAType_ _DottedName_ ‘​**​\=​**​’ _CAArgument_ |
|\|	**​property​** _CAType_ _DottedName_ ‘​**​\=​**​’ _CAArgument_ |

| _CAType_ ::\= |
|--- |
|	**​bytearray​** |
|\|	**​bool​** |
|\|	**​char​** |
|\|	**​float32​** |
|\|	**​float64​** |
|\|	**​string​** |
|\|	**​object​** |
|\|	**​type​** |
|\|	**​enum​** \[ _TypeReferenceOrReflectionSQ_ \] |
|\|	\[ **​unsigned​** \] **​int8​** |
|\|	**​uint8​** |
|\|	\[ **​unsigned​** \] **​int16​** |
|\|	**​uint16​** |
|\|	\[ **​unsigned​** \] **​int32​** |
|\|	**​uint32​** |
|\|	\[ **​unsigned​** \] **​int64​** |
|\|	**​uint64​** |
|\|	_CAType_ ‘​**​\[​**​’ ‘​**​\]​**​’ |

| _CAArgument_ ::\= |
|--- |
|	**​nullref​** |
|	**​object​** ‘​**​(​**​’ _CAArgument_ ‘​**​)​**​’ |
|\|	**​bytearray​** ‘​**​(​**​’ \[ _Bytes_ \] ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |
|\|	**​enum​** \[ _TypeReferenceOrReflectionSQ_ \] _SzArrayInit_ \[ ‘​**​{​**​’ _EnumVal_\* ‘​**​}​**​’ \] |
|\|	_TypeVal_ |
|\|	**​type​** _SzArrayInit_ \[ ‘​**​{​**​’ _TypeVal_\* ‘​**​}​**​’ \] |
|\|	_Char_ |
|\|	**​char​** _SzArrayInit_ \[ ‘​**​{​**​’ _Char_\* ‘​**​}​**​’ \] |
|\|	_String_ |
|\|	**​string​** _SzArrayInit_ \[ ‘​**​{​**​’ _String_\* ‘​**​}​**​’ \] |
|\|	_Bool_ |
|\|	**​bool​** _SzArrayInit_ \[ ‘​**​{​**​’ _Bool_\* ‘​**​}​**​’ \] |
|\|	**​float32​** ‘​**​(​**​’ _Float32_ ‘​**​)​**​’ |
|\|	**​float32​** _SzArrayInit_ \[ ‘​**​{​**​’ \[ **​float32​** ‘​**​(​**​’ _Float32_ ‘​**​)​**​’ \]\* ‘​**​}​**​’ \] |
|\|	**​float64​** ‘​**​(​**​’ _Float64_ ‘​**​)​**​’ |
|\|	**​float64​** _SzArrayInit_ \[ ‘​**​{​**​’ \[ **​float64​** ‘​**​(​**​’ _Float64_ ‘​**​)​**​’ \]\* ‘​**​}​**​’ \] |
|\|	_UInt8_ |
|\|	**​unsigned int8​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt8_\* ‘​**​}​**​’ \] |
|\|	**​uint8​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt8_\* ‘​**​}​**​’ \] |
|\|	_Int8_ |
|\|	**​int8​** _SzArrayInit_ \[  ‘​**​{​**​’ _Int8_\* ‘​**​}​**​’ \] |
|\|	_UInt16_ |
|\|	**​unsigned int16​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt16_\* ‘​**​}​**​’ \] |
|\|	**​uint16​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt16_\* ‘​**​}​**​’ \] |
|\|	_Int16_ |
|\|	**​int16​** _SzArrayInit_ \[  ‘​**​{​**​’ _Int16_\* ‘​**​}​**​’ \] |
|\|	_UInt32_ |
|\|	**​unsigned int32​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt32_\* ‘​**​}​**​’ \] |
|\|	**​uint32​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt32_\* ‘​**​}​**​’ \] |
|\|	_Int32_ |
|\|	**​int32​** _SzArrayInit_ \[  ‘​**​{​**​’ _Int32_\* ‘​**​}​**​’ \] |
|\|	_UInt64_ |
|\|	**​unsigned int64​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt64_\* ‘​**​}​**​’ \] |
|\|	**​uint64​** _SzArrayInit_ \[ ‘​**​{​**​’ _UInt64_\* ‘​**​}​**​’ \] |
|\|	_Int64_ |
|\|	**​int64​** _SzArrayInit_ \[  ‘​**​{​**​’ _Int64_\* ‘​**​}​**​’ \] |

| _SzArrayInit_ ::\= |
|--- |
|	‘​**​\[​**​’ \[ _Int32Literal_ \] ‘​**​\]​**​’ |

| _TypeVal_ ::\= |
|--- |
|	**​type​** ‘​**​(​**​’ _Type_ ‘​**​)​**​’ |
|	**​type​** ‘​**​(​**​’ _TypeReferenceOrReflectionSQ_ ‘​**​)​**​’ |
> Use _Type_ instead for function pointer signatures.

| _EnumVal_ ::\= |
|--- |
|	_UInt8_ |
|\|	_Int8_ |
|\|	_UInt16_ |
|\|	_Int16_ |
|\|	_UInt32_ |
|\|	_Int32_ |
|\|	_UInt64_ |
|\|	_Int64_ |
|\|	_ConstantFieldReference_ |
> _EnumVal_ must be the enum underlying type.

| _Bool_ ::\= |
|--- |
|	**​bool​** ‘​**​(​**​’ **​true​** \| **​false​** ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _Char_ ::\= |
|--- |
|	‘​**​'​**​’ _CharLiteral_ ‘​**​'​**​’ |
|\|	**​char​** ‘​**​(​**​’ ‘​**​'​**​’ _CharLiteral_ ‘​**​'​**​’ ‘​**​)​**​’ |
|\|	**​char​** ‘​**​(​**​’ _Int32Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _String_ ::\= |
|--- |
|	_QSTRING_ |
|\|	**​string​** ‘​**​(​**​’ _SQSTRING_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _TypeReferenceOrReflectionSQ_ ::\= |
|--- |
|	_TypeReference2_ |
|\|	**​class​** _SQSTRING_ |
|\|	**​valuetype​** _SQSTRING_ |
> _SQSTRING_ is a single-quoted string containing the fully-qualified name of the type in Reflection format. Reflection does support function pointer signatures.

| _TypeReference2_ ::\= |
|--- |
|	_TypeReference_ |
|\|	**​bool​** |
|\|	**​char​** |
|\|	**​float32​** |
|\|	**​float64​** |
|\|	**​string​** |
|\|	**​object​** |
|\|	**​void​** |
|\|	**​typedref​** |
|\|	\[ **​native​** \] \[ **​unsigned​** \] **​int​** |
|\|	\[ **​native​** \] **​uint​** |
|\|	\[ **​unsigned​** \] **​int8​** |
|\|	**​uint8​** |
|\|	\[ **​unsigned​** \] **​int16​** |
|\|	**​uint16​** |
|\|	\[ **​unsigned​** \] **​int32​** |
|\|	**​uint32​** |
|\|	\[ **​unsigned​** \] **​int64​** |
|\|	**​uint64​** |

| _Int8_ ::\= |
|--- |
|	**​int8​** ‘​**​(​**​’ _Int8Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _Int16_ ::\= |
|--- |
|	**​int16​** ‘​**​(​**​’ _Int16Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _Int32_ ::\= |
|--- |
|	**​int32​** ‘​**​(​**​’ _Int32Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _Int64_ ::\= |
|--- |
|	**​int64​** ‘​**​(​**​’ _Int64Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _UInt8_ ::\= |
|--- |
|	**​unsigned int8​** ‘​**​(​**​’ _UInt8Literal_ ‘​**​)​**​’ |
|\|	**​uint8​** ‘​**​(​**​’ _UInt8Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _UInt16_ ::\= |
|--- |
|	**​unsigned int16​** ‘​**​(​**​’ _UInt16Literal_ ‘​**​)​**​’ |
|\|	**​uint16​** ‘​**​(​**​’ _UInt16Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _UInt32_ ::\= |
|--- |
|	**​unsigned int32​** ‘​**​(​**​’ _UInt32Literal_ ‘​**​)​**​’ |
|\|	**​uint32​** ‘​**​(​**​’ _UInt32Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

| _UInt64_ ::\= |
|--- |
|	**​unsigned int64​** ‘​**​(​**​’ _UInt64Literal_ ‘​**​)​**​’ |
|\|	**​uint64​** ‘​**​(​**​’ _UInt64Literal_ ‘​**​)​**​’ |
|\|	_ConstantFieldReference_ |

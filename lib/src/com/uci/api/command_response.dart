//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'command_response.g.dart';

/// CommandResponse
///
/// Properties:
/// * [engineResult] 
/// * [error] 
/// * [errorString] 
@BuiltValue()
abstract class CommandResponse implements Built<CommandResponse, CommandResponseBuilder> {
  @BuiltValueField(wireName: r'engineResult')
  BuiltList<String>? get engineResult;

  @BuiltValueField(wireName: r'error')
  bool? get error;

  @BuiltValueField(wireName: r'errorString')
  BuiltList<String>? get errorString;

  CommandResponse._();

  factory CommandResponse([void updates(CommandResponseBuilder b)]) = _$CommandResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommandResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommandResponse> get serializer => _$CommandResponseSerializer();
}

class _$CommandResponseSerializer implements PrimitiveSerializer<CommandResponse> {
  @override
  final Iterable<Type> types = const [CommandResponse, _$CommandResponse];

  @override
  final String wireName = r'CommandResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommandResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.engineResult != null) {
      yield r'engineResult';
      yield serializers.serialize(
        object.engineResult,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType(bool),
      );
    }
    if (object.errorString != null) {
      yield r'errorString';
      yield serializers.serialize(
        object.errorString,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommandResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommandResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'engineResult':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.engineResult.replace(valueDes);
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.error = valueDes;
          break;
        case r'errorString':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.errorString.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommandResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommandResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


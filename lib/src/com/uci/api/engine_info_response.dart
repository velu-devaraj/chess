//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'engine.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'engine_info_response.g.dart';

/// EngineInfoResponse
///
/// Properties:
/// * [engine] 
@BuiltValue()
abstract class EngineInfoResponse implements Built<EngineInfoResponse, EngineInfoResponseBuilder> {
  @BuiltValueField(wireName: r'engine')
  Engine? get engine;

  EngineInfoResponse._();

  factory EngineInfoResponse([void updates(EngineInfoResponseBuilder b)]) = _$EngineInfoResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EngineInfoResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EngineInfoResponse> get serializer => _$EngineInfoResponseSerializer();
}

class _$EngineInfoResponseSerializer implements PrimitiveSerializer<EngineInfoResponse> {
  @override
  final Iterable<Type> types = const [EngineInfoResponse, _$EngineInfoResponse];

  @override
  final String wireName = r'EngineInfoResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EngineInfoResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.engine != null) {
      yield r'engine';
      yield serializers.serialize(
        object.engine,
        specifiedType: const FullType(Engine),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EngineInfoResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EngineInfoResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'engine':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Engine),
          ) as Engine;
          result.engine.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EngineInfoResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EngineInfoResponseBuilder();
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


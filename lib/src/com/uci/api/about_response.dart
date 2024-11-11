//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'about.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'about_response.g.dart';

/// AboutResponse
///
/// Properties:
/// * [about] 
@BuiltValue()
abstract class AboutResponse implements Built<AboutResponse, AboutResponseBuilder> {
  @BuiltValueField(wireName: r'about')
  About? get about;

  AboutResponse._();

  factory AboutResponse([void updates(AboutResponseBuilder b)]) = _$AboutResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AboutResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AboutResponse> get serializer => _$AboutResponseSerializer();
}

class _$AboutResponseSerializer implements PrimitiveSerializer<AboutResponse> {
  @override
  final Iterable<Type> types = const [AboutResponse, _$AboutResponse];

  @override
  final String wireName = r'AboutResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AboutResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.about != null) {
      yield r'about';
      yield serializers.serialize(
        object.about,
        specifiedType: const FullType(About),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AboutResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AboutResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'about':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(About),
          ) as About;
          result.about.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AboutResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AboutResponseBuilder();
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


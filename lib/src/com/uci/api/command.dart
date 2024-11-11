//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'command.g.dart';

/// Command
///
/// Properties:
/// * [commandString] 
@BuiltValue()
abstract class Command implements Built<Command, CommandBuilder> {
  @BuiltValueField(wireName: r'commandString')
  BuiltList<String>? get commandString;

  Command._();

  factory Command([void updates(CommandBuilder b)]) = _$Command;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommandBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Command> get serializer => _$CommandSerializer();
}

class _$CommandSerializer implements PrimitiveSerializer<Command> {
  @override
  final Iterable<Type> types = const [Command, _$Command];

  @override
  final String wireName = r'Command';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Command object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.commandString != null) {
      yield r'commandString';
      yield serializers.serialize(
        object.commandString,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Command object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommandBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'commandString':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.commandString.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Command deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommandBuilder();
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


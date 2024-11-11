//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'date_serializer.dart';
import 'com/uci/api/date.dart';

import 'com/uci/api/about.dart';
import 'com/uci/api/about_response.dart';
import 'com/uci/api/command.dart';
import 'com/uci/api/command_response.dart';
import 'com/uci/api/engine.dart';
import 'com/uci/api/engine_info_response.dart';

part 'serializers.g.dart';

@SerializersFor([
  About,
  AboutResponse,
  Command,
  CommandResponse,
  Engine,
  EngineInfoResponse,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

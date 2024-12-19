import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part '../src/server_config.g.dart';

class PropertyKeys {
  static final String uciServerScheme = "uci.server.scheme";
  static final String uciServerHost = "uci.server.host";
  static final String uciServerPort = "uci.server.port";
  static final String uciServerBasePath = "uci.server.base.path";  
  static final String moveDelay = "move.delay";
  static final String selectionToMoveDelay = "selection.to.move.delay";
  static final String maxDepth = "max.depth";
  static final String maxNodes = "max.nodes";
}

@JsonSerializable(explicitToJson: true)
class ServerConfig {
  String name = "ServerConfig";

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String> propertyKeys = [
    PropertyKeys.uciServerScheme,
    PropertyKeys.uciServerHost,
    PropertyKeys.uciServerPort,
    PropertyKeys.uciServerBasePath,
    PropertyKeys.moveDelay,
    PropertyKeys.selectionToMoveDelay,
    PropertyKeys.maxDepth,
    PropertyKeys.maxDepth
  ];

  Map<String, Property> properties = Map<String, Property>();

  ServerConfig() {}

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ServerConfigToJson(this);

  String getKey() {
    return "ServerConfig:" + name;
  }

  Property? getProperty(String propertyKey) {
    return properties[propertyKey];
  }

  int getPropertyAsInt(String propertyKey) {
    return properties[propertyKey]!.asInt();
  }

  String getPropertyAsString(String propertyKey) {
    return properties[propertyKey]!.value![0];
  }
}

@JsonSerializable(explicitToJson: true)
class Property {
  String? name;
  List<String>? value;
  String? type;
  Property() {}
  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyToJson(this);

  int asInt() {
    return int.parse(value![0]);
  }
}

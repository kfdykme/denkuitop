///
//  Generated code. Do not modify.
//  source: ipc.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class IpcInvoke extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('IpcInvoke', createEmptyInstance: create)
    ..aQS(1, 'module')
    ..aQS(2, 'method')
  ;

  IpcInvoke._() : super();
  factory IpcInvoke() => create();
  factory IpcInvoke.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IpcInvoke.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  IpcInvoke clone() => IpcInvoke()..mergeFromMessage(this);
  IpcInvoke copyWith(void Function(IpcInvoke) updates) => super.copyWith((message) => updates(message as IpcInvoke));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static IpcInvoke create() => IpcInvoke._();
  IpcInvoke createEmptyInstance() => create();
  static $pb.PbList<IpcInvoke> createRepeated() => $pb.PbList<IpcInvoke>();
  @$core.pragma('dart2js:noInline')
  static IpcInvoke getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IpcInvoke>(create);
  static IpcInvoke _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get module => $_getSZ(0);
  @$pb.TagNumber(1)
  set module($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasModule() => $_has(0);
  @$pb.TagNumber(1)
  void clearModule() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get method => $_getSZ(1);
  @$pb.TagNumber(2)
  set method($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMethod() => $_has(1);
  @$pb.TagNumber(2)
  void clearMethod() => clearField(2);
}


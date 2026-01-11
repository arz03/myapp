// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
  studentName: json['studentName'] as String,
  topic: json['topic'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$ClassToJson(Class instance) => <String, dynamic>{
  'studentName': instance.studentName,
  'topic': instance.topic,
  'date': instance.date.toIso8601String(),
};

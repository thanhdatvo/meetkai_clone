library suggested_movie_modal;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';

part 'suggested_movie.g.dart';

abstract class SuggestedMovie
    implements Built<SuggestedMovie, SuggestedMovieBuilder> {
  SuggestedMovie._();

  factory SuggestedMovie([updates(SuggestedMovieBuilder b)]) = _$SuggestedMovie;

  @nullable
  @BuiltValueField(wireName: 'id')
  int get id;

  @nullable
  @BuiltValueField(wireName: 'title')
  String get title;

  @nullable
  @BuiltValueField(wireName: 'est')
  double get est;

  String toJson() {
    return json
        .encode(serializers.serializeWith(SuggestedMovie.serializer, this));
  }

  static SuggestedMovie fromJson(String jsonString) {
    return serializers.deserializeWith(
        SuggestedMovie.serializer, json.decode(jsonString));
  }

  static Serializer<SuggestedMovie> get serializer =>
      _$suggestedMovieSerializer;
}

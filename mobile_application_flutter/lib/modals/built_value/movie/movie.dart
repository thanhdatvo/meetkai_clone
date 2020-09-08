library movie_modal;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';

part 'movie.g.dart';

abstract class Movie implements Built<Movie, MovieBuilder> {
  Movie._();

  factory Movie([updates(MovieBuilder b)]) = _$Movie;

  @nullable
  @BuiltValueField(wireName: 'id')
  String get id;
  @nullable
  @BuiltValueField(wireName: 'est')
  double get est;
  @nullable
  @BuiltValueField(wireName: 'imdb_id')
  String get imdb_id;
  @nullable
  @BuiltValueField(wireName: 'overview')
  String get overview;
  @nullable
  @BuiltValueField(wireName: 'genre')
  String get genre;
  @nullable
  @BuiltValueField(wireName: 'poster')
  String get poster;
  @nullable
  @BuiltValueField(wireName: 'releasedYear')
  String get releasedYear;
  @nullable
  @BuiltValueField(wireName: 'title')
  String get title;
  @nullable
  @BuiltValueField(wireName: 'vote_average')
  String get voteAverage;
  @nullable
  @BuiltValueField(wireName: 'runtime')
  String get runtime;

  String toJson() {
    return json.encode(serializers.serializeWith(Movie.serializer, this));
  }

  static Movie fromJson(String jsonString) {
    return serializers.deserializeWith(
        Movie.serializer, json.decode(jsonString));
  }

  static Serializer<Movie> get serializer => _$movieSerializer;
}

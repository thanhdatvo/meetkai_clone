import 'dart:async';
import 'package:built_stream/stream_annotations.dart';
import 'package:built_stream/stream_types.dart';
import 'package:customized_streams/customized_streams.dart';

import 'package:flutter_meet_kai_clone/modals/built_value/movie/movie.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/suggested_movie/suggested_movie.dart';
import 'package:flutter_meet_kai_clone/respositories/movie_respository.dart';

part "read_movies_stream.g.dart";

@SingleStream(MovieRespository, 'readMultiple')
@StreamParam('List<SuggestedMovie>', 'suggestedMovies')
@StreamResult('List<Movie>', 'movies')
class ReadMoviesStream extends _ReadMoviesStreamOrigin {
  @override
  String get errorMessage => 'Cannot read movies';
}

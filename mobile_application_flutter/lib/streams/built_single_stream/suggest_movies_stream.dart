import 'dart:async';
import 'package:built_stream/stream_annotations.dart';
import 'package:built_stream/stream_types.dart';
import 'package:customized_streams/customized_streams.dart';

import 'package:flutter_meet_kai_clone/modals/built_value/suggested_movie/suggested_movie.dart';
import 'package:flutter_meet_kai_clone/respositories/movie_respository.dart';

part 'suggest_movies_stream.g.dart';

@SingleStream(MovieRespository, 'suggestMovies')
@StreamParam('int', 'userId')
@StreamParam('String', 'movieTitle')
@StreamResult('List<SuggestedMovie>', 'movies')
class SuggestMoviesStream extends _SuggestMoviesStreamOrigin {
  @override
  String get errorMessage => 'Cannot suggest movies';
}

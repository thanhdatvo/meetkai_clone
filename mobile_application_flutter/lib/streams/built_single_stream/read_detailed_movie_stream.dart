import 'dart:async';
import 'package:built_stream/stream_annotations.dart';
import 'package:built_stream/stream_types.dart';
import 'package:customized_streams/customized_streams.dart';

import 'package:flutter_meet_kai_clone/modals/built_value/movie/movie.dart';
import 'package:flutter_meet_kai_clone/respositories/movie_respository.dart';

part 'read_detailed_movie_stream.g.dart';

@SingleStream(MovieRespository, 'readDetailedOne')
@StreamParam('Movie', 'movie')
@StreamResult('Movie', 'detailedMovie')
class ReadDetailedMovieStream extends _ReadDetailedMovieStreamOrigin {
  @override
  String get errorMessage => 'Cannot read detailed movie';
}

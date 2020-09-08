import 'package:dio/dio.dart';
import 'package:flutter_meet_kai_clone/streams/built_single_stream/read_detailed_movie_stream.dart';
import 'package:flutter_meet_kai_clone/streams/built_single_stream/read_movies_stream.dart';
import 'package:flutter_meet_kai_clone/predefined/local_config.dart';
import 'package:flutter_meet_kai_clone/predefined/network.dart';

class MovieApiProvider {
  Future<Response> readMultiple(ReadMoviesParams params) async {
    String idsQueryString = params.suggestedMovies
        .map<int>((suggestedMovie) => suggestedMovie.id)
        .join('&movieIds=');
    return Network().request(
        HttpMethod.get, '${LocalConfig.backendAPI}/movies?$idsQueryString');
  }

  Future<Response> readDetailedOne(ReadDetailedMovieParams params) async {
    String imbdID = params.movie.imdb_id;
    return Network().request(
        HttpMethod.get, 'http://www.omdbapi.com/?i=$imbdID&apikey=ce762116');
  }
}

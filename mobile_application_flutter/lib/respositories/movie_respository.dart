import 'package:flutter_meet_kai_clone/streams/built_single_stream/read_detailed_movie_stream.dart';
import 'package:flutter_meet_kai_clone/streams/built_single_stream/read_movies_stream.dart';
import 'package:flutter_meet_kai_clone/streams/built_single_stream/suggest_movies_stream.dart';
import 'package:flutter_meet_kai_clone/data_providers/api_providers/movie_api_provider.dart';
import 'package:flutter_meet_kai_clone/data_providers/grpc_providers/movie_grpc_provider.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/movie/movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/suggested_movie/suggested_movie.dart';
import 'package:flutter_meet_kai_clone/modals/grpc_protos/advice_service.pbgrpc.dart';

class MovieRespository {
  MovieApiProvider _apiProvider = MovieApiProvider();
  SuggestedMoviesGRPCProvider _grpcProvider = SuggestedMoviesGRPCProvider();

  Future<ReadMoviesResults> readMultiple(ReadMoviesParams params) async {
    Response res = await _apiProvider.readMultiple(params);

    List<Movie> movies = res.data
        .map<Movie>((data) => Movie().rebuild((m) {
              SuggestedMovie correspondedSuggestedMovie = params.suggestedMovies
                  .firstWhere(
                      (suggestedMovie) =>
                          suggestedMovie.id == int.tryParse(data['id']),
                      orElse: () => null);

              return m
                ..est = correspondedSuggestedMovie?.est
                ..imdb_id = data['imdb_id']
                ..title = data['title']
                ..runtime = data['runtime']
                ..voteAverage = data['vote_average']
                ..releasedYear = data['release_date'].substring(0, 4);
            }))
        .toList();
    return ReadMoviesResults(movies);
  }

  Future<ReadDetailedMovieResults> readDetailedOne(
      ReadDetailedMovieParams params) async {
    Response res = await _apiProvider.readDetailedOne(params);
    Movie detailedMovie = params.movie.rebuild((m) => m
      ..genre = res.data['Genre']
      ..poster = res.data['Poster']);

    return ReadDetailedMovieResults(detailedMovie);
  }

  Future<SuggestMoviesResults> suggestMovies(SuggestMoviesParams params) async {
    Answer answer = await _grpcProvider.readMultiple(params);
    List<SuggestedMovie> suggestedMovies = answer.rates
        .map<SuggestedMovie>((rate) => SuggestedMovie().rebuild((m) => m
          ..id = rate.id
          ..title = rate.title
          ..est = rate.est))
        .toList();

    return SuggestMoviesResults(suggestedMovies);
  }
}

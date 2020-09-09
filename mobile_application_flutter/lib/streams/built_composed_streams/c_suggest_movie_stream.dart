import 'package:built_stream/stream_annotations.dart';
import 'package:built_stream/stream_types.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/movie/movie.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/suggested_movie/suggested_movie.dart';
import 'package:flutter_meet_kai_clone/streams/built_single_stream/read_detailed_movie_stream.dart';
import 'package:flutter_meet_kai_clone/streams/built_single_stream/read_movies_stream.dart';
import 'package:flutter_meet_kai_clone/streams/built_single_stream/suggest_movies_stream.dart';
import 'package:customized_streams/customized_streams.dart';
import 'package:rxdart/rxdart.dart';

part "c_suggest_movie_stream.g.dart";

@ComposedStreams(const [
  SuggestMoviesStream,
  ReadMoviesStream,
  ReadDetailedMovieStream,
])
@StreamParam('int', 'userId')
@StreamParam('String', 'movieTitle')
@StreamResult('List<Movie>', 'movies')
class CSuggestMoviesStream extends _CSuggestMoviesStreamOrigin {
  @override
  Stream<StreamState> process(CSuggestMoviesParams params) async* {
    ErrorLocation errorLocation =
        ErrorLocation(this.runtimeType, "Could not completely suggest movie");
    yield CSuggestMoviesStart();

    try {
      // LOAD SUGGESTED MOVIES
      List<SuggestedMovie> suggestedMovies;
      await for (StreamState state in _suggestMoviesStream
          .process(SuggestMoviesParams(params.userId, params.movieTitle))) {
        if (state is SuggestMoviesError) {
          yield CSuggestMoviesError.composeLocation(state, errorLocation);
          return;
        }
        if (state is SuggestMoviesSucceed) {
          suggestedMovies = state.results.movies;
        }
        yield state;
      }

      // LOAD MOVIES FROM MOVIE_IDS
      List<Movie> movies;
      await for (StreamState state
          in _readMoviesStream.process(ReadMoviesParams(suggestedMovies))) {
        if (state is ReadMoviesError) {
          yield CSuggestMoviesError.composeLocation(state, errorLocation);
          return;
        }
        if (state is ReadMoviesSucceed) {
          movies = state.results.movies;
        }
        yield state;
      }

      // LOAD DETAILED MOVIES FROM MOVIES
      List<Stream> fetchDetailedMoviesStreams = movies
          .map<Stream>((movie) =>
              _readDetailedMovieStream.process(ReadDetailedMovieParams(movie)))
          .toList();

      Stream paralleledStream = Rx.merge(fetchDetailedMoviesStreams);
      movies = [];
      await for (StreamState state in paralleledStream) {
        if (state is ReadDetailedMovieError) {
          yield CSuggestMoviesError.composeLocation(state, errorLocation);
          return;
        }
        if (state is ReadDetailedMovieSucceed) {
          movies.add(state.results.detailedMovie);
        }
        yield state;
      }
      
      yield CSuggestMoviesSucceed(CSuggestMoviesResults(movies));
    } catch (error) {
      yield CSuggestMoviesError.init(errorLocation, error, params);
    }
  }
}

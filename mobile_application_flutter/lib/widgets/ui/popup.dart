import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/movie/movie.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/v_box.dart';

import 'h_box.dart';

const _IMG_URL =
    'https://cdn.prime1studio.com/media/catalog/product/cache/1/thumbnail/9df78eab33525d08d6e5fb8d27136e95/h/d/hdmmdc-02_a19.jpg';

var _cyan = Colors.cyanAccent.shade700;
const _MIN_SCROLL_APPEAR = -100;

class PopUp extends StatefulWidget {
  final Function onHide;
  final double fullHeight;
  const PopUp({Key key, @required this.onHide, @required this.fullHeight})
      : super(key: key);
  @override
  PopUpState createState() => PopUpState();
}

class PopUpState extends State<PopUp> {
  ScrollController _scrollController;
  bool _isDisappearing;
  List<Movie> _movies;

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController();
    _isDisappearing = false;
    _movies = [];
  }

  setMovies(List<Movie> movies) {
    setState(() {
      _movies = movies;
    });
  }

  startHiding() {
    if (_isDisappearing == false) {
      setState(() {
        _isDisappearing = true;
      });
    }
  }

  endShowing() {
    setState(() {
      _isDisappearing = false;
    });
  }

  bool _onScroll(ScrollNotification scrollNotification) {
    if (_scrollController.offset < _MIN_SCROLL_APPEAR) {
      widget.onHide();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_movies.length == 0) return SizedBox();
    Movie mainMovie = _movies[0];
    List<Movie> otherMovies =
        _movies.where((movie) => movie.imdb_id != mainMovie.imdb_id).toList();
    return Container(
      height: widget.fullHeight,
      decoration: BoxDecoration(
          color: _isDisappearing
              ? Colors.transparent
              : Colors.black.withOpacity(0.5)),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: widget.fullHeight / 3,
                  color: Colors.transparent,
                ),
                onTap: widget.onHide,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    _MovieBanner(mainMovie.poster),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MovieInfo(mainMovie),
                          VBox(15),
                          const _WatchMoreButton(),
                          VBox(15),
                          _OtherOptions(otherMovies),
                          VBox(15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtherOptions extends StatelessWidget {
  final List<Movie> otherMovies;
  const _OtherOptions(this.otherMovies);
  @override
  Widget build(BuildContext context) {
    List<Widget> otherMovieWidgets = otherMovies
        .map<Widget>((movie) => Row(
              children: [
                _OtherOptionsItem(movie),
                HBox(10),
              ],
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Other options",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        VBox(5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: otherMovieWidgets,
          ),
        ),
      ],
    );
  }
}

class _OtherOptionsItem extends StatelessWidget {
  final Movie movie;
  const _OtherOptionsItem(this.movie);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(movie.poster),
            ),
          ),
        ),
        VBox(3),
        Text(
          "${movie.title}          ".substring(0, 10),
          style: TextStyle(
            fontSize: 14,
            color: _cyan,
          ),
        ),
      ],
    );
  }
}

class _WatchMoreButton extends StatelessWidget {
  const _WatchMoreButton();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Text(
          'Watch now!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {},
    );
  }
}

class _MovieInfo extends StatelessWidget {
  final Movie movie;
  const _MovieInfo(this.movie);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          movie.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          movie.genre,
          style: TextStyle(fontSize: 14),
        ),
        Text(
          '${movie.releasedYear} | ${movie.runtime} min',
          style: TextStyle(fontSize: 14),
        ),
        Row(
          children: [
            _RatingStars(
              rating: double.tryParse(movie.voteAverage) ?? 0,
            ),
            Text(
              'Aggrated score ${(100 - movie.est).toStringAsFixed(2)}%',
              style: TextStyle(
                  fontSize: 14, color: _cyan, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ],
    );
  }
}

class _MovieBanner extends StatelessWidget {
  final String posterUrl;
  const _MovieBanner(this.posterUrl);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(posterUrl),
        ),
        color: Colors.grey,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  const _RatingStars({this.rating});
  @override
  Widget build(BuildContext context) {
    int intRating = rating.floor();
    List<Widget> starWidgets = [];
    for (int i = 0; i < intRating; i++) {
      starWidgets.add(const _IconStar());
    }
    if (intRating < rating.ceil()) {
      starWidgets.add(const _IconStar(
        isHalf: true,
      ));
    }
    return Row(
      children: starWidgets,
    );
  }
}

class _IconStar extends StatelessWidget {
  final bool isHalf;
  const _IconStar({this.isHalf: false});
  @override
  Widget build(BuildContext context) {
    return Icon(
      isHalf ? Icons.star_half : Icons.star,
      color: _cyan,
      size: 18,
    );
  }
}

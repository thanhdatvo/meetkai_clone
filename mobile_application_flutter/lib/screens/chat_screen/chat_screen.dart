import 'package:after_layout/after_layout.dart';
import 'package:built_stream/stream_types.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/movie/movie.dart';
import 'package:flutter_meet_kai_clone/streams/built_composed_streams/c_suggest_movie_stream.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_border_radius.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_colors.dart';
import 'package:flutter_meet_kai_clone/widgets/overlays/loading_overlay.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/popup.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/touchable_icon.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/v_box.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen();
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  CSuggestMoviesBloc _cSuggestMoviesBloc;
  GlobalKey<__PopUpAnimatorState> _popUpAnimatorKey;
  GlobalKey<PopUpState> _popUpKey;
  GlobalKey<LoadingOverlayState> _loadingOverlayKey;

  bool _overlayShown = false;
  OverlayEntry _entry;

  @override
  void initState() {
    super.initState();

    _popUpAnimatorKey = GlobalKey();
    _popUpKey = GlobalKey();
    _loadingOverlayKey = GlobalKey();

    _cSuggestMoviesBloc = CSuggestMoviesBloc();
    _cSuggestMoviesBloc.cSuggestMoviesSubject.outputStream
        .listen((StreamState state) {
      try {
        if (_loadingOverlayKey.currentState != null) {
          _loadingOverlayKey.currentState
              .setContent(state.toString().replaceAll("Instance of ", ""));
        }

        if (state is CSuggestMoviesSucceed) {
          handleSuccess(state.results.movies);
        } else if (state is CSuggestMoviesError) {
          handleFailure(state.error);
        }
        if (state is CSuggestMoviesSucceed || state is CSuggestMoviesError) {
          _toggleLoading();
        }
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void dispose() {
    _cSuggestMoviesBloc.dispose();
    super.dispose();
  }

  _toggleLoading() {
    print("toogle");
    if (!_overlayShown) {
      _entry = OverlayEntry(builder: (context) {
        return LoadingOverlay(key: _loadingOverlayKey);
      });
      Overlay.of(context).insert(_entry);
    } else if (_entry != null) {
      _entry.remove();
    }
    _overlayShown = !_overlayShown;
  }

  suggestMovies() {
    _toggleLoading();
    _cSuggestMoviesBloc.cSuggestMoviesSubject
        .add(CSuggestMoviesParams(1, "Finding%20Nemo"));
  }

  _onPopUpStartHiding() {
    _popUpKey.currentState.startHiding();
  }

  _onPopUpEndShowing() {
    _popUpKey.currentState.endShowing();
  }

  _showPopUp() {
    _popUpAnimatorKey.currentState.showPopUp();
  }

  _hidePopUp() {
    _popUpAnimatorKey.currentState.hidePopUp();
  }

  handleFailure(Error error) {
    print(error.toString());
  }

  handleSuccess(List<Movie> movies) {
    _popUpKey.currentState.setMovies(movies);
    _showPopUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: EColors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: <Widget>[
                const VBox(20.0),
                const _TopMenu(),
                const VBox(20.0),
                const _Chat()
              ],
            ),
          ),
          Positioned(
            bottom: 30.0,
            left: 0,
            right: 0,
            child: _ListenButton(
              suggestMovies: this.suggestMovies,
            ),
          ),
          _PopUpAnimator(
            key: _popUpAnimatorKey,
            fullHeight: MediaQuery.of(context).size.height,
            onStartHiding: _onPopUpStartHiding,
            onEndShowing: _onPopUpEndShowing,
            child: StreamBuilder(
                stream: _cSuggestMoviesBloc.cSuggestMoviesSubject.outputStream,
                builder: (context, snapshot) {
                  return PopUp(
                    key: _popUpKey,
                    fullHeight: MediaQuery.of(context).size.height,
                    onHide: _hidePopUp,
                  );
                }),
          )
        ],
      ),
    );
  }
}

class _PopUpAnimator extends StatefulWidget {
  final double fullHeight;
  final Widget child;
  final Function onStartHiding;
  final Function onEndShowing;
  const _PopUpAnimator(
      {Key key,
      @required this.child,
      @required this.fullHeight,
      @required this.onStartHiding,
      @required this.onEndShowing})
      : super(key: key);
  @override
  __PopUpAnimatorState createState() => __PopUpAnimatorState();
}

class __PopUpAnimatorState extends State<_PopUpAnimator>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: -widget.fullHeight, end: 0)
        .animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            switch (status) {
              case AnimationStatus.reverse:
                widget.onStartHiding();
                break;
              case AnimationStatus.completed:
                widget.onEndShowing();
                break;
              default:
                break;
            }
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  showPopUp() async {
    _animationController.forward();
  }

  hidePopUp() async {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: _animation.value, left: 0, right: 0, child: widget.child);
  }
}

class _ListenButton extends StatefulWidget {
  final Function() suggestMovies;

  const _ListenButton({Key key, @required this.suggestMovies})
      : super(key: key);
  @override
  __ListenButtonState createState() => __ListenButtonState();
}

class __ListenButtonState extends State<_ListenButton> {
  Color _iconColor;
  @override
  void initState() {
    super.initState();
    _iconColor = EColors.black26;
  }

  _handleTapDown(_) {
    setState(() {
      _iconColor = EColors.black54;
    });
  }

  _handleTapUp(_) {
    setState(() {
      _iconColor = EColors.black26;
    });
  }

  _handleTap() async {
    widget.suggestMovies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        Icons.keyboard_voice,
        color: _iconColor,
        size: 30.0,
      ),
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTap: _handleTap,
    );
  }
}

class _TopMenu extends StatefulWidget {
  const _TopMenu();
  @override
  __TopMenuState createState() => __TopMenuState();
}

class __TopMenuState extends State<_TopMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TouchableIcon(
            iconData: Icons.person,
            onPress: () {},
          ),
          TouchableIcon(
            iconData: Icons.keyboard,
            onPress: () {},
          ),
        ],
      ),
    );
  }
}

class LeftMessage extends StatefulWidget {
  LeftMessage(this.message);
  final String message;
  @override
  _LeftMessageState createState() => _LeftMessageState();
}

class _LeftMessageState extends State<LeftMessage> {
  show() {}
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
            color: EColors.white, borderRadius: EBorderRaius.regular),
        child: Text(
          widget.message,
          style: TextStyle(color: EColors.black),
        ),
      ),
    );
  }
}

class RightMessage extends StatefulWidget {
  RightMessage(this.message);
  final String message;
  @override
  _RightMessageState createState() => _RightMessageState();
}

class _RightMessageState extends State<RightMessage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
            color: EColors.blue, borderRadius: EBorderRaius.regular),
        child: Text(
          widget.message,
          style: TextStyle(color: EColors.white),
        ),
      ),
    );
  }
}

class _Chat extends StatefulWidget {
  const _Chat();
  @override
  __ChatState createState() => __ChatState();
}

class __ChatState extends State<_Chat> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [LeftMessage('Left message'), RightMessage('Right message')],
      ),
    );
  }
}

import 'package:after_layout/after_layout.dart';
import 'package:built_stream/stream_types.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/modals/built_value/movie/movie.dart';
import 'package:flutter_meet_kai_clone/modals/data/message.dart';
import 'package:flutter_meet_kai_clone/modals/data/message_position.dart';
import 'package:flutter_meet_kai_clone/streams/built_composed_streams/c_suggest_movie_stream.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_border_radius.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_colors.dart';
import 'package:flutter_meet_kai_clone/utils/debouncer.dart';
import 'package:flutter_meet_kai_clone/widgets/overlays/loading_overlay.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/popup.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/touchable_icon.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/v_box.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

const String LOCALE_ID = "en-US";

class ChatScreen extends StatefulWidget {
  const ChatScreen();
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  CSuggestMoviesBloc _cSuggestMoviesBloc;
  GlobalKey<__PopUpAnimatorState> _popUpAnimatorKey;
  GlobalKey<PopUpState> _popUpKey;
  GlobalKey<LoadingOverlayState> _loadingOverlayKey;
  GlobalKey<__ChatState> _chatKey;

  bool _overlayShown = false;
  OverlayEntry _entry;

  double _soundLevel = 0.0;
  String _listenedWords = "";

  SpeechToText _speech;

  final _debouncer = Debouncer(milliseconds: 500);
  @override
  void initState() {
    super.initState();

    _popUpAnimatorKey = GlobalKey();
    _popUpKey = GlobalKey();
    _loadingOverlayKey = GlobalKey();
    _chatKey = GlobalKey();

    _cSuggestMoviesBloc = CSuggestMoviesBloc();
    _cSuggestMoviesBloc.cSuggestMoviesSubject.outputStream
        .listen((StreamState state) {
      try {
        if (_loadingOverlayKey.currentState != null) {
          _loadingOverlayKey.currentState.setContent(
              state.runtimeType.toString().replaceAll("Instance of ", ""));
        }

        if (state is CSuggestMoviesSucceed) {
          _handleSuccess(state.results.movies);
        } else if (state is CSuggestMoviesError) {
          _handleFailure(state.error);
        }
      } catch (e) {
        print(e);
      }
    });
    _speech = SpeechToText();
    _initSpeechState();
  }

  @override
  void dispose() {
    _cSuggestMoviesBloc.dispose();
    if (_speech.isListening) {
      _speech.cancel();
    }
    super.dispose();
  }

  Future<void> _initSpeechState() async {
    await _speech.initialize(
        onError: _errorListener, onStatus: _statusListener);
  }

  void _startListening() {
    try {
      _listenedWords = "";
      _speech.listen(
        onResult: _resultListener,
        pauseFor: Duration(seconds: 2),
        localeId: LOCALE_ID,
        onSoundLevelChange: _soundLevelListener,
        cancelOnError: true,
        partialResults: true,
      );
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _resultListener(SpeechRecognitionResult result) {
    if (result.finalResult == true) {
      _debouncer.run(() {
        _handleListenedWords(result.recognizedWords);
      });
    } else {
      setState(() {
        _listenedWords = result.recognizedWords;
      });
      _debouncer.run(() {
        _stopListening();
      });
    }
  }

  void _handleListenedWords(String listenedWord) {
    print("Stop");
    setState(() {
      _listenedWords = "";
      _soundLevel = 0.0;
    });
    _chatKey.currentState
        .addMessage(Message(listenedWord, position: MessagePosition.RIGHT));
    _suggestMovies(listenedWord);
  }

  void _soundLevelListener(double _soundLevel) {
    print("SoundLevel: " + _soundLevel.toString());
    setState(() {
      this._soundLevel = _soundLevel;
    });
  }

  void _errorListener(SpeechRecognitionError error) {
    print("Error: " + error.toString());
  }

  void _statusListener(String status) {
    print("Status: " + status);
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _soundLevel = 0.0;
    });
  }

  _toggleLoading() {
    print("toggle");
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

  _suggestMovies(String suggestion) {
    _toggleLoading();
    _cSuggestMoviesBloc.cSuggestMoviesSubject
        .add(CSuggestMoviesParams(1, Uri.encodeFull(suggestion)));
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
    _debouncer.run(() {
      _chatKey.currentState.addNextMessage();
      _popUpAnimatorKey.currentState.hidePopUp();
    });
  }

  _handleFailure(dynamic error) async {
    print(error.toString());
    await Future.delayed(Duration(seconds: 1));
    _toggleLoading();
    await Future.delayed(Duration(seconds: 1));
    _chatKey.currentState.addMessage(Message(
        "We cannot find the movie!\nPlease try again!",
        position: MessagePosition.LEFT));
  }

  _handleSuccess(List<Movie> movies) async {
    movies.sort((a, b) => a.est < b.est ? 1 : -1);
    await Future.delayed(Duration(seconds: 1));
    _toggleLoading();

    _chatKey.currentState.addMessage(Message(
        "We found the movie ${movies[0].title}\n\nIs this the movie you are looking for?",
        position: MessagePosition.LEFT));
    _popUpKey.currentState.setMovies(movies);
    await Future.delayed(Duration(seconds: 1));
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
                const VBox(10.0),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: EColors.blue, width: 1)),
                  child: Center(
                    child: Text(
                      _listenedWords,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const VBox(20.0),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: EColors.black26.withOpacity(0.1),
                              width: 1))),
                ),
                const VBox(5.0),
                Expanded(
                  flex: 1,
                  child: _Chat(key: _chatKey),
                ),
                const VBox(5.0),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: EColors.black26.withOpacity(0.1),
                              width: 1))),
                )
              ],
            ),
          ),
          Positioned.fill(
            bottom: 30,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1.9,
                        spreadRadius: _soundLevel * 2.3,
                        color: Colors.blue.withOpacity(.1))
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(70)),
                ),
                child: IconButton(
                    color: _speech.isListening ? EColors.blue : EColors.black,
                    icon: Icon(Icons.mic),
                    iconSize: 45,
                    onPressed:
                        _speech.isListening ? _stopListening : _startListening),
              ),
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

  @override
  void afterFirstLayout(BuildContext context) {
    _chatKey.currentState.addMessage(Message(
        "Tell me what kind of movie you like?",
        position: MessagePosition.LEFT));
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
        constraints: BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.only(bottom: 10),
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
        constraints: BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.only(bottom: 10),
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
  const _Chat({key}) : super(key: key);
  @override
  __ChatState createState() => __ChatState();
}

class __ChatState extends State<_Chat> {
  List<Message> _messages;
  ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _messages = [];
    _scrollController = ScrollController();
  }

  void addMessage(Message message) async {
    setState(() {
      _messages.add(message);
    });
    await Future.delayed(Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void addNextMessage() {
    if (_messages[_messages.length - 1].content !=
        "Tell me what kind of movie you like?") {
      addMessage(Message("Tell me what kind of movie you like?",
          position: MessagePosition.LEFT));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> messageWidgets = _messages.map<Widget>((message) {
      switch (message.position) {
        case MessagePosition.LEFT:
          return LeftMessage(message.content);
        case MessagePosition.RIGHT:
          return RightMessage(message.content);
        default:
          throw "Not available position";
      }
    }).toList();
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          VBox(10),
          ...messageWidgets,
          VBox(20),
        ],
      ),
    );
  }
}

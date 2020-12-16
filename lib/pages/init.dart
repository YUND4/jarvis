import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:jarvis/models/Message.dart';
import 'package:jarvis/theme/jarvisTheme.dart';
import 'package:jarvis/utils/animation.dart';
import 'package:jarvis/widgets/page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

const languages = const [
  'fr_FR',
  'en_US',
  'ru_RU',
  'it_IT',
  'es_ES',
];

class Init extends StatefulWidget {
  static String get pageName => 'Init';

  @override
  _InitState createState() => _InitState();
}

class _InitState extends State<Init> with BasePage, TickerProviderStateMixin {
  bool _loading;
  double _progressValue;
  AnimationController _progressController,
      _jarvisController,
      _pulseController,
      _nameController;
  Animation<Offset> _progressAnimation, _jarvisAnimation;
  Animation<Color> _pulseAnimation;
  Animation<String> _nameAnimation;
  bool _avalible = true;
  String _nameIA = 'J.A.R.V.I.S';
  final _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _isListening = false;
  bool _speechRecognitionAvailable = false;
  String selectedLang = languages.first;

  List<Message> message = <Message>[
    Message(text: 'Hola...', ia: true),
    Message(text: 'Quien es...'),
    Message(text: 'Quien es...'),
    Message(text: 'Hola...', ia: true),
    Message(text: 'Hola...', ia: true),
    Message(text: 'Quien es...'),
  ];

  AssetsAudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _progressDefinition();
    _jarvisDefinition();
    _pulseDefinition();
    _nameDefinition();
    _proAnimation();
  }

  @override
  Widget build(BuildContext context) {
    this.loadArguments(context);
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
          child: Column(
            children: [
              _jarvisLabel(),
              _startButton(),
            ],
          ),
        ));
  }

  _jarvisLabel() => SlideTransition(
        position: _jarvisAnimation,
        child: Center(
          child: Text(
            _nameAnimation.value,
            style: theme(context).headline1,
          ),
        ),
      );

  _startButton() => Expanded(
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              _circularProgress(),
            ],
          ),
        ),
      );

  _circularProgress() => SlideTransition(
        position: _progressAnimation,
        child: Container(
            alignment: Alignment.center,
            child: _loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        strokeWidth: 15,
                        value: _progressValue,
                        backgroundColor: Colors.white,
                      ),
                      Text(
                        '${(_progressValue * 100).round()}%',
                        style: theme(context).headline1,
                      ),
                    ],
                  )
                : _avalible == true
                    ? FloatingActionButton(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        backgroundColor: _pulseAnimation.value,
                        child: Icon(
                          Icons.power_settings_new,
                          size: 40,
                          color: _avalible ? Colors.white : Colors.transparent,
                        ),
                        onPressed: () {
                          if (_avalible == true) _updateProgress();
                          playMusic();
                        },
                      )
                    : _conversation()),
      );

  void _updateProgress() {
    _loading = !_loading;
    const oneSec = const Duration(milliseconds: 150);
    _progressValue = 0.0;
    new Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _progressValue += 0.01;
        if (_progressValue.toStringAsFixed(1) == '1.0') {
          _loading = false;
          t.cancel();
          _progressValue:
          0.0;
          _avalible = false;
          stopMusic();
          return;
        }
      });
    });
  }

  Widget _conversation() => Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Expanded(
            flex: 9,
            child: Container(
              color: Colors.white,
              child: _feed(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: _accionButton(),
            ),
          )
        ],
      );

  Widget _accionButton() => FloatingActionButton(
      onPressed: () async {
        await _player.dispose();
        if (!_isListening)
          start();
        else
          stop();
      },
      child: Icon(_icon));

  Widget _feed() => ListView.builder(
        itemCount: message.length,
        itemBuilder: (context, i) {
          bool upContinuity = false;
          bool downContinuity = false;
          double offset = 10;
          EdgeInsets margin = EdgeInsets.all(offset);
          EdgeInsets padding = EdgeInsets.all(offset);
          BorderRadius border = BorderRadius.all(
            Radius.circular(offset),
          );
          try {
            upContinuity = message[i - 1].ia == message[i].ia;
          } catch (e) {}
          try {
            downContinuity = message[i + 1].ia == message[i].ia;
          } catch (e) {}
          if (upContinuity && downContinuity) {
            margin = EdgeInsets.only(left: offset, right: offset);
            padding = EdgeInsets.only(left: offset, right: offset);
            border = BorderRadius.all(
              Radius.circular(0),
            );
          } else if (downContinuity) {
            margin = EdgeInsets.only(left: offset, right: offset, top: offset);
            padding = EdgeInsets.only(left: offset, right: offset, top: offset);
            border = BorderRadius.only(
              topLeft: Radius.circular(offset),
              topRight: Radius.circular(offset),
            );
          } else if (upContinuity) {
            margin =
                EdgeInsets.only(left: offset, right: offset, bottom: offset);
            padding =
                EdgeInsets.only(left: offset, right: offset, bottom: offset);
            border = BorderRadius.only(
              bottomLeft: Radius.circular(offset),
              bottomRight: Radius.circular(offset),
            );
          }
          return Row(
            children: [
              Visibility(
                visible: message[i].ia,
                child: Expanded(
                  flex: 1,
                  child: Opacity(
                    opacity: 1,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: margin,
                  padding: padding,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: border,
                  ),
                  child: Text(
                    message[i].text,
                    style: theme(context).bodyText1,
                    textAlign: message[i].ia ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ),
              Visibility(
                visible: !message[i].ia,
                child: Expanded(
                  flex: 1,
                  child: Opacity(
                    opacity: 1,
                  ),
                ),
              ),
            ],
          );
        },
      );

  void _proAnimation() async {
    _loading = false;
    _progressValue = 0.0;
    Future.delayed(
      Duration(seconds: 3),
      () async {
        await _nameController.forward();
        await Future.delayed(Duration(seconds: 1));
        await _jarvisController.forward();
        await _progressController.forward();
        _pulseController.repeat(reverse: true);
        _avalible = true;
      },
    );
  }

  void _progressDefinition() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );
    _progressAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.decelerate,
      ),
    );
  }

  void _jarvisDefinition() {
    _jarvisController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _jarvisAnimation = Tween<Offset>(
      begin: Offset(0.0, 3.5),
      end: Offset(0.0, 0.7),
    ).animate(
      CurvedAnimation(
        parent: _jarvisController,
        curve: Curves.decelerate,
      ),
    );
  }

  void _pulseDefinition() {
    _pulseController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _pulseAnimation = ColorTween(begin: Colors.transparent, end: Colors.white38)
        .animate(_pulseController)
          ..addListener(() {
            setState(() {});
          });
  }

  void _nameDefinition() {
    _nameController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _nameAnimation = StringTween(end: _nameIA).animate(_nameController)
      ..addListener(() {
        setState(() {});
      });
  }

  void playMusic() {
    _player = AssetsAudioPlayer.newPlayer();
    _player.open(
      Audio("assets/tracks/intro.mp3"),
      autoStart: true,
      showNotification: true,
    );
  }

  void stopMusic() {
    _player.stop();
  }

  IconData get _icon => _isListening ? Icons.mic_off : Icons.mic;

  void start() {
    if (_speechReady) {
      _isListening = true;
      _speech.listen(
        listenFor: Duration(seconds: 5),
        onResult: (result) {
          _isListening = false;
          message.add(
            Message(
              text: result.toString(),
            ),
          );
        },
      );
    } else {
      onError('speech not ready');
    }
  }

  void stop() {
    _speech.stop();
    _isListening = false;
  }

  void _initSpeech() async {
    bool hasPermission = await Permission.microphone.isGranted;
    if (!hasPermission) {
      await Permission.microphone.request();
    }
    _speechReady = await _speech.initialize(
        onStatus: onStatusChanged, onError: onError, debugLogging: true);
  }

  void onError(error) {
    print('Error => $error');
    _isListening = false;
  }

  void onStatusChanged(String status) {
    print('Status => $status');
  }
}

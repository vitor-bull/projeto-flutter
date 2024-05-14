import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:word_generator/word_generator.dart';

class PosLoginScreen extends StatelessWidget {
  const PosLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fala AI',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: VoiceWordComparison());
  }
}

class VoiceWordComparison extends StatefulWidget {
  @override
  _VoiceWordComparisonState createState() => _VoiceWordComparisonState();
}

class _VoiceWordComparisonState extends State<VoiceWordComparison> {
  late stt.SpeechToText _speech;
  bool _isRecording = false;
  String _text = 'Pressione e segure o botão para gravar seu áudio';
  bool _buttonPressed = false;
  String _wordToCompare = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    fetchWord();
  }

  void _initializeSpeech() async {
    bool isAvailable = await _speech.initialize(onError: (error) {
      setState(() => {});
    });
    if (!isAvailable) {
      setState(() {
        _text = 'Reconhecimento de voz indisponível';
      });
    }
  }

  void _startRecording() async {
    if (!_speech.isAvailable) {
      _initializeSpeech(); // Reinitialize if not available
      return;
    }

    await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _isRecording = false;
              _text = 'Você disse: ${result.recognizedWords}';
              _compareWords(result.recognizedWords);
            });
          }
        },
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 1),
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation);

    setState(() {
      _isRecording = true;
      _text = 'Ouvindo...';
    });
  }

  void _stopRecording() async {
    if (_speech.isListening) {
      await _speech.stop();
    }

    setState(() {
      _isRecording = false;
      _text = 'Gravação pausada';
    });
  }

  void _compareWords(String spokenWord) {
    if (spokenWord.toLowerCase() == _wordToCompare.toLowerCase()) {
      setState(() {
        _text = "Pronúncia correta, parabéns!";
      });
      fetchWord();
    } else {
      setState(() {
        _text = "Áudio não corresponde ao texto (${spokenWord.toLowerCase()}). Tente novamente.";
      });
    }
  }

  void fetchWord() {
    final wordGenerator = WordGenerator();
    _wordToCompare = wordGenerator.randomVerb();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Treino de Pronúncia'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Text('Palavra a Comparar: $_wordToCompare'),
              Text(_text),
              SizedBox(height: 20),
              GestureDetector(
                onLongPress: () {
                  _buttonPressed = true;
                  _startRecording();
                },
                onLongPressEnd: (details) {
                  _buttonPressed = false;
                  _stopRecording();
                },
                child: Icon(
                  Icons.mic,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchWord,
                child: Text('Nova Palavra'),
              ),
            ])));
  }
}

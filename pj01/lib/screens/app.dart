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
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
        ),
      ),
      home: VoiceWordComparison(),
    );
  }
}

class VoiceWordComparison extends StatefulWidget {
  @override
  _VoiceWordComparisonState createState() => _VoiceWordComparisonState();
}

class _VoiceWordComparisonState extends State<VoiceWordComparison> {
  late stt.SpeechToText _speech;
  bool _isRecording = false;
  String _text = 'Pressione o botão para gravar';
  String _wordToCompare = '';
  String _recordedWord = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    _generateWord();
  }

  void _initializeSpeech() async {
    bool isAvailable = await _speech.initialize(
      onError: (error) {
        setState(() {
          _text = 'Reconhecimento de voz indisponível';
        });
      },
    );
    if (!isAvailable) {
      setState(() {
        _text = 'Reconhecimento de voz indisponível';
      });
    }
  }

  void _startRecording() async {
    if (!_speech.isAvailable) {
      _initializeSpeech();
      return;
    }

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recordedWord = result.recognizedWords;
          _text = 'Gravando...';
          _compareWords(_recordedWord);
        });
      },
      listenFor: null, // Record indefinitely until stopped
      cancelOnError: true,
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );
    setState(() {
      _isRecording = true;
      _text = 'Gravando...';
    });
  }

  void _stopRecording() async {
    if (_speech.isListening) {
      await _speech.stop();
    }

    setState(() {
      _isRecording = false;
      _text = 'Gravação finalizada';
    });
  }

  void _compareWords(String spokenWord) {
    if (spokenWord.toLowerCase() == _wordToCompare.toLowerCase()) {
      _stopRecording();
      setState(() {
        _text = "Pronúncia correta, parabéns! 🥳";
        _generateWord();
      });
    } else {
      setState(() {
        _text =
            "Áudio não corresponde à palavra! 🙁";
        _recordedWord = spokenWord;
        _isRecording = false;
      });
    }
  }

  void _generateWord() {
    final wordGenerator = WordGenerator();
    _wordToCompare = wordGenerator.randomVerb();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fala AI!', style: TextStyle(fontSize: 22, color: Color.fromARGB(255, 250, 249, 249))),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 3, 41, 71),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Palavra escolhida:', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              _wordToCompare,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(_text, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Text('Você disse:', style: Theme.of(context).textTheme.bodyLarge),
            Text(
              _recordedWord,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 32, 3, 90)),
            ),
            const SizedBox(height: 40),
            FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 3, 41, 71),
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Icon(
                color: const Color.fromARGB(255, 250, 249, 249),
                _isRecording ? Icons.stop : Icons.mic,
                size: 35,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _generateWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 3, 41, 71),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(width: 1)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Nova Palavra', style: TextStyle(color: Color.fromARGB(255, 250, 249, 249), fontWeight: FontWeight.bold)) ,
            ),
          ],
        ),
      ),
    );
  }
}
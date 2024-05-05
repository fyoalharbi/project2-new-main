import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:word_generator/word_generator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';


import '../Widgets/Appbuttons.dart';
import 'Congrats.dart';

final RandomWord = WordGenerator();
String noun = RandomWord.randomSentence(6);

class Speechtotext extends StatefulWidget {
  const Speechtotext({Key? key}) : super(key: key);

  @override
  State<Speechtotext> createState() => _SpeechtotextState();
}

class _SpeechtotextState extends State<Speechtotext> {
  SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  SpeechToText speechToText = SpeechToText();
  bool isListening = false;
  bool isSuccessful = false;
  int successCounter = 0;
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      isListening = true;
    });
  }

  /// Manually stop the active speech recognition session
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  Widget build(BuildContext context) {
    void regren() {
      setState(() {
        noun = RandomWord.randomSentence(6);
        _lastWords = '';
      });
    }
    bool SuccessState(successCounter)  {
      if (successCounter >= 1){
        return true;
      }
      return false;
    }


    bool verifyText() {
      _lastWords = _lastWords.toLowerCase();
      noun = noun.trim();

      if (_lastWords.contains(noun)) {
        successCounter++;
        print(successCounter);
        regren();

        return true;
      }
      return false;
    }
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Color(0xFFE3AC96)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
      
        ),
      
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/Photos/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(

            physics: const BouncingScrollPhysics(),
            child: Container(

              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              margin: const EdgeInsets.only(bottom: 150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height:33),
                  Center(

                    child: Text(
                      'Read the following words in the correct order for authentication: $noun',
                      style: TextStyle(
                        fontSize: 24,
                        color: isListening ? Colors.black87 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      // If listening is active show the recognized words
                      _speechToText.isListening
                          ? _lastWords
                      // If listening isn't active but could be tell the user
                      // how to start it, otherwise indicate that speech
                      // recognition is not yet ready or not supported on
                      // the target device
                          : _speechToText.isAvailable
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                    ),
                  ),
                  Expanded(
                    child: verifyText()
                        ? const Text("Success")
                        : const Text("Failed"),
                  ),
                  const SizedBox(
                    height: 120,
                  ),
                  AvatarGlow(
                    animate: isListening,
                    duration: const Duration(milliseconds: 2000),
                    glowColor: const Color(0xFF2D2689),
                    repeat: true,
                    child: GestureDetector(
                      onTap: () {
                        _speechToText.isNotListening
                            ? _startListening()
                            : _stopListening();
                      },
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF2D2689),
                        radius: 50,
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Appbuttons(
                    onPressed: () {
                      regren();
                    },
                    text: "Click to regenerate a new words",
                  ),
                  const SizedBox(height: 15),
                  Appbuttons(
                    text: "Submit",
                    onPressed:  SuccessState(successCounter) ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Congrats()),
                      );
                    }
                        : null,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
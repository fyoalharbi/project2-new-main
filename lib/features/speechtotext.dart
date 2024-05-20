import 'package:flutter/material.dart';
import 'package:flutter_interfaces/features/Congrats.dart';
import 'package:flutter_interfaces/features/finalverify.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:word_generator/word_generator.dart';
final RandomWord = WordGenerator();
String noun = RandomWord.randomNoun();
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  int successCounter = 0;
  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    void regren() {
      setState(() {
        noun = RandomWord.randomNoun();
        _wordsSpoken = '';
      });
    }
    bool SuccessState(successCounter)  {
      if (successCounter >= 5){
        return true;
      }
    return false;
  }
   bool _verifyText() {
    var cleanedRecognizedWords = _wordsSpoken.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    var cleanedNoun = noun.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    print('Verifying text: Recognized Words: $cleanedRecognizedWords, Noun: $cleanedNoun');
    if (cleanedRecognizedWords == cleanedNoun) {
      successCounter++;
      print('Success counter: $successCounter');
      return true;
    }
    print('ASR failed - no match');
    return false;
  }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Speech Demo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [

             Text(
                  'Read the following text for authentication: $noun',
                  style: TextStyle(
                    fontSize: 24,
                    color: _speechToText.isListening ? Colors.black87 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "listening..."
                    : _speechEnabled
                        ? "Tap the microphone to start listening..."
                        : "Speech not available",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
                child: _verifyText()
                    ? const Text("Success")
                    : const Text("Failed"),
              ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            

              const SizedBox(height: 45),
              Appbuttons(
                onPressed: () {
                  regren();
                },
                text: "Click to regenerate a word",
              ),
               const SizedBox(height: 20),
              Appbuttons(
                text: "Submit",
                onPressed:  SuccessState(successCounter) ? () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  finalverfiy()),
                );
                }
                :null,
              )
          ],
          
        ),
        
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

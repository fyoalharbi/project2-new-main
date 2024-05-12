
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:word_generator/word_generator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'Congrats.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_interfaces/features/voice_recording/resources/sentences.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_params.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


final RandomWord = WordGenerator();
String noun = RandomWord.randomSentence(3);

class Speechtotext extends StatefulWidget {
  const Speechtotext({Key? key}) : super(key: key);

  @override
  State<Speechtotext> createState() => _SpeechtotextState();
}

class _SpeechtotextState extends State<Speechtotext> with TickerProviderStateMixin{
  SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  SpeechToText speechToText = SpeechToText();
  bool isListening = false;
  bool isSuccessful = false;
  int successCounter = 0;  
   String path = '';
  String url ='';
  String audioPath= '';
  String savedUid = '';
  String firstName = '';
  bool _isRecording = false;
  List<String> _recordings = [];
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _animationController;
  final List<String> _sentences = Sentences.sentences;
  var sentenceCount = 0;
  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initSpeech();
    _loadUserData();
        _animationController = AnimationController(vsync: this);

  }
@override
 void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    
    _startRecording();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      isListening = true;
    });
  }
    Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }
  void _startRecording() async {
    print("STARTED RECORDING");
    await _recorder.openRecorder();
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/${DateTime
        .now()
        .millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );
    setState(() {
      _isRecording = true;
      _animationController.repeat();
    });
  }
  
  void _stopAndSaveRecording() async {
    setState(() {
      _isRecording = false;
      _animationController.reset();
      _animationController.stop();
    });
    String? path = await _recorder.stopRecorder();
    final audioFile = File(path!);
    final audioPath = path;
    print('Recorded audio: $audioFile' );
        String wavFilePath = '${path.substring(0, path.lastIndexOf('.'))}.wav';
    await _convertToWav(path, wavFilePath);
       uploadAndDeleteRecording(wavFilePath);
      
      
    }

  Future<void> _convertToWav(String inputPath, String outputPath) async {
  final flutterFFmpeg = FlutterFFmpeg();
  await flutterFFmpeg.execute('-i $inputPath $outputPath');
}

        // Display error message to the user
        // Duration is within the acceptable range
      
    
  /// Manually stop the active speech recognition session
  void _stopListening() async {
    await _speechToText.stop();
    isListening = false;
    _stopAndSaveRecording();
  
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
        noun = RandomWord.randomSentence(3);
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          margin: const EdgeInsets.only(bottom: 150),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Read the following text for authentication: $noun',
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
                      //_isRecording
                    //? _stopAndSaveRecording()
                    //: _startRecording(),
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
                height: 75,
              ),
              AvatarGlow(
                animate: isListening,
                duration: const Duration(milliseconds: 2000),
                glowColor: const Color(0xFF2F66F5),
                repeat: true,
                child: GestureDetector(
                  onTap: () {
                    _speechToText.isNotListening
                        ? _startListening()  
                        : _stopListening; _stopAndSaveRecording();
                  },
                  child: Lottie.asset(
                  "assets/microphone.json",
                  controller: _animationController,
                  onLoaded: (composition) =>
                  _animationController.duration = composition.duration,

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
                  MaterialPageRoute(builder: (context) => const Congrats()),
                );
              }
              : null,
              )
            ],
          ),
        ),
      ),
    );

  }
    _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          // Check if the snapshot contains the fields
          if (snapshot.data()!.containsKey('first_name') && snapshot.data()!.containsKey('last_name') && snapshot.data()!.containsKey('uid')) {
            String firstName = snapshot.data()!['first_name']; // Retrieve first name from FB
            String lastName = snapshot.data()!['last_name']; // Retrieve last name
            String uid = snapshot.data()!['uid']; // Retrieve UID

           /*
           // print data for testing
            print('First Name: $firstName'); // Print first name to terminal
            print('Last Name: $lastName'); // Print last name
            print('UID: $uid'); // Print UID
            */

            // full name
            String fullName = '$firstName $lastName';
           // print('Full Name: $fullName');    //for testing

            // Save the first name, last name, and UID in variables for later use
            String savedFirstName = firstName;
            String savedLastName = lastName;
            savedUid = uid;

            // Save the full name as a var too if needed
            String savedFullName = fullName;
          } else {
            throw('User document does not contain first name, last name, and UID fields');
          }
        }
      }
    } catch (e) {
      throw('Error loading user data: $e');
    }
  }
Future<void> uploadAndDeleteRecording(path) async {
  
  print("Uid ----------------------${savedUid}------------------------");

    try {
      final url = Uri.parse('http://192.168.8.116:5000/train/$savedUid');  //plug user's UID here 
      final file = File(path);
      if (!file.existsSync()) {
        print("UPLOADING FILE NOT EXIST+++++++++++++++++++++++++++++++++++++++++++++++++");
        return;
      }
      print("UPLOADING FILE ++++++++++++++++${file}+++++++++++++++++++++++++++++++++");
      final request = http.MultipartRequest('POST', url)
        ..files.add(
          await http.MultipartFile.fromPath(
            'audio',
            path,
            //await file.readAsBytes(),

            //file.readAsBytes().asStream(),
            //file.lengthSync(),
            filename: 'audio.wav', 
          ),
        );
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("FILE UPLOADED SUCCESSFULLY!!!!!!!!!!!!!!!!!1");
        // Upload successful, you can delete the recording if needed
        // Show a snackbar or any other UI feedback for a successful upload
        if(responseData == savedUid && successCounter > 2){
          Navigator.pushNamed(context, "/Congrats");

          print("predicted speaker is same as current speaker");
        }
        const snackBar = SnackBar(
          content: Text('Audio uploaded.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Refresh the UI
        setState(() {
          audioPath = "";
        });
      } else {
        // Handle the error or show an error message
        print('Failed to upload audio. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading audio: $e');
    }
  }
} 
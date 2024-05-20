import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_interfaces/features/Congrats.dart';
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
String savedUid = '';

class finalverfiy extends StatefulWidget {
  @override
  finalverfiyState createState() => finalverfiyState();
}

class finalverfiyState extends State<finalverfiy> with TickerProviderStateMixin {
  bool _isRecording = false;
  List<String> _recordings = [];
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _animationController;
  final List<String> _sentences = Sentences.sentences;
  var sentenceCount = 0;
  String audioPath = '';
  @override
  void initState() {
    super.initState();
    _loadUserData(); // Call the function to load user data
    _initRecorder();
    _animationController = AnimationController(vsync: this);
    // Display a message informing the user that 4 recordings are needed
    showRecordingLimitMessage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:
      AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFE3AC96)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.lightBlue[200]!, // Light blue ombre
              Colors.orange[200]! // Light orange
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Record Your Voice", style: TextStyle(fontSize: 32)),
              const SizedBox(height: 16),
              const Text("Tap the microphone icon and talk about yourself in length",
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: () =>
                _isRecording
                    ? _stopAndSaveRecording()
                    : _startRecording(),
                child: Lottie.asset(
                  "assets/microphone.json",
                  controller: _animationController,
                  onLoaded: (composition) =>
                  _animationController.duration = composition.duration,

                ),
              ),
            
              Expanded(
                child: ListView.builder(
                  itemCount: _recordings.length,
                  itemBuilder: (context, index) {
                    if (_recordings.isEmpty) {
                      return const SizedBox();
                    }
                    
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text('Voice Recorder'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _recordings.length < 4
              ? Navigator.pushReplacementNamed(context, "/Login")
              : Navigator.pushReplacementNamed(context, "/Userinterface");
        },
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'help') {
              // Call the help dialog
              showHelpDialog();
            } else if (value == 'contact_support') {
              // Send email to labguard.app@outlook.com
              final Uri _emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'labguard.app@outlook.com',
                queryParameters: {'subject': 'Support Needed'},
              );
              launch(_emailLaunchUri.toString());
            }
          },
          itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text('More Information'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'contact_support',
              child: ListTile(
                leading: Icon(Icons.email),
                title: Text('Contact Support'),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Future<void> _loadUserData() async {
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
            print('User document does not contain first name, last name, and UID fields');
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }





  void showRecordingLimitMessage() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Voice Recording Setup'),
            content: const Text(
                "Please Talk about yourself in details "),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Call the help dialog
                  showHelpDialog();
                },
                child: const Text('More Info'),
              ),
            ],
          );
        },
      );
    });
  }


  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  Future<void> _saveRecordingsToFirestore() async {
    await FirebaseFirestore.instance.collection("recordings").doc(
        FirebaseAuth.instance.currentUser!.uid).set({
      'recordings': _recordings,
    }, SetOptions(merge: true));
  }



  void changeSentence() => setState(() => sentenceCount++);





  void _startRecording() async {
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
    if (path != null) {
      final duration = await _getAudioDuration(
          path); // Get the duration of the audio
      if (duration < Duration(seconds: 2) || duration > Duration(seconds: 6)) {
        // Determine if the duration is too long or too short
        String errorMessage;
        if (duration < Duration(seconds: 3)) {
          errorMessage =
          "Recording is too short. It must be at least 3 seconds long.";
        } else {
          errorMessage =
          "";
        }
        // Display error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Recording Error"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Try Again"),
                ),
              ],
            );
          },
        );
        return; // Exit early, do not save the recording
      }
      // Duration is within the acceptable range
      // Convert PCM audio to WAV format using FFmpeg
    String wavFilePath = '${path.substring(0, path.lastIndexOf('.'))}.wav';
    await _convertToWav(path, wavFilePath);
       uploadAndDeleteRecording(wavFilePath);
      setState(() {
      });
      await _saveRecordingsToFirestore();
    }
  }
  Future<void> _convertToWav(String inputPath, String outputPath) async {
  final flutterFFmpeg = FlutterFFmpeg();
  await flutterFFmpeg.execute('-i $inputPath $outputPath');
}

Future<void> uploadAndDeleteRecording(path) async {
  //convert
  /* 
   FFmpegKit.execute('-i input.aac output.wav').then((session) async {
   final returnCode = await session.getReturnCode();
  print(returnCode);
 });*/
  print("Uid ----------------------${savedUid}------------------------");
    //try
     {
      final url = Uri.parse('http://192.168.8.116:5000/auth/');  //plug user's UID here 
      final file = File(path);
      if (!file.existsSync()) {
        print("UPLOADING FILE NOT EXIST+++++++++++++++++++++++++++++++++++++++++++++++++");
        return;
      }
      print("UPLOADING FILE ++++++++++++++++$file+++++++++++++++++++++++++++++++++");
      final request = http.MultipartRequest('POST', url);
        request.files.add(
          await http.MultipartFile.fromPath(
            'audio',
            path,
            //await file.readAsBytes(),

            //file.readAsBytes().asStream(),
            //file.lengthSync(),
            filename: 'audio.wav', 
          ),
        );
        request.headers['Connection'] = 'Keep-Alive';
      
//http.Response response = await http.Response.fromStream(await request.send());
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print(responseData);
      //final response = await http.get(url);
      //var response = await request.send();
      //var responseData = await response.stream.bytesToString();
     // var x = json.decode(response.body);
      if (response.statusCode == 200) {
        print("FILE UPLOADED SUCCESSFULLY!!!!!!!!!!!!!!!!!1");
      if(responseData == savedUid){
          Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  Congrats()),
                );
          }
      
  } else {
    print('Failed to upload file. Status code: ${response.statusCode}');
        
        // Upload successful, you can delete the recording if needed
        // Show a snackbar or any other UI feedback for a successful upload
        const snackBar = SnackBar(
          content: Text('Audio uploaded.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Refresh the UI
        setState(() {
          audioPath = "";
        });
      }
    } //catch (e) {
      //print('Error uploading audio: $e');
    //}
  }
  Future<Duration> _getAudioDuration(String path) async {
    final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();
    final result = await _flutterFFprobe.getMediaInformation(path);
    final durationString = result?.getMediaProperties()?["duration"];
    final duration = Duration(seconds: double.parse(durationString).toInt());
    return duration;
  }



  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('More Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why do we need your recordings?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We need your voice recordings for account setup. Each recording should be 3-5 seconds long which will helps us ensure secure authentication using our voice identification model.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Need further assistance?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you have any questions, concerns, or encounter any issues during the process, please feel free to contact us through the "Contact Support" option.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'You have one chance to record yout voice. Make it count!',
                 // style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

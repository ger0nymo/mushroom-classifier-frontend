import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mushroom_classifier/features/camera/bloc/camera_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CameraScreen extends StatelessWidget {
  CameraScreen({Key? key}) : super(key: key);

  String? capturedImagePath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: BlocProvider(
        create: (context) => CameraBloc()..add(const InitializeCameraEvent()),
        child: Scaffold(
          appBar: null,
          body: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              if (state is CameraInitialized) {
                double width = MediaQuery.of(context).size.width;
                double height = MediaQuery.of(context).size.height;

                if (state.result != null) {
                  final predictions = state.result!.predictions;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 2),
                          ),
                          scrollable: true,
                          title: Text(predictions[0].name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          insetPadding: EdgeInsets.all(15),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(text: TextSpan(
                                text: "Our model has predicted",
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black.withOpacity(0.8)),
                                children: <TextSpan>[
                                  TextSpan(text: " ${predictions[0].name} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: "with a confidence of"),
                                  TextSpan(text: " ${(predictions[0].prob * 100).toStringAsFixed(2)}%.", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )),
                              const Text("\nThe following genus are also possible:\n"),
                              // Create a layout for the predictions from index 1-4 the following format: Name .... Percentage
                              // Name should be aligned to the left and Percentage to the right, percentage should be bold
                              for (int i = 1; i < 5; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(predictions[i].name, style: const TextStyle(fontSize: 16)),
                                    Text("${(predictions[i].prob * 100).toStringAsFixed(2)}%", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                            ],
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actions: [
                            TextButton(onPressed: () async {
                              final url = Uri.parse("https://www.google.com/search?q=${predictions[0].name}");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }, child: const Text("Learn more", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),)),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK", style: TextStyle(color: Colors.black),),
                            ),
                          ],
                        );
                      },
                    );
                  });
                }

                return Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 64.0),
                        child: Text(
                          "Mushroom classifier",
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: SizedBox(
                          // Circular border
                          width: width * 0.85,
                          height: height * 0.65,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: OverflowBox(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                    child: SizedBox(
                                      width: width,
                                      height: width *
                                          state.cameraController.value.aspectRatio,
                                      child: state.cameraController.buildPreview(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            minimumSize: Size(width * 0.6, 40),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          onPressed: () {
                            context.read<CameraBloc>().add(const CaptureImageEvent());
                          },
                          child: const Text("Capture  🍄", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is CameraCaptured) {
                double width = MediaQuery.of(context).size.width;
                double height = MediaQuery.of(context).size.height;
                return Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 64.0),
                        child: Text(
                          "Mushroom classifier",
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: SizedBox(
                          // Circular border
                          width: width * 0.85,
                          height: height * 0.65,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: OverflowBox(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: SizedBox(
                                    width: width,
                                    height: width *
                                        state.cameraController.value.aspectRatio,
                                    child: Image.file(
                                      File(state.imagePath),
                                    )
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellowAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                minimumSize: Size(width * 0.4, 30),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              onPressed: () {
                                context.read<CameraBloc>().add(const CameraRetryEvent());
                              },
                              child: const Text("Retry 🔃", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                minimumSize: Size(width * 0.4, 30),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              onPressed: () {
                                context.read<CameraBloc>().add(CameraScanEvent(imageFile: File(state.imagePath)));
                              },
                              child: const Text("Scan 🧐", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is CameraLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottiefiles/loading.json', width: 250, height: 250),
                      const Text("Indentifying mushroom...", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text("Mushroom classifier", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                      ),
                      Lottie.asset('assets/lottiefiles/loading.json', width: 250, height: 250),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

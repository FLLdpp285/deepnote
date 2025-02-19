import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, this.description});

  final String? description;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Error"),
        content: Text(
            "An error occurred while importing images${description == null ? "" : ":\n$description"}"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ]);
  }
}

class ConnectDialog extends StatelessWidget {
  const ConnectDialog(
      {super.key, required this.onStateChange, this.onCharging});

  final Function()? onCharging;
  final Stream<BatteryState> onStateChange;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: StreamBuilder(
            stream: onStateChange,
            builder: (context, batteryState) {
              if (batteryState.data == BatteryState.charging) {
                Future.delayed(const Duration(seconds: 2), onCharging);
                return const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Importing..."),
                      SizedBox(height: 30),
                      CircularProgressIndicator(color: Colors.black),
                    ]);
              }
              return Stack(
                children: [
                  Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text("Waiting for connection...",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 20),
                        const Icon(Icons.usb, size: 50),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300,
                          child: LinearProgressIndicator(
                            color: Colors.black,
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        )
                      ])),
                  const CloseButton()
                ],
              );
            }));
  }
}

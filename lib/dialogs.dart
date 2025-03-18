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
            "An error occurred${description == null ? "" : ":\n$description"}"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ]);
  }
}

class ConnectDialog extends StatefulWidget {
  const ConnectDialog(
      {super.key, required this.onStateChange, this.onCharging});

  final Function()? onCharging;
  final Stream<BatteryState> onStateChange;

  @override
  State<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {

  bool isBatteryBypassed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: StreamBuilder(
            stream: widget.onStateChange,
            builder: (context, batteryState) {
              if (batteryState.data == BatteryState.charging || batteryState.data == BatteryState.connectedNotCharging || isBatteryBypassed) {
                Future.delayed(const Duration(milliseconds: 1331), widget.onCharging);
                return const LoadingColumn();
              }
              return Stack(
                alignment: AlignmentDirectional.topEnd,
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
                        GestureDetector(onTap: () {
                          Future.delayed(const Duration(milliseconds: 1331),
                              widget.onCharging);
                          setState(() {
                            isBatteryBypassed = true;
                          });
                        }, child: const Icon(Icons.usb, size: 50)),
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

class LoadingColumn extends StatelessWidget {
  const LoadingColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Importing..."),
        SizedBox(height: 30, child: SizedBox.expand()),
        CircularProgressIndicator(color: Colors.black),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCUtility {
  final BuildContext context;

  NFCUtility(this.context);

  Future<bool> isNfcAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  Future<void> startNfcSession(TextEditingController controller) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const AnimatedAlertDialog();
      },
    ).then((_) {
      NfcManager.instance.stopSession();
      Navigator.pop(context);
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        String serialNumber = _extractSerialNumber(tag);
        controller.text = serialNumber;

        NfcManager.instance.stopSession();
        Navigator.pop(context);
      },
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
    );
  }

  String _extractSerialNumber(NfcTag tag) {
    try {
      final tagData = Map<String, dynamic>.from(tag.data as Map);

      if (tagData.containsKey('nfcv')) {
        final nfcvData = Map<String, dynamic>.from(tagData['nfcv']);
        if (nfcvData.containsKey('identifier')) {
          final bytes = List<int>.from(nfcvData['identifier']);
          return bytes
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join()
              .toUpperCase();
        }
      } else if (tagData.containsKey('ndef')) {
        final ndefData = Map<String, dynamic>.from(tagData['ndef']);
        if (ndefData.containsKey('identifier')) {
          final bytes = List<int>.from(ndefData['identifier']);
          return bytes
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join()
              .toUpperCase();
        }
      }
      return 'UNKNOWN';
    } catch (e, st) {
      debugPrint("Error extracting serial number: $e\n$st");
      return 'ERROR';
    }
  }
}

class AnimatedAlertDialog extends StatefulWidget {
  const AnimatedAlertDialog({super.key});

  @override
  _AnimatedAlertDialogState createState() => _AnimatedAlertDialogState();
}

class _AnimatedAlertDialogState extends State<AnimatedAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          ScaleTransition(
            scale: _animation,
            child: const CircularProgressIndicator(),
          ),
          const SizedBox(width: 20),
          const Text("Waiting for NFC tag..."),
        ],
      ),
    );
  }
}

void showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AnimatedAlertDialog();
    },
  );
}

import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  final String message;
  const LoadingPage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12.withOpacity(0.5),
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            const SizedBox(height: 15),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

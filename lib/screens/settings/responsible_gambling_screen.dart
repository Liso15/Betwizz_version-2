import 'package:flutter/material.dart';

class ResponsibleGamblingScreen extends StatelessWidget {
  const ResponsibleGamblingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsible Gambling'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gamble responsibly',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Gambling can be addictive. Please play responsibly.',
            ),
            SizedBox(height: 16),
            Text(
              'If you or someone you know has a gambling problem, please contact the National Gambling Helpline at 0800 006 008.',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

/// Demo screen to showcase the CustomAppBar with theme-aware logo
class LogoDemoScreen extends StatelessWidget {
  const LogoDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Logo Demo',
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.info),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CustomAppBar Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This AppBar automatically adapts the logo based on the current theme:',
            ),
            const SizedBox(height: 12),
            const Text('• Light theme: Black logo'),
            const Text('• Dark theme: White logo'),
            const SizedBox(height: 24),
            const Text(
              'Switch between light and dark themes in your device settings to see the logo change!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Usage Examples:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// Basic usage with title',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Text('CustomAppBar(title: "My Screen")'),
                  SizedBox(height: 8),
                  Text(
                    '// Logo only, no title',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Text('LogoOnlyAppBar(actions: [Icon(Icons.menu)])'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

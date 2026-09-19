import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models.dart';
import '../text_direction_helper.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  // 10.0.2.2 is the Android emulator's alias for the host machine's
  // localhost. Change this to your server's real address for a
  // physical device or a deployed backend.
  final _serverUrlController =
      TextEditingController(text: 'http://10.0.2.2:8080');

  bool _isLoading = false;
  String? _errorMessage;
  String _descriptionText = '';

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() => _descriptionText = _descriptionController.text);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    final budgetText = _budgetController.text.trim();

    if (description.isEmpty) {
      setState(() => _errorMessage = 'Please enter a project description.');
      return;
    }
    final budget = double.tryParse(budgetText);
    if (budget == null) {
      setState(() => _errorMessage = 'Please enter a valid numeric budget.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final client = ApiClient(baseUrl: _serverUrlController.text.trim());

    try {
      final EvaluationResult result = await client.evaluate(
        description: description,
        budget: budget,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScopeSense — Price Check')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpansionTile(
                title: const Text('Server settings'),
                tilePadding: EdgeInsets.zero,
                children: [
                  TextField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(
                      labelText: 'API base URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Project description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                minLines: 5,
                maxLines: 10,
                textDirection: directionFor(_descriptionText),
                textAlign: textAlignFor(_descriptionText),
                decoration: const InputDecoration(
                  hintText:
                      'Describe the client\'s project... / توضیح پروژه مشتری را اینجا وارد کنید...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Client-stated budget',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _budgetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'e.g. 2000000',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Evaluate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

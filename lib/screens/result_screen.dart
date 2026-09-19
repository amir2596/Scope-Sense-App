import 'package:flutter/material.dart';

import '../models.dart';
import '../text_direction_helper.dart';

class ResultScreen extends StatelessWidget {
  final EvaluationResult result;

  const ResultScreen({super.key, required this.result});

  Color _verdictColor(BuildContext context) {
    switch (result.verdict) {
      case Verdict.realistic:
        return Colors.green;
      case Verdict.underpriced:
        return Colors.orange;
      case Verdict.overpriced:
        return Colors.red;
      case Verdict.noData:
      case Verdict.unknown:
        return Colors.grey;
    }
  }

  String _verdictLabel() {
    switch (result.verdict) {
      case Verdict.realistic:
        return 'Realistic price';
      case Verdict.underpriced:
        return 'Underpriced';
      case Verdict.overpriced:
        return 'Overpriced';
      case Verdict.noData:
        return 'Not enough data';
      case Verdict.unknown:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        result.comparables.isNotEmpty ? result.comparables.first.currency : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluation Result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _verdictColor(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _verdictColor(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _verdictColor(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _verdictLabel(),
                      style: TextStyle(
                        color: _verdictColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle(context, 'Client budget vs. market range'),
            const SizedBox(height: 8),
            _priceTable(context, currency),
            if (result.spec.clarifyingQuestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle(context, 'Clarifying questions'),
              const SizedBox(height: 8),
              ...result.spec.clarifyingQuestions
                  .map((q) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $q'),
                      )),
            ],
            const SizedBox(height: 20),
            _sectionTitle(context, 'Structured spec'),
            const SizedBox(height: 8),
            _specCard(context),
            const SizedBox(height: 20),
            _sectionTitle(context, 'Comparable projects'),
            const SizedBox(height: 8),
            if (result.comparables.isEmpty)
              const Text('No comparable projects were found.')
            else
              ...result.comparables.map((c) => Card(
                    child: ListTile(
                      title: Text(c.title),
                      trailing: Text('${c.agreedPrice.toStringAsFixed(0)} ${c.currency}'),
                    ),
                  )),
            if (result.explanation.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle(context, 'Explanation'),
              const SizedBox(height: 8),
              Directionality(
                textDirection: directionFor(result.explanation),
                child: Text(
                  result.explanation,
                  textAlign: textAlignFor(result.explanation),
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }

  Widget _priceTable(BuildContext context, String currency) {
    Widget row(String label, double value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${value.toStringAsFixed(0)} $currency'),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            row('Client stated budget', result.clientStatedBudget),
            const Divider(),
            row('Market minimum', result.minPrice),
            row('Market median', result.medianPrice),
            row('Market maximum', result.maxPrice),
          ],
        ),
      ),
    );
  }

  Widget _specCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${result.spec.category}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Directionality(
              textDirection: directionFor(result.spec.scope),
              child: Text(
                result.spec.scope,
                textAlign: textAlignFor(result.spec.scope),
              ),
            ),
            if (result.spec.techStack.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Tech stack:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result.spec.techStack
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
              ),
            ],
            if (result.spec.deliverables.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Deliverables:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              ...result.spec.deliverables.map((d) => Text('• $d')),
            ],
          ],
        ),
      ),
    );
  }
}

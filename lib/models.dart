// Mirrors the JSON shapes returned by the Go backend:
//   - internal/agent.ClarificationResult -> ClarificationSpec
//   - internal/pricing.Comparable        -> Comparable
//   - internal/pricing.Result            -> EvaluationResult

class ClarificationSpec {
  final String scope;
  final List<String> techStack;
  final List<String> deliverables;
  final String category;
  final List<String> clarifyingQuestions;

  ClarificationSpec({
    required this.scope,
    required this.techStack,
    required this.deliverables,
    required this.category,
    required this.clarifyingQuestions,
  });

  factory ClarificationSpec.fromJson(Map<String, dynamic> json) {
    return ClarificationSpec(
      scope: json['scope'] as String? ?? '',
      techStack: (json['tech_stack'] as List?)?.cast<String>() ?? const [],
      deliverables:
          (json['deliverables'] as List?)?.cast<String>() ?? const [],
      category: json['category'] as String? ?? '',
      clarifyingQuestions:
          (json['clarifying_questions'] as List?)?.cast<String>() ??
              const [],
    );
  }
}

class Comparable {
  final String title;
  final double agreedPrice;
  final String currency;

  Comparable({
    required this.title,
    required this.agreedPrice,
    required this.currency,
  });

  factory Comparable.fromJson(Map<String, dynamic> json) {
    return Comparable(
      title: json['title'] as String? ?? '',
      agreedPrice: (json['agreed_price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }
}

enum Verdict { realistic, underpriced, overpriced, noData, unknown }

Verdict verdictFromString(String s) {
  switch (s) {
    case 'realistic':
      return Verdict.realistic;
    case 'underpriced':
      return Verdict.underpriced;
    case 'overpriced':
      return Verdict.overpriced;
    case 'no_data':
      return Verdict.noData;
    default:
      return Verdict.unknown;
  }
}

class EvaluationResult {
  final ClarificationSpec spec;
  final double clientStatedBudget;
  final double minPrice;
  final double medianPrice;
  final double maxPrice;
  final List<Comparable> comparables;
  final Verdict verdict;
  final String explanation;

  EvaluationResult({
    required this.spec,
    required this.clientStatedBudget,
    required this.minPrice,
    required this.medianPrice,
    required this.maxPrice,
    required this.comparables,
    required this.verdict,
    required this.explanation,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      spec: ClarificationSpec.fromJson(
        (json['spec'] as Map<String, dynamic>?) ?? const {},
      ),
      clientStatedBudget:
          (json['client_stated_budget'] as num?)?.toDouble() ?? 0,
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0,
      medianPrice: (json['median_price'] as num?)?.toDouble() ?? 0,
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0,
      comparables: (json['comparables'] as List?)
              ?.map((e) => Comparable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      verdict: verdictFromString(json['verdict'] as String? ?? ''),
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

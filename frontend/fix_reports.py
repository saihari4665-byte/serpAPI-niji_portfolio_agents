import os

path = r'lib\screens\reports_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

replacement = """      List<String> parseStringList(dynamic data) {
        if (data == null) return [];
        if (data is List) {
          return data.map((e) {
            if (e is String) return e;
            if (e is Map) {
              if (e.containsKey('description')) return e['description'].toString();
              if (e.containsKey('reason') && e.containsKey('holding')) return "${e['holding']}: ${e['reason']}";
              if (e.containsKey('reason')) return e['reason'].toString();
              if (e.containsKey('text')) return e['text'].toString();
              if (e.values.isNotEmpty) return e.values.first.toString();
            }
            return e.toString();
          }).toList();
        }
        return [];
      }

      final strengths = parseStringList(aiReport['strengths']);
      final concerns = parseStringList(aiReport['concerns']);
      final monitorNext = aiReport['monitor_next'] as List? ?? [];
      final priorities = aiReport['research_priorities'] as List? ?? [];
      final investorQuestions = parseStringList(aiReport['investor_questions']);"""

target = """      final strengths = List<String>.from(aiReport['strengths'] ?? []);
      final concerns = List<String>.from(aiReport['concerns'] ?? []);
      final monitorNext = aiReport['monitor_next'] as List? ?? [];
      final priorities = aiReport['research_priorities'] as List? ?? [];
      final investorQuestions = List<String>.from(aiReport['investor_questions'] ?? []);"""

code = code.replace(target, replacement)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
print("Updated successfully")

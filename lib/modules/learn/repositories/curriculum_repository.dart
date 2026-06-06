import 'package:englishme/modules/learn/models/curriculum_models.dart';

/// Hợp đồng dữ liệu cho luồng giáo trình. FE chỉ phụ thuộc abstract này.
abstract class CurriculumRepository {
  Future<LevelUnits> getLevelUnits(String level);
  Future<UnitDetail> getUnitDetail(String unitId);
  Future<CurriculumLessonDetail> getLessonDetail(String lessonId);
  Future<void> completeTheory(String lessonId);

  /// Báo BE đã làm xong luyện tập (gửi đáp án thô practice → BE chấm + lưu
  /// practice_completed). Trả về true nếu BE xác nhận đã hoàn thành luyện tập.
  Future<bool> submitExercises(
    String lessonId,
    List<Map<String, dynamic>> answers,
  );

  /// Nộp mini-quiz: gửi ĐÁP ÁN THÔ từng câu, BE tự chấm điểm mastery.
  /// answers[i] = {activityId, selectedOptionId?|text?|order?}.
  Future<LessonResult> completeLesson(
    String lessonId,
    List<Map<String, dynamic>> answers,
  );

  /// Sinh thêm câu hỏi trắc nghiệm (AI) từ lý thuyết bài học để luyện thêm.
  /// [existingQuestions] = text các câu đã có/đã gen, để AI tránh tạo trùng.
  /// Trả list rỗng nếu BE không tạo được (thiếu key / lỗi AI).
  Future<List<CurriculumActivity>> generateExtraPractice(
    String lessonId,
    List<String> existingQuestions, {
    int count = 5,
  });

  /// Lấy trạng thái + đề Level Checkpoint Test (khoá nếu chưa đủ độ phủ unit).
  Future<CheckpointState> getCheckpoint(String level);

  /// Nộp checkpoint (đáp án thô) — pass → BE nâng cấp CEFR + +100 XP.
  Future<CheckpointResult> submitCheckpoint(
    String level,
    List<Map<String, dynamic>> answers,
  );
}

/// Repository GIẢ — trả dữ liệu cứng để xem giao diện. Có delay giả lập mạng.
class MockCurriculumRepository implements CurriculumRepository {
  // Trạng thái tạm trong RAM để demo "xem lý thuyết → mở bài tập", "pass → mở bài kế".
  final Set<String> _theoryViewed = {};
  final Set<String> _practiceCompleted = {};
  final Map<String, int> _bestScore = {};

  Future<T> _delay<T>(T value) =>
      Future.delayed(const Duration(milliseconds: 350), () => value);

  @override
  Future<LevelUnits> getLevelUnits(String level) {
    return _delay(LevelUnits.fromJson({
      'level': level,
      'levelProgress': 0.25,
      'completedUnits': 1,
      'totalUnits': 4,
      'checkpointUnlocked': false,
      'units': [
        {
          'id': 'a1-greetings',
          'level': 'A1',
          'title': 'Greetings & Introductions',
          'subtitle': 'Chào hỏi, giới thiệu bản thân',
          'order': 1,
          'status': 'in_progress',
          'lessonCount': 4,
          'completedLessonCount': 1,
          'skillCoverage': ['vocabulary', 'grammar', 'reading'],
        },
        {
          'id': 'a1-family',
          'level': 'A1',
          'title': 'Family & People',
          'subtitle': 'Gia đình, miêu tả người',
          'order': 2,
          'status': 'locked',
          'lessonCount': 4,
          'completedLessonCount': 0,
          'skillCoverage': ['vocabulary', 'grammar'],
        },
        {
          'id': 'a1-daily',
          'level': 'A1',
          'title': 'Daily Routine',
          'subtitle': 'Thói quen hằng ngày, thì hiện tại đơn',
          'order': 3,
          'status': 'locked',
          'lessonCount': 4,
          'completedLessonCount': 0,
          'skillCoverage': ['vocabulary', 'grammar', 'listening'],
        },
        {
          'id': 'a1-food',
          'level': 'A1',
          'title': 'Food & Drink',
          'subtitle': 'Đồ ăn thức uống, danh từ đếm được',
          'order': 4,
          'status': 'completed',
          'lessonCount': 4,
          'completedLessonCount': 4,
          'skillCoverage': ['vocabulary', 'reading'],
        },
      ],
    }));
  }

  @override
  Future<UnitDetail> getUnitDetail(String unitId) {
    return _delay(UnitDetail.fromJson({
      'id': unitId,
      'level': 'A1',
      'title': 'Greetings & Introductions',
      'subtitle': 'Chào hỏi, giới thiệu bản thân và người khác',
      'status': 'in_progress',
      'completedLessonCount': 1,
      'totalLessons': 4,
      'lessons': [
        {
          'id': 'a1-greetings-l1',
          'title': 'Hello & Goodbye',
          'subtitle': 'Chào hỏi cơ bản',
          'skill': 'vocabulary',
          'lessonOrder': 1,
          'status': 'completed',
          'theoryViewed': true,
          'bestScore': 90,
          'xpReward': 15,
          'durationMinutes': 8,
        },
        {
          'id': 'a1-greetings-l2',
          'title': "What's your name?",
          'subtitle': 'Hỏi tên & đại từ chủ ngữ',
          'skill': 'grammar',
          'lessonOrder': 2,
          'status': 'available',
          'theoryViewed': false,
          'bestScore': 0,
          'xpReward': 15,
          'durationMinutes': 9,
        },
        {
          'id': 'a1-greetings-l3',
          'title': 'Verb to be',
          'subtitle': 'Động từ to be hiện tại',
          'skill': 'grammar',
          'lessonOrder': 3,
          'status': 'locked',
          'theoryViewed': false,
          'bestScore': 0,
          'xpReward': 15,
          'durationMinutes': 10,
        },
        {
          'id': 'a1-greetings-l4',
          'title': 'Introducing others',
          'subtitle': 'Giới thiệu người khác',
          'skill': 'reading',
          'lessonOrder': 4,
          'status': 'locked',
          'theoryViewed': false,
          'bestScore': 0,
          'xpReward': 15,
          'durationMinutes': 10,
        },
      ],
    }));
  }

  @override
  Future<CurriculumLessonDetail> getLessonDetail(String lessonId) {
    return _delay(CurriculumLessonDetail.fromJson({
      'id': lessonId,
      'unitId': 'a1-greetings',
      'level': 'A1',
      'skill': 'vocabulary',
      'title': 'Hello & Goodbye',
      'subtitle': 'Chào hỏi cơ bản',
      'xpReward': 15,
      'requiredScoreToPass': 70,
      'theoryViewed': _theoryViewed.contains(lessonId),
      'practiceCompleted': _practiceCompleted.contains(lessonId),
      'status': _bestScore.containsKey(lessonId)
          ? 'completed'
          : (_theoryViewed.contains(lessonId) ? 'in_progress' : 'available'),
      'theory': {
        'warmup': 'Hai người đang vẫy tay chào nhau — bạn nghĩ họ đang nói gì?',
        'objectives': [
          'Chào hỏi theo thời điểm trong ngày',
          'Phân biệt Hello / Hi / Good morning',
          'Nói lời tạm biệt phù hợp',
        ],
        'vocabBlock': [
          {'word': 'Good morning', 'ipa': '/ɡʊd ˈmɔːnɪŋ/', 'meaningVi': 'Chào buổi sáng', 'example': 'Good morning, teacher!'},
          {'word': 'Good afternoon', 'ipa': '/ɡʊd ˌɑːftəˈnuːn/', 'meaningVi': 'Chào buổi chiều', 'example': 'Good afternoon, everyone.'},
          {'word': 'Goodbye', 'ipa': '/ɡʊdˈbaɪ/', 'meaningVi': 'Tạm biệt', 'example': 'Goodbye! See you tomorrow.'},
          {'word': 'See you', 'ipa': '/siː juː/', 'meaningVi': 'Hẹn gặp lại', 'example': 'See you later!'},
        ],
        'examples': [
          {'en': 'Good morning! How are you?', 'vi': 'Chào buổi sáng! Bạn khỏe không?'},
          {'en': 'Hi, nice to meet you.', 'vi': 'Chào, rất vui được gặp bạn.'},
        ],
        'commonMistakes': ['"Good night" là lời tạm biệt buổi tối, KHÔNG phải lời chào.'],
        'tips': ['Hi / Hello dùng được mọi lúc, không phụ thuộc thời điểm trong ngày.'],
      },
      'exercises': [
        {
          'id': 'p1', 'type': 'multiple_choice', 'phase': 'practice', 'difficulty': 'easy',
          'question': 'Lời chào nào dùng vào buổi sáng?',
          'options': [
            {'id': 'a', 'text': 'Good evening'},
            {'id': 'b', 'text': 'Good morning'},
            {'id': 'c', 'text': 'Goodbye'},
          ],
          'correctOptionId': 'b',
          'explanationVi': 'Good morning = chào buổi sáng.',
        },
        {
          'id': 'p2', 'type': 'multiple_choice', 'phase': 'practice', 'difficulty': 'medium',
          'question': 'Khi tạm biệt, bạn nói gì?',
          'options': [
            {'id': 'a', 'text': 'Good morning'},
            {'id': 'b', 'text': 'Hello'},
            {'id': 'c', 'text': 'Goodbye'},
          ],
          'correctOptionId': 'c',
          'explanationVi': 'Goodbye = tạm biệt.',
        },
        {
          'id': 'p3', 'type': 'grammar_fill_blank', 'phase': 'practice', 'difficulty': 'easy',
          'question': 'Điền từ còn thiếu: "Good ___, teacher!" (chào buổi sáng)',
          'acceptedAnswers': ['morning'],
          'explanationVi': 'Good morning = chào buổi sáng.',
        },
        {
          'id': 'p4', 'type': 'vocabulary_match', 'phase': 'practice', 'difficulty': 'medium',
          'question': 'Nối lời chào tiếng Anh với nghĩa tiếng Việt:',
          'pairs': [
            {'left': 'Good morning', 'right': 'Chào buổi sáng'},
            {'left': 'Goodbye', 'right': 'Tạm biệt'},
            {'left': 'See you', 'right': 'Hẹn gặp lại'},
          ],
          'explanationVi': 'Ghép đúng từng cặp lời chào với nghĩa của nó.',
        },
        // ── Các dạng bài tập MỞ RỘNG (demo UI) ──
        {
          'id': 'p5', 'type': 'sentence_ordering', 'phase': 'practice', 'difficulty': 'medium',
          'question': 'Sắp xếp các từ thành câu chào hỏi đúng:',
          // tokens xáo trộn; correctOrder = thứ tự index để ghép thành "Good morning to you"
          'tokens': ['morning', 'Good', 'you', 'to'],
          'correctOrder': [1, 0, 3, 2],
          'explanationVi': 'Câu đúng: "Good morning to you".',
        },
        {
          'id': 'p6', 'type': 'listening_choice', 'phase': 'practice', 'difficulty': 'easy',
          'question': 'Nghe và chọn lời chào bạn vừa nghe:',
          'audioText': 'Good afternoon',
          'options': [
            {'id': 'a', 'text': 'Good morning'},
            {'id': 'b', 'text': 'Good afternoon'},
            {'id': 'c', 'text': 'Good night'},
          ],
          'correctOptionId': 'b',
          'explanationVi': 'Câu nghe được là "Good afternoon".',
        },
        {
          'id': 'p7', 'type': 'pronunciation', 'phase': 'practice', 'difficulty': 'medium',
          'question': 'Đọc to câu sau và ghi âm:',
          'targetText': 'Good morning',
          'ipa': 'ɡʊd ˈmɔːnɪŋ',
          'minScoreToPass': 70,
          'explanationVi': 'Nhấn đúng trọng âm "MOR-ning".',
        },
        {
          'id': 'p8', 'type': 'translation', 'phase': 'practice', 'difficulty': 'medium',
          'question': 'Dịch câu sau sang tiếng Anh:',
          'sourceText': 'Chào buổi sáng',
          'acceptedAnswers': ['Good morning', 'good morning'],
          'explanationVi': '"Chào buổi sáng" = "Good morning".',
        },
        {
          'id': 'p9', 'type': 'error_correction', 'phase': 'practice', 'difficulty': 'hard',
          'question': 'Câu sau sai — hãy viết lại cho đúng:',
          'sourceText': 'Good night, nice to meet you!',
          'acceptedAnswers': [
            'Good morning, nice to meet you!',
            'Good afternoon, nice to meet you!',
          ],
          'explanationVi': '"Good night" là lời tạm biệt, không dùng khi gặp mặt. Dùng "Good morning/afternoon".',
        },
      ],
      'quiz': [
        {
          'id': 'q1', 'type': 'multiple_choice', 'phase': 'quiz', 'difficulty': 'medium',
          'question': 'Chọn lời chào buổi chiều:',
          'options': [
            {'id': 'a', 'text': 'Good afternoon'},
            {'id': 'b', 'text': 'Good night'},
            {'id': 'c', 'text': 'See you'},
          ],
          'correctOptionId': 'a',
          'explanationVi': 'Good afternoon = chào buổi chiều.',
        },
        {
          'id': 'q2', 'type': 'multiple_choice', 'phase': 'quiz', 'difficulty': 'easy',
          'question': '"See you later" có nghĩa là gì?',
          'options': [
            {'id': 'a', 'text': 'Xin chào'},
            {'id': 'b', 'text': 'Hẹn gặp lại'},
            {'id': 'c', 'text': 'Cảm ơn'},
          ],
          'correctOptionId': 'b',
          'explanationVi': 'See you later = hẹn gặp lại sau.',
        },
        {
          'id': 'q3', 'type': 'multiple_choice', 'phase': 'quiz', 'difficulty': 'hard',
          'question': 'Câu nào SAI khi dùng làm lời chào?',
          'options': [
            {'id': 'a', 'text': 'Good morning'},
            {'id': 'b', 'text': 'Good night'},
            {'id': 'c', 'text': 'Hello'},
          ],
          'correctOptionId': 'b',
          'explanationVi': '"Good night" là lời tạm biệt buổi tối, không phải lời chào.',
        },
        {
          'id': 'q4', 'type': 'grammar_fill_blank', 'phase': 'quiz', 'difficulty': 'medium',
          'question': 'Điền từ: "Good ___" là lời chào buổi chiều.',
          'acceptedAnswers': ['afternoon'],
          'explanationVi': 'Good afternoon = chào buổi chiều.',
        },
        {
          'id': 'q5', 'type': 'listening_choice', 'phase': 'quiz', 'difficulty': 'medium',
          'question': 'Nghe và chọn lời chào đúng:',
          'audioText': 'See you later',
          'options': [
            {'id': 'a', 'text': 'See you later'},
            {'id': 'b', 'text': 'Good morning'},
            {'id': 'c', 'text': 'Nice to meet you'},
          ],
          'correctOptionId': 'a',
          'explanationVi': 'Câu nghe được là "See you later".',
        },
        {
          'id': 'q6', 'type': 'sentence_ordering', 'phase': 'quiz', 'difficulty': 'hard',
          'question': 'Sắp xếp thành câu hỏi đúng:',
          // "Nice to meet you" — tokens xáo trộn
          'tokens': ['to', 'Nice', 'you', 'meet'],
          'correctOrder': [1, 0, 3, 2],
          'explanationVi': 'Câu đúng: "Nice to meet you".',
        },
      ],
    }));
  }

  @override
  Future<void> completeTheory(String lessonId) {
    _theoryViewed.add(lessonId);
    return _delay(null);
  }

  @override
  Future<bool> submitExercises(
    String lessonId,
    List<Map<String, dynamic>> answers,
  ) {
    // Mock: coi như đã xong luyện tập (FE đã tự chấm từng câu trước khi gọi).
    _practiceCompleted.add(lessonId);
    return _delay(true);
  }

  @override
  Future<LessonResult> completeLesson(
    String lessonId,
    List<Map<String, dynamic>> answers,
  ) {
    // Mock: chấm thô rất đơn giản — đếm số câu có đáp án "trông như đã trả lời".
    // (Bản thật do BE chấm; mock chỉ để xem UI offline.)
    final answered = answers
        .where((a) =>
            (a['selectedOptionId'] != null) ||
            ((a['text'] ?? '').toString().trim().isNotEmpty) ||
            ((a['order'] as List?)?.isNotEmpty ?? false))
        .length;
    final score = answers.isEmpty ? 0 : ((answered / answers.length) * 100).round();
    final passed = score >= 70;
    if (passed && (_bestScore[lessonId] ?? 0) < score) {
      _bestScore[lessonId] = score;
    }
    return _delay(LessonResult(
      passed: passed,
      score: score,
      xpEarned: passed ? 15 : 0,
      unitProgress: passed ? 0.5 : 0.25,
      unitCompleted: false,
      nextLessonId: passed ? 'a1-greetings-l2' : null,
    ));
  }

  @override
  Future<List<CurriculumActivity>> generateExtraPractice(
    String lessonId,
    List<String> existingQuestions, {
    int count = 5,
  }) {
    // Mock: trả câu MCQ cứng để test UI offline (khác nhau theo số câu đã gen).
    final seed = existingQuestions.length;
    return _delay(List.generate(count, (i) {
      final n = seed + i + 1;
      return CurriculumActivity.fromJson({
        'id': 'gen-$n',
        'type': 'multiple_choice',
        'phase': 'practice',
        'difficulty': 'medium',
        'question': '[Demo $n] Lời chào nào phù hợp buổi sáng?',
        'options': [
          {'id': 'a', 'text': 'Good morning'},
          {'id': 'b', 'text': 'Good night'},
          {'id': 'c', 'text': 'Goodbye'},
          {'id': 'd', 'text': 'See you'},
        ],
        'correctOptionId': 'a',
        'explanationVi': 'Good morning = chào buổi sáng.',
      });
    }));
  }

  @override
  Future<CheckpointState> getCheckpoint(String level) {
    return _delay(CheckpointState.fromJson({
      'level': level,
      'nextLevel': 'A2',
      'title': 'Kiểm tra cuối cấp $level',
      'unlocked': true,
      'unitProgress': 0.8,
      'requiredUnitProgress': 0.8,
      'passScore': 75,
      'alreadyPassed': false,
      'questions': [
        {
          'id': 'cp1', 'type': 'multiple_choice', 'phase': 'quiz',
          'question': 'Chọn lời chào buổi sáng:',
          'options': [
            {'id': 'a', 'text': 'Good morning'},
            {'id': 'b', 'text': 'Good night'},
          ],
        },
        {
          'id': 'cp2', 'type': 'grammar_fill_blank', 'phase': 'quiz',
          'question': 'I ___ a student.',
        },
      ],
    }));
  }

  @override
  Future<CheckpointResult> submitCheckpoint(
    String level,
    List<Map<String, dynamic>> answers,
  ) {
    final answered = answers
        .where((a) =>
            (a['selectedOptionId'] != null) ||
            ((a['text'] ?? '').toString().trim().isNotEmpty) ||
            ((a['order'] as List?)?.isNotEmpty ?? false))
        .length;
    final score = answers.isEmpty ? 0 : ((answered / answers.length) * 100).round();
    final passed = score >= 75;
    return _delay(CheckpointResult.fromJson({
      'passed': passed,
      'score': score,
      'passScore': 75,
      'leveledUp': passed,
      'fromLevel': level,
      'toLevel': 'A2',
      'xpEarned': passed ? 100 : 0,
    }));
  }
}

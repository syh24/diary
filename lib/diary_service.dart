import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary {
  String text;
  DateTime createdAt;

  Diary({
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "createdAt": createdAt.toString(),
    };
  }

  factory Diary.fromJson(Map<String, dynamic> jsonMap) {
    return Diary(
      text: jsonMap['text'],
      // 문자열로 넘어온 시간을 DateTime으로 다시 바꿔줍니다.
      createdAt: DateTime.parse(jsonMap['createdAt']),
    );
  }
}

class DiaryService extends ChangeNotifier {
  DiaryService(this.prefs) {
    List<String> stringDiaryList = prefs.getStringList("diaryList") ?? [];
    for (String stringDiary in stringDiaryList) {
      Map<String, dynamic> jsonMap = jsonDecode(stringDiary);
      Diary diary = Diary.fromJson(jsonMap);
      diaryList.add(diary);
    }
  }

  SharedPreferences prefs;

  /// Diary 목록
  List<Diary> diaryList = [];

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date) {
    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList();
  }

  /// Diary 작성
  void create(String text, DateTime selectedDate) {
    DateTime now = DateTime.now();

    // 선택된 날짜(selectedDate)에 현재 시간으로 추가
    DateTime createdAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    Diary diary = Diary(
      text: text,
      createdAt: createdAt,
    );
    diaryList.add(diary);
    notifyListeners();
    _saveDiaryList();
  }

  /// Diary 수정
  void update(DateTime createdAt, String newContent) {
    Diary diary = diaryList.firstWhere((diary) => diary.createdAt == createdAt);
    diary.text = newContent;
    notifyListeners();
    _saveDiaryList();
  }

  /// Diary 삭제
  void delete(DateTime createdAt) {
    diaryList.removeWhere((diary) => createdAt == diary.createdAt);
    notifyListeners();
    _saveDiaryList();
  }

  void _saveDiaryList() {
    List<String> stringDiaryList = [];

    for (Diary diary in diaryList) {
      stringDiaryList.add(jsonEncode(diary.toJson()));
    }

    prefs.setStringList("diaryList", stringDiaryList);
  }
}

class Demo {
  Demo({
      this.startTime, 
      this.endTime, 
      this.weekdays, 
      this.tokens,});

  Demo.fromJson(dynamic json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    weekdays = json['weekdays'] != null ? json['weekdays'].cast<int>() : [];
    tokens = json['tokens'];
  }
  String startTime;
  String endTime;
  List<int> weekdays;
  int tokens;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['weekdays'] = weekdays;
    map['tokens'] = tokens;
    return map;
  }

}
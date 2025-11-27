class TableRowData {
  DateTime? date;
  String? day;
  Map<String, List<String>> classSubjects;

  TableRowData({this.date, this.day, Map<String, List<String>>? classSubjects})
    : classSubjects =
          classSubjects ??
          {
            'I': [],
            'II': [],
            'III': [],
            'IV': [],
            'V': [],
            'VI': [],
            'VII': [],
            'VIII': [],
            'IX': [],
            'X': [],
            'XI': [],
            'XII': [],
          };
}

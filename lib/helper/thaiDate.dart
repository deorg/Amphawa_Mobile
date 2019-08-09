class ThaiDate{
  dynamic monthName = ['', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'];
  dynamic monthShortName = ['', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'ม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
  dynamic dayName = ['', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัส', 'ศุกร์', 'เสาร์', 'อาทิตย์'];
  dynamic dayShortName = ['', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อ.'];

  ThaiDate(this.date);
  final DateTime date;

  String get fullThaiDate => getFullThaiDate();
  String get thaiDay => dayName[date.weekday];
  String get thaiShortDay => dayShortName[date.weekday];
  String get thaiMonth => monthName[date.month];
  String get thaiShortMonth => monthShortName[date.month];
  String get thaiYear => (date.year+543).toString();
  String get thaiShortYear => (date.year+543).toString().substring(2,4);


  String getFullThaiDate(){
    return '${date.day} ${monthName[date.month]} ${date.year+543}';
  }
}
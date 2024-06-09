class EventAppointment {
  late int eventId;
  late DateTime startTime;
  late DateTime endTime;
  late String subject;

  EventAppointment(int id, String start, String difference, String caption) {
    eventId = id;
    startTime = DateTime.parse(start);
    String time = difference;
    List<String> timeParts = time.split(':');
    Duration duration = Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[2]));
    endTime = startTime.add(duration);
    subject = caption;
  }
}

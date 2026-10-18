import 'package:centrally/models/centerly_models.dart';

class CenterlyMockData {
  CenterlyMockData._();

  static final List<Student> students = [
    Student(
      id: 'student-1',
      teacherId: 'teacher-1',
      groupId: 'group-1',
      name: 'أحمد عبد الرحمن محمد',
      phone: '0123456789',
      guardianPhone: '0123456789',
      levelTag: 'المستوى الأول',
      qrCodeValue: '48923',
      teacherNote:
          'أحمد جيد، ولكنه تأخر قليلًا. الممارسة واجبة فورًا في البلاغة ويحتاج للتركيز على الأدب.',
      createdAt: DateTime(2026, 4, 1),
    ),
    Student(
      id: 'student-2',
      teacherId: 'teacher-1',
      groupId: 'group-1',
      name: 'عبد الرحمن محمد عبد الرحيم',
      phone: '01011223344',
      guardianPhone: '01011223355',
      levelTag: 'المستوى الأول',
      qrCodeValue: '48924',
      createdAt: DateTime(2026, 4, 2),
    ),
    Student(
      id: 'student-3',
      teacherId: 'teacher-1',
      groupId: 'group-1',
      name: 'مريم علي حسن',
      phone: '01022334455',
      guardianPhone: '01022334466',
      levelTag: 'المستوى الأول',
      qrCodeValue: '48925',
      createdAt: DateTime(2026, 4, 3),
    ),
    Student(
      id: 'student-4',
      teacherId: 'teacher-1',
      groupId: 'group-2',
      name: 'يوسف خالد محمود',
      phone: '01033445566',
      guardianPhone: '01033445577',
      levelTag: 'المستوى الثاني',
      qrCodeValue: '48926',
      createdAt: DateTime(2026, 4, 4),
    ),
    Student(
      id: 'student-5',
      teacherId: 'teacher-1',
      groupId: 'group-2',
      name: 'ليلى سامي إبراهيم',
      phone: '01044556677',
      guardianPhone: '01044556688',
      levelTag: 'المستوى الثاني',
      qrCodeValue: '48927',
      createdAt: DateTime(2026, 4, 5),
    ),
  ];

  static final List<Group> groups = [
    Group(
      id: 'group-1',
      teacherId: 'teacher-1',
      gradeLevelId: 'grade-10',
      gradeLevelName: 'الصف الأول الثانوي',
      name: 'مجموعة أ',
      subjectName: 'فيزياء',
      capacity: 44,
      scheduleLabel: 'الخميس - الثلاثاء',
      nextSessionAt: DateTime(2026, 4, 25, 9),
      createdAt: DateTime(2026, 4, 1),
    ),
    Group(
      id: 'group-2',
      teacherId: 'teacher-1',
      gradeLevelId: 'grade-10',
      gradeLevelName: 'الصف الأول الثانوي',
      name: 'مجموعة ب',
      subjectName: 'فيزياء',
      capacity: 25,
      scheduleLabel: 'السبت - الأربعاء',
      nextSessionAt: DateTime(2026, 4, 26, 13),
      createdAt: DateTime(2026, 4, 4),
    ),
    Group(
      id: 'group-3',
      teacherId: 'teacher-1',
      gradeLevelId: 'grade-11',
      gradeLevelName: 'الصف الثاني الثانوي',
      name: 'مجموعة ج',
      subjectName: 'فيزياء',
      capacity: 20,
      scheduleLabel: 'الأحد - الثلاثاء',
      nextSessionAt: DateTime(2026, 4, 27, 10),
      createdAt: DateTime(2026, 4, 6),
    ),
  ];

  static final List<Session> sessions = [
    Session(
      id: 'session-1',
      teacherId: 'teacher-1',
      groupId: 'group-1',
      date: DateTime(2026, 4, 14),
      startTime: DateTime(2026, 4, 14, 10),
      endTime: DateTime(2026, 4, 14, 12),
      status: SessionStatus.ongoing,
      expectedStudentsCount: 20,
      attendanceLockAt: DateTime(2026, 4, 14, 10, 30),
      createdAt: DateTime(2026, 4, 7),
    ),
    Session(
      id: 'session-2',
      teacherId: 'teacher-1',
      groupId: 'group-2',
      date: DateTime(2026, 4, 14),
      startTime: DateTime(2026, 4, 14, 12),
      endTime: DateTime(2026, 4, 14, 14),
      status: SessionStatus.upcoming,
      expectedStudentsCount: 20,
      attendanceLockAt: DateTime(2026, 4, 14, 12, 30),
      createdAt: DateTime(2026, 4, 7),
    ),
    Session(
      id: 'session-3',
      teacherId: 'teacher-1',
      groupId: 'group-3',
      date: DateTime(2026, 4, 15),
      startTime: DateTime(2026, 4, 15, 10),
      endTime: DateTime(2026, 4, 15, 12),
      status: SessionStatus.completed,
      expectedStudentsCount: 15,
      attendanceLockAt: DateTime(2026, 4, 15, 10, 30),
      createdAt: DateTime(2026, 4, 8),
    ),
    Session(
      id: 'session-4',
      teacherId: 'teacher-1',
      groupId: 'group-1',
      date: DateTime(2026, 4, 17),
      startTime: DateTime(2026, 4, 17, 10),
      endTime: DateTime(2026, 4, 17, 12),
      status: SessionStatus.cancelled,
      expectedStudentsCount: 18,
      attendanceLockAt: DateTime(2026, 4, 17, 10, 30),
      cancelReasonType: 'technical_issue',
      cancelReasonText: 'عطل فني',
      cancelledByType: UserRole.teacher,
      cancelledById: 'teacher-1',
      cancelledAt: DateTime(2026, 4, 16, 20),
      createdAt: DateTime(2026, 4, 10),
    ),
  ];

  static final List<Attendance> attendance = [
    Attendance(
      id: 'attendance-1',
      sessionId: 'session-1',
      studentId: 'student-1',
      status: AttendanceStatus.present,
      markedByType: MarkedByType.secretary,
      markedById: 'secretary-1',
      markedAt: DateTime(2026, 4, 14, 9, 55),
      updatedAt: DateTime(2026, 4, 14, 9, 55),
    ),
    Attendance(
      id: 'attendance-2',
      sessionId: 'session-1',
      studentId: 'student-2',
      status: AttendanceStatus.present,
      markedByType: MarkedByType.secretary,
      markedById: 'secretary-1',
      markedAt: DateTime(2026, 4, 14, 9, 56),
      updatedAt: DateTime(2026, 4, 14, 9, 56),
    ),
    Attendance(
      id: 'attendance-3',
      sessionId: 'session-1',
      studentId: 'student-3',
      status: AttendanceStatus.absent,
      markedByType: MarkedByType.secretary,
      markedById: 'secretary-1',
      markedAt: DateTime(2026, 4, 14, 10, 5),
      updatedAt: DateTime(2026, 4, 14, 10, 5),
    ),
    Attendance(
      id: 'attendance-4',
      sessionId: 'session-1',
      studentId: 'student-4',
      status: AttendanceStatus.excused,
      markedByType: MarkedByType.secretary,
      markedById: 'secretary-1',
      markedAt: DateTime(2026, 4, 14, 10, 8),
      updatedAt: DateTime(2026, 4, 14, 10, 8),
    ),
  ];

  static final List<Invoice> invoices = [
    Invoice(
      id: 'invoice-1',
      teacherId: 'teacher-1',
      studentId: 'student-1',
      groupId: 'group-1',
      invoiceNumber: '#4526',
      amount: 400,
      dueDate: DateTime(2026, 5, 10),
      status: InvoiceStatus.paid,
      paidAmount: 400,
      paidAt: DateTime(2026, 5, 10),
      paidBy: 'secretary-1',
      createdAt: DateTime(2026, 5, 1),
    ),
    Invoice(
      id: 'invoice-2',
      teacherId: 'teacher-1',
      studentId: 'student-1',
      groupId: 'group-1',
      invoiceNumber: '#4527',
      amount: 400,
      dueDate: DateTime(2026, 5, 10),
      status: InvoiceStatus.due,
      paidAmount: 0,
      createdAt: DateTime(2026, 5, 1),
    ),
    Invoice(
      id: 'invoice-3',
      teacherId: 'teacher-1',
      studentId: 'student-2',
      groupId: 'group-1',
      invoiceNumber: '#4528',
      amount: 750,
      dueDate: DateTime(2026, 5, 30),
      status: InvoiceStatus.paid,
      paidAmount: 750,
      paidAt: DateTime(2026, 5, 18),
      paidBy: 'secretary-1',
      createdAt: DateTime(2026, 5, 1),
    ),
  ];

  static final List<Exam> exams = [
    Exam(
      id: 'exam-1',
      teacherId: 'teacher-1',
      studentId: 'student-1',
      groupId: 'group-1',
      title: 'اختبار الشهر',
      date: DateTime(2026, 5, 10),
      scorePercent: 89,
      enteredBy: 'secretary-1',
      createdAt: DateTime(2026, 5, 10),
      updatedAt: DateTime(2026, 5, 10),
    ),
    Exam(
      id: 'exam-2',
      teacherId: 'teacher-1',
      studentId: 'student-1',
      groupId: 'group-1',
      title: 'اختبار الشهر',
      date: DateTime(2026, 5, 10),
      scorePercent: 49,
      enteredBy: 'secretary-1',
      createdAt: DateTime(2026, 5, 10),
      updatedAt: DateTime(2026, 5, 10),
    ),
  ];

  static final List<Assignment> assignments = [
    Assignment(
      id: 'assignment-1',
      teacherId: 'teacher-1',
      studentId: 'student-1',
      groupId: 'group-1',
      title: 'الدرس الأول',
      date: DateTime(2026, 5, 10),
      status: AssignmentStatus.submitted,
      enteredBy: 'secretary-1',
      createdAt: DateTime(2026, 5, 10),
      updatedAt: DateTime(2026, 5, 10),
    ),
    Assignment(
      id: 'assignment-2',
      teacherId: 'teacher-1',
      studentId: 'student-1',
      groupId: 'group-1',
      title: 'الدرس الثاني',
      date: DateTime(2026, 5, 10),
      status: AssignmentStatus.late,
      enteredBy: 'secretary-1',
      createdAt: DateTime(2026, 5, 10),
      updatedAt: DateTime(2026, 5, 10),
    ),
  ];

  static final List<SecretaryProfile> secretaries = [
    const SecretaryProfile(
      id: 'secretary-1',
      teacherId: 'teacher-1',
      name: 'سارة محمود',
      phone: '01055667788',
      email: 'sara@centerly.app',
      status: SecretaryStatus.active,
    ),
    const SecretaryProfile(
      id: 'secretary-2',
      teacherId: 'teacher-1',
      name: 'منة خالد',
      phone: '01066778899',
      email: 'menna@centerly.app',
      status: SecretaryStatus.inactive,
    ),
  ];

  static final List<SecretaryRemovalRequest> secretaryRemovalRequests = [
    SecretaryRemovalRequest(
      id: 'request-1',
      teacherId: 'teacher-1',
      secretaryId: 'secretary-2',
      status: RemovalRequestStatus.handled,
      requestedAt: DateTime(2026, 4, 12),
      handledAt: DateTime(2026, 4, 13),
    ),
  ];

  static Group groupById(String id) =>
      groups.firstWhere((group) => group.id == id);

  static Student studentById(String id) =>
      students.firstWhere((student) => student.id == id);

  static List<Student> studentsForGroup(String groupId) =>
      students.where((student) => student.groupId == groupId).toList();

  static List<Attendance> attendanceForSession(String sessionId) =>
      attendance.where((item) => item.sessionId == sessionId).toList();
}

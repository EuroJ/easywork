import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TaskCreationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = Uuid();

  static Future<void> createDemoTasks() async {
    // หา UIDs ของ users
    final usersSnapshot = await _firestore.collection('users').get();
    final users = usersSnapshot.docs;
    
    if (users.length < 2) {
      print('❌ Need at least 2 users to create tasks');
      return;
    }

    final adminUser = users.firstWhere((u) => u.data()['role'] == 'admin');
    final employees = users.where((u) => u.data()['role'] == 'employee').toList();

    final demoTasks = [
      {
        'title': 'ອັບເດດລະບົບຈັດການ',
        'description': 'ປັບປຸງລະບົບຈັດການງານໃຫ້ທັນສະໄໝ ແລະ ເພີ່ມຟີເຈີໃໝ່',
        'priority': 2, // high
        'category': 'Development',
        'daysFromNow': 7,
        'progress': 45.0,
        'status': 1, // inProgress
      },
      {
        'title': 'ລາຍງານປະຈໍາເດືອນ', 
        'description': 'ຈັດທໍາລາຍງານສະຫຼຸບຜົນງານປະຈໍາເດືອນ',
        'priority': 1, // medium
        'category': 'Report',
        'daysFromNow': 3,
        'progress': 0.0,
        'status': 0, // pending
      },
      {
        'title': 'ປັບປຸງ UI ໃໝ່',
        'description': 'ອອກແບບ UI ໃໝ່ໃຫ້ສວຍງາມ ແລະ ໃຊ້ງານງ່າຍ',
        'priority': 1, // medium  
        'category': 'Design',
        'daysFromNow': -2, // overdue
        'progress': 100.0,
        'status': 2, // completed
      },
      {
        'title': 'ທົດສອບລະບົບ',
        'description': 'ທົດສອບການເຮັດວຽກຂອງລະບົບໃໝ່',
        'priority': 2, // high
        'category': 'Testing', 
        'daysFromNow': 1,
        'progress': 25.0,
        'status': 1, // inProgress
      },
      {
        'title': 'ຝຶກອົບຮົມພະນັກງານ',
        'description': 'ຈັດການຝຶກອົບຮົມພະນັກງານໃໝ່',
        'priority': 0, // low
        'category': 'Training',
        'daysFromNow': 14,
        'progress': 0.0,
        'status': 0, // pending
      },
    ];

    for (int i = 0; i < demoTasks.length; i++) {
      final task = demoTasks[i];
      final assignedEmployee = employees[i % employees.length];
      
      final dueDate = DateTime.now().add(Duration(days: task['daysFromNow'] as int));
      
      await _firestore.collection('tasks').doc(_uuid.v4()).set({
        'id': _uuid.v4(),
        'title': task['title'],
        'description': task['description'],
        'createdBy': adminUser.id,
        'assignedTo': assignedEmployee.id,
        'status': task['status'],
        'priority': task['priority'],
        'category': task['category'],
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': dueDate.millisecondsSinceEpoch,
        'completedAt': task['status'] == 2 ? DateTime.now().millisecondsSinceEpoch : null,
        'attachments': [],
        'comments': [],
        'progress': task['progress'],
      });
    }

    print('✅ Created ${demoTasks.length} demo tasks');
  }
}
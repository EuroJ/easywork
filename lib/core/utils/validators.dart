class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນອີເມລ';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'ຮູບແບບອີເມລບໍ່ຖືກຕ້ອງ';
    }
    
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
    }
    
    if (value.length < 6) {
      return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
    }
    
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານ';
    }
    
    if (value != password) {
      return 'ລະຫັດຜ່ານບໍ່ກົງກັນ';
    }
    
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນ${fieldName ?? 'ຂໍ້ມູນ'}';
    }
    
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນຊື່';
    }
    
    if (value.trim().length < 2) {
      return 'ຊື່ຕ້ອງມີຢ່າງໜ້ອຍ 2 ຕົວອັກສອນ';
    }
    
    return null;
  }

  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນຫົວຂໍ້ວຽກງານ';
    }
    
    if (value.trim().length < 3) {
      return 'ຫົວຂໍ້ວຽກງານຕ້ອງມີຢ່າງໜ້ອຍ 3 ຕົວອັກສອນ';
    }
    
    return null;
  }

  static String? taskDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນລາຍລະອຽດວຽກງານ';
    }
    
    if (value.trim().length < 10) {
      return 'ລາຍລະອຽດວຽກງານຕ້ອງມີຢ່າງໜ້ອຍ 10 ຕົວອັກສອນ';
    }
    
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນເບີໂທລະສັບ';
    }
    
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'ຮູບແບບເບີໂທລະສັບບໍ່ຖືກຕ້ອງ';
    }
    
    return null;
  }

  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນ${fieldName ?? 'ຂໍ້ມູນ'}';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'ຂໍ້ມູນ'}ຕ້ອງມີຢ່າງໜ້ອຍ $minLength ຕົວອັກສອນ';
    }
    
    return null;
  }

  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'ຂໍ້ມູນ'}ຕ້ອງບໍ່ເກີນ $maxLength ຕົວອັກສອນ';
    }
    
    return null;
  }

  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນ${fieldName ?? 'ຕົວເລກ'}';
    }
    
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'ຂໍ້ມູນ'}ຕ້ອງເປັນຕົວເລກ';
    }
    
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    final numericResult = numeric(value, fieldName: fieldName);
    if (numericResult != null) return numericResult;
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '${fieldName ?? 'ຕົວເລກ'}ຕ້ອງເປັນຄ່າບວກ';
    }
    
    return null;
  }

  static String? range(String? value, double min, double max, {String? fieldName}) {
    final numericResult = numeric(value, fieldName: fieldName);
    if (numericResult != null) return numericResult;
    
    final number = double.parse(value!);
    if (number < min || number > max) {
      return '${fieldName ?? 'ຄ່າ'}ຕ້ອງຢູ່ລະຫວ່າງ $min ແລະ $max';
    }
    
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນ URL';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'ຮູບແບບ URL ບໍ່ຖືກຕ້ອງ';
    }
    
    return null;
  }

  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
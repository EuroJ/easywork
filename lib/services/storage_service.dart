import 'dart:math';

class StorageService {
  static const bool ENABLE_FILE_UPLOAD = false; // ปิดการอัพโหลดไฟล์
  
  // สร้าง Avatar URL แบบฟรี
  static String generateAvatarUrl({
    required String name,
    required String userId,
    int size = 200,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final colors = [
      '6366F1', // Primary blue
      '8B5CF6', // Purple  
      '06B6D4', // Cyan
      '10B981', // Green
      'F59E0B', // Orange
      'EF4444', // Red
      'EC4899', // Pink
      '8B5A2B', // Brown
    ];
    
    // ใช้ userId สร้างสีที่ consistent
    final colorIndex = userId.hashCode.abs() % colors.length;
    final backgroundColor = colors[colorIndex];
    
    return 'https://ui-avatars.com/api/'
           '?name=$initial'
           '&background=$backgroundColor'
           '&color=fff'
           '&size=$size'
           '&rounded=true'
           '&bold=true';
  }
  
  // จัดการไฟล์แนบแบบง่าย (เก็บชื่อไฟล์อย่างเดียว)
  static Map<String, dynamic> createFileReference({
    required String fileName,
    required String fileType,
    required int fileSize,
    String? description,
  }) {
    return {
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'description': description ?? '',
      'uploadedAt': DateTime.now().millisecondsSinceEpoch,
      'url': 'local:///$fileName', // Mock URL
      'isLocal': true,
    };
  }
  
  // สร้าง placeholder สำหรับไฟล์ประเภทต่างๆ
  static String getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'https://img.icons8.com/color/96/pdf.png';
      case 'doc':
      case 'docx':
        return 'https://img.icons8.com/color/96/microsoft-word-2019.png';
      case 'xls':
      case 'xlsx':
        return 'https://img.icons8.com/color/96/microsoft-excel-2019.png';
      case 'ppt':
      case 'pptx':
        return 'https://img.icons8.com/color/96/microsoft-powerpoint-2019.png';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'https://img.icons8.com/color/96/image.png';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'https://img.icons8.com/color/96/video.png';
      case 'mp3':
      case 'wav':
        return 'https://img.icons8.com/color/96/audio.png';
      case 'zip':
      case 'rar':
        return 'https://img.icons8.com/color/96/archive.png';
      default:
        return 'https://img.icons8.com/color/96/file.png';
    }
  }
  
  // ตรวจสอบขนาดไฟล์ (สำหรับอนาคต)
  static bool isFileSizeValid(int fileSizeInBytes, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeBytes;
  }
  
  // สร้าง demo attachments
  static List<Map<String, dynamic>> createDemoAttachments() {
    return [
      createFileReference(
        fileName: 'requirements.pdf',
        fileType: 'pdf',
        fileSize: 2048000,
        description: 'เอกสารความต้องการ',
      ),
      createFileReference(
        fileName: 'design_mockup.png',
        fileType: 'png', 
        fileSize: 1024000,
        description: 'ภาพ mockup การออกแบบ',
      ),
    ];
  }
}
import 'dart:math';

class UtilsClass{


  String generateUniquePhoneNumber() {
    final random = Random();
    final Set<String> generatedNumbers = {};
    String phoneNumber;
    do {
      phoneNumber = '1';
      for (int i = 0; i < 10; i++) {
        phoneNumber += random.nextInt(10).toString();
      }
    } while (generatedNumbers.contains(phoneNumber));
    generatedNumbers.add(phoneNumber);
    return phoneNumber;
  }
}
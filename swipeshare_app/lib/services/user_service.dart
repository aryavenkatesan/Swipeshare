import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeshare_app/models/user.dart';

class UserService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Get user data once (static)
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _fireStore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Optional: Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _fireStore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<void> updatePaymentTypes(String uid, List<String> paymentTypes) async {
    try {
      await _fireStore.collection('users').doc(uid).update({
        'payment_types': paymentTypes,
      });
    } catch (e) {
      print('Error updating payment types: $e');
    }
  }
}

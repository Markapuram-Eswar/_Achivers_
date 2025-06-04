const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationToStudent = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const rollNumber = notification.rollNumber;

    // Find user by roll number
    const userQuery = await admin
      .firestore()
      .collection("users")
      .where("rollNumber", "==", rollNumber)
      .where("role", "==", "student")
      .get();

    if (!userQuery.empty) {
      const userDoc = userQuery.docs[0];
      const fcmToken = userDoc.data().fcmToken;

      if (fcmToken) {
        const message = {
          notification: {
            title: notification.title,
            body: notification.body,
          },
          token: fcmToken,
        };

        await admin.messaging().send(message);
      }
    }
  });

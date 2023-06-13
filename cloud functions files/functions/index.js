const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnStatusChange = functions
    .region('asia-southeast1')
    .database.ref('/appointments/{differentId}/notifState')
    .onUpdate(async (change, context) => {
        const newStatus = change.after.val();
        const previousStatus = change.before.val();

        // Check if the value changed from 'no' to 'yes'
        if (previousStatus === 'no' && newStatus === 'yes') {
            const differentId = context.params.differentId;

            try {
                // Get the device token or user ID associated with the differentId
                const snapshot = await admin.database()
                    .ref(`/appointments/${differentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Test Notif',
                        body: 'Please Work',
                    },
                };

                // Send the message
                admin.messaging().send(message)
                    .then((response) => {
                        // Handle the response
                        console.log('Successfully sent notification:', response);
                    })
                    .catch((error) => {
                        // Handle the error
                        console.error('Error sending notification:', error);
                    });
            } catch (error) {
                console.error('Error sending push notification ($differentID):', error);
            }
        }
    });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnStatusChange = functions
    .region('asia-southeast1')
    .database.ref('/appointments/{differentId}/requestStatus')
    .onUpdate(async (change, context) => {
        const newStatus = change.after.val();
        const previousStatus = change.before.val();

        // pending to upcoming
        if (previousStatus === 'PENDING' && newStatus === 'UPCOMING') {
            const differentId = context.params.differentId;

            try {
                // Get the device token or user ID associated with the differentId
                // Student Token
                const snapshot = await admin.database()
                    .ref(`/appointments/${differentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                //Prof FName
                const snapshot2 = await admin.database()
                    .ref(`/appointments/${differentId}/professorName`)
                    .once('value');
                const profName = snapshot2.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Appointment Status',
                        body: `Your appointment is approved by ${profName}`,
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
                console.error(`Error sending push notification ${differentID} 1:`, error);
            }

            // pending to cancel
        } else if (previousStatus === 'PENDING' && newStatus === 'CANCELED') {
            const differentId = context.params.differentId;
            try {
                // Get the device token or user ID associated with the differentId
                // Student Token
                const snapshot = await admin.database()
                    .ref(`/appointments/${differentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                //Prof FName
                const snapshot2 = await admin.database()
                    .ref(`/appointments/${differentId}/professorName`)
                    .once('value');
                const profName = snapshot2.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Appointment Status',
                        body: `Your appointment is cancelled by ${profName}`,
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
                console.error(`Error sending push notification (${differentID}) 2:`, error);
            }

            //approved to cancel
        } else if (previousStatus === 'UPCOMING' && newStatus === 'CANCELED') {
            const differentId = context.params.differentId;
            try {
                // Get the device token or user ID associated with the differentId
                // Student Token
                const snapshot = await admin.database()
                    .ref(`/appointments/${differentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                //Prof FName
                const snapshot2 = await admin.database()
                    .ref(`/appointments/${differentId}/professorName`)
                    .once('value');
                const profName = snapshot2.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Appointment Status',
                        body: `Your appointment is canceled by ${profName}`,
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
                console.error(`Error sending push notification ${differentID} 3:`, error);
            }
        }
    });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

//students
exports.sendNotificationOnStatusChange = functions
    .region('asia-southeast1')
    .database.ref('/appointments/{appointmentId}/requestStatus')
    .onUpdate(async (change, context) => {
        const newStatus = change.after.val();
        const previousStatus = change.before.val();

        // pending to upcoming
        if (previousStatus === 'PENDING' && newStatus === 'UPCOMING') {
            const appointmentId = context.params.appointmentId;

            try {
                // Get the device token or user ID associated with the appointmentId
                // Student Token
                const snapshot = await admin.database()
                    .ref(`/appointments/${appointmentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                //Prof FName
                const snapshot2 = await admin.database()
                    .ref(`/appointments/${appointmentId}/professorName`)
                    .once('value');
                const profName = snapshot2.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Appointment Status',
                        body: `Your appointment with ${profName} has been set.`,
                    },
                };

                // Send the message
                admin.messaging().send(message)
                    .then((response) => {
                        // Handle the response
                        console.log('Successfully sent notification 1:', response);
                    })
                    .catch((error) => {
                        // Handle the error
                        console.error('Error sending notification 1:', error);
                    });
            } catch (error) {
                console.error('Error sending push notification 1:', error);
            }

            // pending to cancel
        } else if (previousStatus === 'PENDING' && newStatus === 'CANCELED') {
            const appointmentId = context.params.appointmentId;
            try {
                // Get the device token or user ID associated with the appointmentId
                // Student Token
                const snapshot = await admin.database()
                    .ref(`/appointments/${appointmentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                //Prof FName
                const snapshot2 = await admin.database()
                    .ref(`/appointments/${appointmentId}/professorName`)
                    .once('value');
                const profName = snapshot2.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Appointment Status',
                        body: `Your appointment has been canceled.`,
                    },
                };

                // Send the message
                admin.messaging().send(message)
                    .then((response) => {
                        // Handle the response
                        console.log('Successfully sent notification 2:', response);
                    })
                    .catch((error) => {
                        // Handle the error
                        console.error('Error sending notification 2:', error);
                    });
            } catch (error) {
                console.error('Error sending push notification 2:', error);
            }

            //approved to cancel
        } else if (previousStatus === 'UPCOMING' && newStatus === 'CANCELED') {
            const appointmentId = context.params.appointmentId;
            try {
                // Get the device token or user ID associated with the appointmentId
                // Student Token
                const snapshot = await admin.database()
                    .ref(`/appointments/${appointmentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                //Prof FName
                const snapshot2 = await admin.database()
                    .ref(`/appointments/${appointmentId}/professorName`)
                    .once('value');
                const profName = snapshot2.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Appointment Status',
                        body: `Your appointment has been canceled.`,
                    },
                };

                // Send the message
                admin.messaging().send(message)
                    .then((response) => {
                        // Handle the response
                        console.log('Successfully sent notification 3:', response);
                    })
                    .catch((error) => {
                        // Handle the error
                        console.error('Error sending notification 3:', error);
                    });
            } catch (error) {
                console.error('Error sending push notification 3:', error);
            }
        }
    });

exports.onReschedulesChangeFunction = functions
    .region('asia-southeast1')
    .database.ref('/appointments/{appointmentId}/countered')
    .onUpdate(async (change, context) => {
        const newStatus = change.after.val();
        const previousStatus = change.before.val();

        if (previousStatus === 'no' && newStatus === 'yes') {
            const appointmentId = context.params.appointmentId;

            try {
                // Get the device token or user ID associated with the appointmentId
                // Student Token
                const snapshot = await admin.database()
                    .ref(`/appointments/${appointmentId}/fcmToken`)
                    .once('value');
                const deviceToken = snapshot.val();

                //Prof FName
                const snapshot2 = await admin.database()
                    .ref(`/appointments/${appointmentId}/professorName`)
                    .once('value');
                const profName = snapshot2.val();

                const message = {
                    token: deviceToken,
                    notification: {
                        title: 'Appointment Status',
                        body: `${profName} has requested an appointment reschedule.`,
                    },
                };

                // Send the message
                admin.messaging().send(message)
                    .then((response) => {
                        // Handle the response
                        console.log('Successfully sent notification 4:', response);
                    })
                    .catch((error) => {
                        // Handle the error
                        console.error('Error sending notification 4:', error);
                    });
            } catch (error) {
                console.error('Error sending push notification 4:', error);
            }
        }

    })



exports.onAppointmentFieldCreate = functions
    .region('asia-southeast1')
    .database.ref('/appointments/{appointmentId}')
    .onCreate(async (snapshot, context) => {
        // const appointmentId = context.params.appointmentId;
        const appointmentData = snapshot.val();

        if (appointmentData.hasOwnProperty('fcmProfToken')) {
            const { fcmProfToken, studentName } = appointmentData;

            try {
                const message = {
                    token: fcmProfToken,
                    notification: {
                        title: 'New Appointment',
                        body: `${studentName} has requested an appointment`,
                    },
                };

                // Send the message
                admin.messaging().send(message)
                    .then((response) => {
                        // Handle the response
                        console.log('Successfully sent notification 5:', response);
                    })
                    .catch((error) => {
                        // Handle the error
                        console.error('Error sending notification 5:', error);
                    });
            } catch (error) {
                console.error('Error sending push notification 5:', error);
            }

        }
    });


// Send notif if upcoming 

exports.sendAppointmentNotifications = functions
    .region('asia-southeast1')
    .https.onRequest(async (req, res) => {
        try {
            // Get the current time
            const currentTime = new Date();
            currentTime.setUTCHours(currentTime.getUTCHours() + 8); // Adjust to GMT+8 Manila time

            // Retrieve appointments that are upcoming within the next hour
            const appointmentsRef = admin.database().ref('/appointments');
            const snapshot = await appointmentsRef
                .orderByChild('requestStatus')
                .equalTo('UPCOMING')
                .once('value');

            const appointments = snapshot.val();

            // Iterate over the appointments and send notifications for upcoming ones
            const sendNotifications = [];
            Object.entries(appointments).forEach(async ([appointmentId, appointmentData]) => {
                const { fcmToken, fcmProfToken, professorName, studentName, date, time } = appointmentData;
                const scheduledDateTime = new Date(`${date} ${time}`);

                // Calculate the time difference in milliseconds
                const delay = scheduledDateTime.getTime() - currentTime.getTime() - (60 * 60 * 1000);

                // Check if the appointment is upcoming within the next hour
                if (delay <= 0 && delay > -3600000) {
                    try {
                        sendNotifications.push(

                            await admin.messaging().send({
                                token: fcmProfToken,
                                notification: {
                                    title: 'Upcoming Appointment',
                                    body: `Your appointment with ${studentName} is scheduled to happen on ${date} at ${time}.`,
                                },
                            }),
                            await admin.messaging().send({
                                token: fcmToken,
                                notification: {
                                    title: 'Upcoming Appointment',
                                    body: `Your appointment with ${professorName} is scheduled to happen on ${date} at ${time}.`,
                                },
                            }),
                        );
                    } catch (error) {
                        console.error('Error sending push notification 5:', error);
                    }
                }
            });

            // Wait for all the notifications to be sent
            await Promise.all(sendNotifications);

            res.status(200).send('Notifications sent successfully.');
        } catch (error) {
            console.error('Error sending notifications:', error);
            res.status(500).send('An error occurred while sending notifications.');
        }
    });

const { applicationDefault, getApps, initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { FieldValue, getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

const firebaseApp = getApps()[0] || initializeApp({
    credential: applicationDefault(),
});

module.exports = {
    auth: getAuth(firebaseApp),
    firestore: getFirestore(firebaseApp),
    messaging: getMessaging(firebaseApp),
    FieldValue,
};

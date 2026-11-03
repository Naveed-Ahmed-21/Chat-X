const {
    applicationDefault,
    cert,
    getApps,
    initializeApp,
} = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { FieldValue, getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

function getCredential() {
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (!serviceAccountJson) return applicationDefault();

    try {
        return cert(JSON.parse(serviceAccountJson));
    } catch (error) {
        throw new Error(
            `FIREBASE_SERVICE_ACCOUNT_JSON must be valid JSON: ${error.message}`,
        );
    }
}

const firebaseApp = getApps()[0] || initializeApp({
    credential: getCredential(),
});

module.exports = {
    auth: getAuth(firebaseApp),
    firestore: getFirestore(firebaseApp),
    messaging: getMessaging(firebaseApp),
    FieldValue,
};

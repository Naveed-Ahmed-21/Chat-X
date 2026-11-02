const express = require("express");
const router = express.Router();
const { FieldValue, firestore, messaging } = require("../config/firebaseAdmin");
const { requireFirebaseUser } = require("../middleWare/auth");

router.post("/send", requireFirebaseUser, async (req, res) => {
    try {
        const senderUid = req.firebaseUser.uid;
        const roomId = typeof req.body.roomId === "string" ? req.body.roomId.trim() : "";
        const body = typeof req.body.body === "string" ? req.body.body.trim() : "";

        if (!roomId || !body) {
            return res.status(400).json({ message: "roomId and body are required" });
        }

        const roomSnapshot = await firestore.collection("chats").doc(roomId).get();
        if (!roomSnapshot.exists) {
            return res.status(404).json({ message: "Chat was not found" });
        }

        const room = roomSnapshot.data() || {};
        const participants = Array.isArray(room.participants) ? room.participants : [];
        if (!participants.includes(senderUid)) {
            return res.status(403).json({ message: "You are not a participant in this chat" });
        }

        const recipientUids = participants.filter((uid) => uid !== senderUid);
        if (recipientUids.length === 0) {
            return res.json({ success: true, sent: 0 });
        }

        const [senderSnapshot, ...recipientSnapshots] = await Promise.all([
            firestore.collection("users").doc(senderUid).get(),
            ...recipientUids.map((uid) => firestore.collection("users").doc(uid).get()),
        ]);
        const senderName = senderSnapshot.data()?.name || "Chat X user";
        const groupName = typeof room.groupName === "string" ? room.groupName.trim() : "";
        const title = groupName ? `${senderName} · ${groupName}` : senderName;

        const tokenOwners = [];
        for (let index = 0; index < recipientSnapshots.length; index += 1) {
            const userData = recipientSnapshots[index].data() || {};
            const tokens = new Set([
                ...(Array.isArray(userData.fcmTokens) ? userData.fcmTokens : []),
                ...(typeof userData.fcmToken === "string" ? [userData.fcmToken] : []),
            ].filter((token) => typeof token === "string" && token.length > 0));
            for (const token of tokens) {
                tokenOwners.push({ token, uid: recipientUids[index] });
            }
        }

        if (tokenOwners.length === 0) {
            return res.json({ success: true, sent: 0 });
        }

        const response = await messaging.sendEachForMulticast({
            tokens: tokenOwners.slice(0, 500).map(({ token }) => token),
            notification: {
                title: title.slice(0, 100),
                body: body.slice(0, 500),
            },
            data: {
                kind: "chat_message",
                roomId,
                senderId: senderUid,
                senderName: String(senderName).slice(0, 100),
            },
            android: {
                priority: "high",
                notification: {
                    channelId: "chatx_notifications",
                    icon: "ic_chatx_notification",
                    priority: "high",
                    defaultSound: true,
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: "default",
                    },
                },
            },
        });

        const staleTokensByUid = new Map();
        response.responses.forEach((result, index) => {
            if (!result.success && [
                "messaging/registration-token-not-registered",
                "messaging/invalid-registration-token",
            ].includes(result.error?.code)) {
                const { token, uid } = tokenOwners[index];
                if (!staleTokensByUid.has(uid)) staleTokensByUid.set(uid, []);
                staleTokensByUid.get(uid).push(token);
            }
        });

        await Promise.all([...staleTokensByUid.entries()].map(([uid, tokens]) =>
            firestore.collection("users").doc(uid).update({
                fcmTokens: FieldValue.arrayRemove(...tokens),
                ...(tokens.includes((recipientSnapshots[recipientUids.indexOf(uid)].data() || {}).fcmToken)
                    ? { fcmToken: FieldValue.delete() }
                    : {}),
            }).catch(() => undefined)
        ));

        return res.json({ success: true, sent: response.successCount });
    } catch (error) {
        console.error("Could not send the chat notification:", error.code || error.message);
        return res.status(500).json({ message: "Could not send notification" });
    }
});

module.exports = router;

const { auth } = require("../config/firebaseAdmin");

async function requireFirebaseUser(req, res, next) {
    const authorization = req.get("authorization") || "";
    const match = authorization.match(/^Bearer\s+(.+)$/i);
    if (!match) {
        return res.status(401).json({ message: "Firebase bearer token is required" });
    }

    try {
        req.firebaseUser = await auth.verifyIdToken(match[1]);
        return next();
    } catch (error) {
        return res.status(401).json({ message: "Firebase bearer token is invalid" });
    }
}

module.exports = { requireFirebaseUser };

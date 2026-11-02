const express = require("express");
const router = express.Router();

const { upload, cleanupTemporaryUpload } = require("../middleWare/upload");
const { requireFirebaseUser } = require("../middleWare/auth");

const {
  uploadImage,
  uploadChatImage,
  uploadVideo,
  uploadAudio,
  uploadFile,
} = require("../controller/upload.controller");

router.post(
  "/profile",
  requireFirebaseUser,
  upload.single("image"),
  cleanupTemporaryUpload,
  uploadImage
);

router.post(
  "/chat",
  requireFirebaseUser,
  upload.single("image"),
  cleanupTemporaryUpload,
  uploadChatImage
);

router.post(
    "/video",
    requireFirebaseUser,
    upload.single("video"),
    cleanupTemporaryUpload,
    uploadVideo
);

router.post(
    "/audio",
    requireFirebaseUser,
    upload.single("audio"),
    cleanupTemporaryUpload,
    uploadAudio
);

router.post(
  "/file",
  requireFirebaseUser,
  upload.single("file"),
  cleanupTemporaryUpload,
  uploadFile
);


module.exports = router;

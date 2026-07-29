const express = require("express");
const router = express.Router();

const upload = require("../middleWare/upload");

const {
  uploadImage,
  uploadChatImage,
  uploadVideo,
} = require("../controller/upload.controller");

router.post(
  "/profile",
  upload.single("image"),
  uploadImage
);

router.post(
  "/chat",
  upload.single("image"),
  uploadChatImage
);

router.post(
    "/video",
    upload.single("video"),
    uploadVideo
);

module.exports = router;
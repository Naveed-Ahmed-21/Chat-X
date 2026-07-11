const express = require("express");

const router = express.Router();

const upload = require("../middleWare/upload");

const { uploadImage } = require("../controller/upload.controller");

router.post(
    "/profile",
    upload.single("image"),
    uploadImage
);


module.exports = router;
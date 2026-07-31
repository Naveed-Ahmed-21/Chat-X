const cloudinary = require("../config/cloudinary");

const uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No image selected",
      });
    }

    const uid = req.body.uid;

    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "ChatX/ProfileImages",
      public_id: uid,
      overwrite: true,
      invalidate: true,
    });

    return res.json({
      success: true,
      imageUrl: result.secure_url,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const uploadChatImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No image selected",
      });
    }

    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "ChatX/ChatImages",
    });

    return res.json({
      success: true,
      imageUrl: result.secure_url,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const uploadVideo = async (req, res) => {
  try {

       console.log("VIDEO API HIT");

         console.log(req.file);

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No video selected",
      });
    }

    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "ChatX/Videos",
      resource_type: "video",
    });

    console.log(result);

    return res.json({
      success: true,
      videoUrl: result.secure_url,
      duration: result.duration ?? 0,
    });
  } catch (e) {
      console.error(e);

    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};

const uploadAudio = async (req, res) => {
  try {

    console.log("AUDIO API HIT");

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No audio selected",
      });
    }

    const uid = req.body.uid;

    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "ChatX/Audio",
      resource_type: "video",
      public_id: `${uid}_${Date.now()}`,
    });

    return res.json({
      success: true,
      audioUrl: result.secure_url,
    });

  } catch (e) {

    console.log(e);

    return res.status(500).json({
      success: false,
      message: e.message,
    });

  }
};

const path = require("path");

const uploadFile = async (req, res) => {
  try {
    console.log("FILE API HIT");

    if (!req.file) {
      console.log("No file in request");
      return res.status(400).json({
        success: false,
        message: "No file selected",
      });
    }

    const uid = req.body.uid || "anonymous";
    console.log("UID from body:", uid);
    console.log("File path:", req.file.path);

    // Using resource_type: "auto" is often safer as Cloudinary will detect it
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "ChatX/Files",
      resource_type: "auto",
    });

    console.log("Cloudinary upload successful:", result.secure_url);

    return res.json({
      success: true,
      fileUrl: result.secure_url,
      fileName: req.file.originalname,
      size: req.file.size,
      extension: path.extname(req.file.originalname),
    });

  } catch (e) {
    console.error("FILE UPLOAD ERROR:", e);
    return res.status(500).json({
      success: false,
      message: "Internal server error during file upload: " + e.message,
    });
  }
};

module.exports = {
  uploadImage,
  uploadChatImage,
  uploadVideo,
  uploadAudio,
  uploadFile
};

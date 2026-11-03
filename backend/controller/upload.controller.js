const cloudinary = require("../config/cloudinary");

const uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No image selected",
      });
    }

    const uid = req.firebaseUser.uid;

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
    console.error("Profile image upload failed:", error.code || error.message);

    res.status(500).json({
      success: false,
      message: "Profile image upload failed",
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
    console.error("Chat image upload failed:", error.code || error.message);

    res.status(500).json({
      success: false,
      message: "Chat image upload failed",
    });
  }
};

const uploadVideo = async (req, res) => {
  try {

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

    return res.json({
      success: true,
      videoUrl: result.secure_url,
      duration: result.duration ?? 0,
    });
  } catch (e) {
      console.error("Video upload failed:", e.code || e.message);

    return res.status(500).json({
      success: false,
      message: "Video upload failed",
    });
  }
};

const uploadAudio = async (req, res) => {
  try {

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No audio selected",
      });
    }

    const uid = req.firebaseUser.uid;

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

    console.error("Audio upload failed:", e.code || e.message);

    return res.status(500).json({
      success: false,
      message: "Audio upload failed",
    });

  }
};

const path = require("path");

const uploadFile = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No file selected",
      });
    }

    // Using resource_type: "auto" is often safer as Cloudinary will detect it
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "ChatX/Files",
      resource_type: "auto",
    });

    return res.json({
      success: true,
      fileUrl: result.secure_url,
      fileName: req.file.originalname,
      size: req.file.size,
      extension: path.extname(req.file.originalname),
    });

  } catch (e) {
    console.error("File upload failed:", e.code || e.message);
    return res.status(500).json({
      success: false,
      message: "File upload failed",
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

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

module.exports = {
  uploadImage,
  uploadChatImage,
  uploadVideo,
};

const cloudinary = require("../config/cloudinary");

console.log("Flutter reached upload API");



const uploadImage = async(req , res) => {
    try {

        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "No image selected"
            });
        }

        console.log(req.file);

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

        console.log(result);
        console.log("UID:", req.body.uid);

    } catch (error) {

        console.error(error);

        res.status(500).json({ 
            success: false,
            message: error.message || "Internal Server Error"
         });
    }
};

module.exports = { uploadImage };
const multer = require("multer");
const { unlink } = require("node:fs/promises");

const storage = multer.diskStorage({});

const upload = multer({
  storage,
  limits: {
    fileSize: 100 * 1024 * 1024,
    files: 1,
  },
});

function cleanupTemporaryUpload(req, res, next) {
  res.once("finish", () => {
    if (req.file?.path) {
      unlink(req.file.path).catch((error) => {
        if (error.code !== "ENOENT") {
          console.error("Could not clean up a temporary upload:", error.code);
        }
      });
    }
  });
  next();
}

module.exports = { upload, cleanupTemporaryUpload };

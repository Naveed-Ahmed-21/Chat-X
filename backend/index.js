require("dotenv").config();

const express = require("express");

const app = express();

app.use(express.json());

const uploadRoute = require("./routers/upload.router");
app.use("/api/upload", uploadRoute);

const PORT = process.env.PORT || 5000;

process.env.CLOUDINARY_CLOUD_NAME;

console.log(process.env.CLOUDINARY_CLOUD_NAME);

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
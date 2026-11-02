require("dotenv").config();

const { createApp } = require("./app");

const requiredCloudinaryVariables = [
  "CLOUDINARY_CLOUD_NAME",
  "CLOUDINARY_API_KEY",
  "CLOUDINARY_API_SECRET",
];
const missingVariables = requiredCloudinaryVariables.filter(
  (name) => !process.env[name],
);

if (missingVariables.length > 0) {
  throw new Error(
    `Missing required environment variables: ${missingVariables.join(", ")}`,
  );
}

const port = Number.parseInt(process.env.PORT || "5000", 10);
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error("PORT must be a valid TCP port");
}

const app = createApp();
const server = app.listen(port, "0.0.0.0", () => {
  console.info(`ChatX backend listening on port ${port}`);
});

function shutdown(signal) {
  server.close((error) => {
    if (error) {
      console.error(`Backend shutdown failed after ${signal}.`);
      process.exitCode = 1;
      return;
    }
    process.exitCode = 0;
  });
}

process.once("SIGINT", () => shutdown("SIGINT"));
process.once("SIGTERM", () => shutdown("SIGTERM"));

module.exports = { app, server };

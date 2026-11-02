const express = require("express");

const uploadRoute = require("./routers/upload.router");
const notificationRoute = require("./routers/notification.router");

function createApp() {
  const app = express();

  app.disable("x-powered-by");
  app.use(express.json({ limit: "1mb" }));

  app.get("/health", (_req, res) => {
    res.status(200).json({ status: "ok" });
  });

  app.use("/api/upload", uploadRoute);
  app.use("/api/notifications", notificationRoute);

  app.use((error, _req, res, _next) => {
    if (res.headersSent) return;
    const status = error?.code === "LIMIT_FILE_SIZE" ? 413 : 500;
    res.status(status).json({
      message: status === 413 ? "Uploaded file exceeds the size limit" : "Request failed",
    });
  });

  return app;
}

module.exports = { createApp };

const { after, before, describe, it } = require("node:test");
const assert = require("node:assert/strict");
const { createApp } = require("../app");

describe("ChatX backend HTTP security and health", () => {
  let server;
  let baseUrl;

  before(async () => {
    server = createApp().listen(0, "127.0.0.1");
    await new Promise((resolve, reject) => {
      server.once("listening", resolve);
      server.once("error", reject);
    });
    const address = server.address();
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  after(async () => {
    if (!server) return;
    await new Promise((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  });

  it("returns a healthy response without exposing the Express header", async () => {
    const response = await fetch(`${baseUrl}/health`);
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { status: "ok" });
    assert.equal(response.headers.get("x-powered-by"), null);
  });

  it("rejects unauthenticated uploads before accepting file data", async () => {
    const response = await fetch(`${baseUrl}/api/upload/chat`, {
      method: "POST",
    });
    assert.equal(response.status, 401);
  });

  it("rejects unauthenticated notification requests", async () => {
    const response = await fetch(`${baseUrl}/api/notifications/send`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ roomId: "room", body: "hello" }),
    });
    assert.equal(response.status, 401);
  });
});

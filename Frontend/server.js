const express = require("express");
const path = require("path");
const http = require("http");
const querystring = require("querystring");

const app = express();

app.use(express.urlencoded({ extended: true }));

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.get("/", (req, res) => {
  res.render("form", { response: null });
});

app.post("/submit", (req, res) => {
  const postData = querystring.stringify({
    name: req.body.name,
    email: req.body.email,
  });

  const options = {
    hostname: process.env.BACKEND_HOST,
    port: 5000,
    path: "/submit",
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Content-Length": Buffer.byteLength(postData),
    },
  };

  const backendReq = http.request(options, (backendRes) => {
    let data = "";

    backendRes.on("data", (chunk) => {
      data += chunk;
    });

    backendRes.on("end", () => {
      const parsed = JSON.parse(data);
      res.render("form", { response: parsed });
    });
  });

  backendReq.on("error", () => {
    res.render("form", { response: { message: "Backend unreachable" } });
  });

  backendReq.write(postData);
  backendReq.end();
});

app.listen(3000, "0.0.0.0", () => {
  console.log("Frontend running on port 3000");
});

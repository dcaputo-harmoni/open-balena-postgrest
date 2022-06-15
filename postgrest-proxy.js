const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const jwt = require('njwt');

require('dotenv').config()

const app = express();

app.use(cors());

app.use('/', createProxyMiddleware({
  target: `http://127.0.0.1:3000`,
  onProxyReq: async (proxyReq, req, res) => {
    try {
      jwt.verify(req.headers.authorization.split("Bearer ")[1], process.env.PGRST_JWT_SECRET);
      const token = jwt.create({role: "docker"}, process.env.PGRST_JWT_SECRET).compact();
      proxyReq.setHeader("Authorization", `Bearer ${token}`);
    } catch (e) {
      proxyReq.destroy();
  }
  },
  changeOrigin: true,
}));

app.listen(8000);
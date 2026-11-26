import express from "express";
import authRoutes from "./routes/auth/auth.routes";
import adminRoutes from "./routes/admin.routes";

const app = express();
const PORT = 5000;

app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);

app.get("/", (req, res) => {
  res.send("hello Express + Typescript");
});

app.listen(PORT, () => {
  console.log(`server running on http://localhost:${PORT}`);
});
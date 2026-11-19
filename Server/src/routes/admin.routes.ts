import { Router } from "express";
import { authenticate, requireAdmin } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticate, requireAdmin, (_req, res) => {
    res.status(200).json({ message: "Admin access granted" });
});

export default router;

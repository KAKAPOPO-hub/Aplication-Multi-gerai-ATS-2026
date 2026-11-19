import { Request, Response } from "express";
import { eq } from "drizzle-orm";
import { db } from "../config/db";
import { menuTable } from "../config/schema";

export class MenuController {
    getAll = async (_req: Request, res: Response) => {
        try {
            const menu = await db.select().from(menuTable);

            return res.status(200).json({
                success: true,
                data: menu,
            });
        } catch (error) {
            console.error(error);

            return res.status(500).json({
                success: false,
                message: "Internal server error",
            });
        }
    }

    getById = async (req: Request, res: Response) => {
        const id = Number(req.params.id);
        if (!Number.isInteger(id) || id <= 0) {
            return res.status(400).json({
                success: false,
                message: "Invalid menu ID",
            });
        }

        try {
            const [menu] = await db
                .select()
                .from(menuTable)
                .where(eq(menuTable.id, id))
                .limit(1);

            if (!menu) {
                return res.status(404).json({
                    success: false,
                    message: "Menu not found",
                });
            }

            return res.status(200).json({
                success: true,
                data: menu,
            });
        } catch (error) {
            console.error(error);

            return res.status(500).json({
                success: false,
                message: "Internal server error",
            });
        }
    };
}

export default new MenuController();
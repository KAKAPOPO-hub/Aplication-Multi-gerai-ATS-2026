import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import { eq } from "drizzle-orm";
import { registerSchema, loginSchema } from "../validations/auth.validations";
import { db } from "../config/db";
import { usersTable } from "../config/schema";
import jwt from "jsonwebtoken";
    


    export class AuthController {

    register = async (req: Request, res: Response) => {
            try {
                const validatedData = registerSchema.parse(req.body);

                const { username, email, password } = validatedData;

                const existingEmail = await db.query.usersTable.findFirst({
                    where: eq(usersTable.email, email),
                });

                if (existingEmail) {
                    return res.status(409).json({
                        success: false,
                        message: "Email already exists",
                    });
                }

                const hashedPassword = await bcrypt.hash(password, 10);

                const [newUser] = await db
                    .insert(usersTable)
                    .values({
                        username,
                        email,
                        password: hashedPassword,
                    })
                    .returning({
                        id: usersTable.id,
                        username: usersTable.username,
                        email: usersTable.email,
                        role: usersTable.role,
                    });

                return res.status(201).json({
                    success: true,
                    message: "Register successful",
                    data: {
                        user: newUser,
                    },
                });

            } catch (error) {
                console.error(error);

                return res.status(500).json({
                    success: false,
                    message: "Internal server error",
                });
            }
        };

     login = async (req: Request, res: Response) => {
        try {
            // 1. VALIDATION
            const validatedData = loginSchema.parse(req.body);
            const { email, password } = validatedData;

            // 2. FIND USER BY EMAIL
            const user = await db.query.usersTable.findFirst({
                where: eq(usersTable.email, email),
            });

            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: "Email or password incorrect",
                });
            }

            // 3. CHECK PASSWORD
            const isPasswordValid = await bcrypt.compare(
                password,
                user.password
            );

            if (!isPasswordValid) {
                return res.status(401).json({
                    success: false,
                    message: "Email or password incorrect",
                });
            }


            const token = jwt.sign(
                {
                    id: user.id,
                    username: user.username,
                    email: user.email,
                    role: user.role
                },
                process.env.JWT_SECRET as string,
                {
                    expiresIn: "7d",
                }
            );

            return res.status(200).json({
                success: true,
                message: "Login successful",
                data: {
                    token,
                    user: {
                        id: user.id,
                        username: user.username,
                        email: user.email,
                        role: user.role,
                    },
                },
            });

        } catch (error) {
            console.error(error);

            return res.status(500).json({
                success: false,
                message: "Internal server error",
            });
        }
    }
    }

    

    export default new AuthController();
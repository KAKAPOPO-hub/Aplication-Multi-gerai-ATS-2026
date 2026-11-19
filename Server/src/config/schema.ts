import { sql } from "drizzle-orm";
import {
  boolean,
  check,
  integer,
  numeric,
  pgEnum,
  pgTable,
  serial,
  text,
  timestamp,
  varchar,
} from "drizzle-orm/pg-core";


export const USER_ROLES = [ "user", "admin", ] as const;


export const POST_STATUS = [ "delete", "published", ] as const;

export const userRoleEnum = pgEnum("user_role", USER_ROLES);


// USERS
export const usersTable = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  password: varchar("password", { length: 255 }).notNull(),
  role: userRoleEnum("role").notNull().default("user"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().$onUpdateFn(() => new Date()),
});


//Admin
export const AdminTable = pgTable("Admin", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  password: varchar("password", { length: 255 }).notNull(),
  role: userRoleEnum("role").notNull().default("user"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().$onUpdateFn(() => new Date()),
});

export const menuTable = pgTable(
  "menu",
  {
    id: serial("id").primaryKey(),
    categoryId: integer("category_id"),
    name: varchar("name", { length: 150 }).notNull(),
    description: text("description"),
    price: numeric("price", { precision: 12, scale: 2 }).notNull(),
    imageUrl: text("image_url"),
    stock: integer("stock").default(0),
    isAvailable: boolean("is_available").default(true),
    createdAt: timestamp("created_at").defaultNow(),
  },
  (table) => [
    check("menu_price_check", sql`${table.price} >= 0`),
    check("menu_stock_check", sql`${table.stock} >= 0`),
  ],
);


// src/db/schema.ts

import {
  pgTable,
  pgEnum,
  serial,
  integer,
  varchar,
  text,
  numeric,
  boolean,
  timestamp,
  unique,
} from "drizzle-orm/pg-core";

import { relations } from "drizzle-orm";

// ==================================================
// ENUMS
// ==================================================

export const userRoleEnum = pgEnum("user_role", [
  "user",
  "owner",
  "admin",
]);

export const propertyStatusEnum = pgEnum("property_status", [
  "active",
  "inactive",
]);

export const roomStatusEnum = pgEnum("room_status", [
  "available",
  "occupied",
  "maintenance",
]);

export const applicationStatusEnum = pgEnum("application_status", [
  "pending",
  "approved",
  "rejected",
  "cancelled",
]);

export const tenancyStatusEnum = pgEnum("tenancy_status", [
  "active",
  "completed",
  "cancelled",
]);

export const billStatusEnum = pgEnum("bill_status", [
  "unpaid",
  "partially_paid",
  "paid",
  "overdue",
]);

export const paymentStatusEnum = pgEnum("payment_status", [
  "pending",
  "verified",
  "rejected",
]);

export const complaintStatusEnum = pgEnum("complaint_status", [
  "pending",
  "in_progress",
  "resolved",
  "rejected",
]);

// ==================================================
// USERS
// ==================================================

export const usersTable = pgTable("users", {
  id: serial("id").primaryKey(),

  username: varchar("username", { length: 50 })
    .notNull(),

  email: varchar("email", { length: 100 })
    .notNull()
    .unique(),

  password: varchar("password", { length: 255 })
    .notNull(),

  role: userRoleEnum("role")
    .notNull()
    .default("user"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),

  updatedAt: timestamp("updated_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// CATEGORIES
// ==================================================

export const categoriesTable = pgTable("categories", {
  id: serial("id").primaryKey(),

  name: varchar("name", { length: 100 })
    .notNull()
    .unique(),

  description: text("description"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// PROPERTIES
// ==================================================

export const propertiesTable = pgTable("properties", {
  id: serial("id").primaryKey(),

  ownerId: integer("owner_id")
    .notNull()
    .references(() => usersTable.id, { onDelete: "restrict" }),

  categoryId: integer("category_id")
    .references(() => categoriesTable.id, { onDelete: "set null" }),

  name: varchar("name", { length: 150 })
    .notNull(),

  description: text("description"),

  address: text("address")
    .notNull(),

  city: varchar("city", { length: 100 })
    .notNull(),

  priceFrom: numeric("price_from", {
    precision: 12,
    scale: 2,
  }),

  imageUrl: text("image_url"),

  status: propertyStatusEnum("status")
    .notNull()
    .default("active"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),

  updatedAt: timestamp("updated_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// ROOMS
// ==================================================

export const roomsTable = pgTable(
  "rooms",
  {
    id: serial("id").primaryKey(),

    propertyId: integer("property_id")
      .notNull()
      .references(() => propertiesTable.id, { onDelete: "cascade" }),

    roomNumber: varchar("room_number", { length: 50 })
      .notNull(),

    description: text("description"),

    price: numeric("price", {
      precision: 12,
      scale: 2,
    }).notNull(),

    status: roomStatusEnum("status")
      .notNull()
      .default("available"),

    imageUrl: text("image_url"),

    createdAt: timestamp("created_at")
      .defaultNow()
      .notNull(),
  },
  (table) => [
    unique("rooms_property_room_unique")
      .on(table.propertyId, table.roomNumber),
  ],
);

// ==================================================
// FACILITIES
// ==================================================

export const facilitiesTable = pgTable("facilities", {
  id: serial("id").primaryKey(),

  name: varchar("name", { length: 100 })
    .notNull()
    .unique(),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// PROPERTY FACILITIES
// Junction table: Properties <-> Facilities
// ==================================================

export const propertyFacilitiesTable = pgTable(
  "property_facilities",
  {
    id: serial("id").primaryKey(),

    propertyId: integer("property_id")
      .notNull()
      .references(() => propertiesTable.id, { onDelete: "cascade" }),

    facilityId: integer("facility_id")
      .notNull()
      .references(() => facilitiesTable.id, { onDelete: "cascade" }),
  },
  (table) => [
    unique("property_facility_unique")
      .on(table.propertyId, table.facilityId),
  ],
);

// ==================================================
// RENTAL APPLICATIONS
// ==================================================

export const rentalApplicationsTable = pgTable("rental_applications", {
  id: serial("id").primaryKey(),

  userId: integer("user_id")
    .notNull()
    .references(() => usersTable.id, { onDelete: "restrict" }),

  roomId: integer("room_id")
    .notNull()
    .references(() => roomsTable.id, { onDelete: "restrict" }),

  message: text("message"),

  status: applicationStatusEnum("status")
    .notNull()
    .default("pending"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),

  updatedAt: timestamp("updated_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// TENANCIES
// ==================================================

export const tenanciesTable = pgTable("tenancies", {
  id: serial("id").primaryKey(),

  applicationId: integer("application_id")
    .notNull()
    .unique()
    .references(() => rentalApplicationsTable.id, { onDelete: "restrict" }),

  userId: integer("user_id")
    .notNull()
    .references(() => usersTable.id, { onDelete: "restrict" }),

  roomId: integer("room_id")
    .notNull()
    .references(() => roomsTable.id, { onDelete: "restrict" }),

  startDate: timestamp("start_date")
    .notNull(),

  endDate: timestamp("end_date"),

  status: tenancyStatusEnum("status")
    .notNull()
    .default("active"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// BILLS
// ==================================================

export const billsTable = pgTable("bills", {
  id: serial("id").primaryKey(),

  tenancyId: integer("tenancy_id")
    .notNull()
    .references(() => tenanciesTable.id, { onDelete: "restrict" }),

  title: varchar("title", { length: 150 })
    .notNull(),

  description: text("description"),

  amount: numeric("amount", {
    precision: 12,
    scale: 2,
  }).notNull(),

  dueDate: timestamp("due_date")
    .notNull(),

  status: billStatusEnum("status")
    .notNull()
    .default("unpaid"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// PAYMENTS
// ==================================================

export const paymentsTable = pgTable("payments", {
  id: serial("id").primaryKey(),

  billId: integer("bill_id")
    .notNull()
    .references(() => billsTable.id, { onDelete: "restrict" }),

  amount: numeric("amount", {
    precision: 12,
    scale: 2,
  }).notNull(),

  paymentMethod: varchar("payment_method", { length: 50 }),

  proofUrl: text("proof_url"),

  status: paymentStatusEnum("status")
    .notNull()
    .default("pending"),

  paidAt: timestamp("paid_at"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// COMPLAINTS
// ==================================================

export const complaintsTable = pgTable("complaints", {
  id: serial("id").primaryKey(),

  tenancyId: integer("tenancy_id")
    .notNull()
    .references(() => tenanciesTable.id, { onDelete: "restrict" }),

  title: varchar("title", { length: 150 })
    .notNull(),

  description: text("description")
    .notNull(),

  imageUrl: text("image_url"),

  status: complaintStatusEnum("status")
    .notNull()
    .default("pending"),

  response: text("response"),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),

  updatedAt: timestamp("updated_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// NOTIFICATIONS
// ==================================================

export const notificationsTable = pgTable("notifications", {
  id: serial("id").primaryKey(),

  userId: integer("user_id")
    .notNull()
    .references(() => usersTable.id, { onDelete: "cascade" }),

  title: varchar("title", { length: 150 })
    .notNull(),

  message: text("message")
    .notNull(),

  isRead: boolean("is_read")
    .notNull()
    .default(false),

  createdAt: timestamp("created_at")
    .defaultNow()
    .notNull(),
});

// ==================================================
// RELATIONS
// ==================================================

export const usersRelations = relations(usersTable, ({ many }) => ({
  properties: many(propertiesTable),
  rentalApplications: many(rentalApplicationsTable),
  tenancies: many(tenanciesTable),
  notifications: many(notificationsTable),
}));

export const categoriesRelations = relations(categoriesTable, ({ many }) => ({
  properties: many(propertiesTable),
}));

export const propertiesRelations = relations(propertiesTable, ({ one, many }) => ({
  owner: one(usersTable, {
    fields: [propertiesTable.ownerId],
    references: [usersTable.id],
  }),

  category: one(categoriesTable, {
    fields: [propertiesTable.categoryId],
    references: [categoriesTable.id],
  }),

  rooms: many(roomsTable),
  propertyFacilities: many(propertyFacilitiesTable),
}));

export const roomsRelations = relations(roomsTable, ({ one, many }) => ({
  property: one(propertiesTable, {
    fields: [roomsTable.propertyId],
    references: [propertiesTable.id],
  }),

  rentalApplications: many(rentalApplicationsTable),
  tenancies: many(tenanciesTable),
}));

export const facilitiesRelations = relations(facilitiesTable, ({ many }) => ({
  propertyFacilities: many(propertyFacilitiesTable),
}));

export const propertyFacilitiesRelations = relations(
  propertyFacilitiesTable,
  ({ one }) => ({
    property: one(propertiesTable, {
      fields: [propertyFacilitiesTable.propertyId],
      references: [propertiesTable.id],
    }),

    facility: one(facilitiesTable, {
      fields: [propertyFacilitiesTable.facilityId],
      references: [facilitiesTable.id],
    }),
  }),
);

export const rentalApplicationsRelations = relations(
  rentalApplicationsTable,
  ({ one }) => ({
    user: one(usersTable, {
      fields: [rentalApplicationsTable.userId],
      references: [usersTable.id],
    }),

    room: one(roomsTable, {
      fields: [rentalApplicationsTable.roomId],
      references: [roomsTable.id],
    }),

    tenancy: one(tenanciesTable),
  }),
);

export const tenanciesRelations = relations(tenanciesTable, ({ one, many }) => ({
  application: one(rentalApplicationsTable, {
    fields: [tenanciesTable.applicationId],
    references: [rentalApplicationsTable.id],
  }),

  user: one(usersTable, {
    fields: [tenanciesTable.userId],
    references: [usersTable.id],
  }),

  room: one(roomsTable, {
    fields: [tenanciesTable.roomId],
    references: [roomsTable.id],
  }),

  bills: many(billsTable),
  complaints: many(complaintsTable),
}));

export const billsRelations = relations(billsTable, ({ one, many }) => ({
  tenancy: one(tenanciesTable, {
    fields: [billsTable.tenancyId],
    references: [tenanciesTable.id],
  }),

  payments: many(paymentsTable),
}));

export const paymentsRelations = relations(paymentsTable, ({ one }) => ({
  bill: one(billsTable, {
    fields: [paymentsTable.billId],
    references: [billsTable.id],
  }),
}));

export const complaintsRelations = relations(complaintsTable, ({ one }) => ({
  tenancy: one(tenanciesTable, {
    fields: [complaintsTable.tenancyId],
    references: [tenanciesTable.id],
  }),
}));

export const notificationsRelations = relations(
  notificationsTable,
  ({ one }) => ({
    user: one(usersTable, {
      fields: [notificationsTable.userId],
      references: [usersTable.id],
    }),
  }),
);

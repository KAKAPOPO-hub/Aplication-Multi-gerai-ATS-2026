
CREATE TYPE "public"."application_status" AS ENUM('pending', 'approved', 'rejected', 'cancelled');
--> statement-breakpoint
CREATE TYPE "public"."bill_status" AS ENUM('unpaid', 'partially_paid', 'paid', 'overdue');
--> statement-breakpoint
CREATE TYPE "public"."complaint_status" AS ENUM('pending', 'in_progress', 'resolved', 'rejected');
--> statement-breakpoint
CREATE TYPE "public"."payment_status" AS ENUM('pending', 'verified', 'rejected');
--> statement-breakpoint
CREATE TYPE "public"."property_status" AS ENUM('active', 'inactive');
--> statement-breakpoint
CREATE TYPE "public"."room_status" AS ENUM('available', 'occupied', 'maintenance');
--> statement-breakpoint
CREATE TYPE "public"."tenancy_status" AS ENUM('active', 'completed', 'cancelled');
--> statement-breakpoint

ALTER TYPE "public"."user_role" ADD VALUE 'owner' BEFORE 'admin';
--> statement-breakpoint

-- Hapus tabel restoran lama
DROP TABLE IF EXISTS "menu" CASCADE;
--> statement-breakpoint
DROP TABLE IF EXISTS "categories" CASCADE;
--> statement-breakpoint

-- Membuat tabel KosD
CREATE TABLE "bills" (
    "id" serial PRIMARY KEY NOT NULL,
    "tenancy_id" integer NOT NULL,
    "title" varchar(150) NOT NULL,
    "description" text,
    "amount" numeric(12, 2) NOT NULL,
    "due_date" timestamp NOT NULL,
    "status" "bill_status" DEFAULT 'unpaid' NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint

CREATE TABLE "categories" (
    "id" serial PRIMARY KEY NOT NULL,
    "name" varchar(100) NOT NULL,
    "description" text,
    "created_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "categories_name_unique" UNIQUE("name")
);
--> statement-breakpoint

CREATE TABLE "complaints" (
    "id" serial PRIMARY KEY NOT NULL,
    "tenancy_id" integer NOT NULL,
    "title" varchar(150) NOT NULL,
    "description" text NOT NULL,
    "image_url" text,
    "status" "complaint_status" DEFAULT 'pending' NOT NULL,
    "response" text,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint

CREATE TABLE "facilities" (
    "id" serial PRIMARY KEY NOT NULL,
    "name" varchar(100) NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "facilities_name_unique" UNIQUE("name")
);
--> statement-breakpoint

CREATE TABLE "notifications" (
    "id" serial PRIMARY KEY NOT NULL,
    "user_id" integer NOT NULL,
    "title" varchar(150) NOT NULL,
    "message" text NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint

CREATE TABLE "payments" (
    "id" serial PRIMARY KEY NOT NULL,
    "bill_id" integer NOT NULL,
    "amount" numeric(12, 2) NOT NULL,
    "payment_method" varchar(50),
    "proof_url" text,
    "status" "payment_status" DEFAULT 'pending' NOT NULL,
    "paid_at" timestamp,
    "created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint

CREATE TABLE "properties" (
    "id" serial PRIMARY KEY NOT NULL,
    "owner_id" integer NOT NULL,
    "category_id" integer,
    "name" varchar(150) NOT NULL,
    "description" text,
    "address" text NOT NULL,
    "city" varchar(100) NOT NULL,
    "price_from" numeric(12, 2),
    "image_url" text,
    "status" "property_status" DEFAULT 'active' NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint

CREATE TABLE "property_facilities" (
    "id" serial PRIMARY KEY NOT NULL,
    "property_id" integer NOT NULL,
    "facility_id" integer NOT NULL,
    CONSTRAINT "property_facility_unique" UNIQUE("property_id", "facility_id")
);
--> statement-breakpoint

CREATE TABLE "rental_applications" (
    "id" serial PRIMARY KEY NOT NULL,
    "user_id" integer NOT NULL,
    "room_id" integer NOT NULL,
    "message" text,
    "status" "application_status" DEFAULT 'pending' NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint

CREATE TABLE "rooms" (
    "id" serial PRIMARY KEY NOT NULL,
    "property_id" integer NOT NULL,
    "room_number" varchar(50) NOT NULL,
    "description" text,
    "price" numeric(12, 2) NOT NULL,
    "status" "room_status" DEFAULT 'available' NOT NULL,
    "image_url" text,
    "created_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "rooms_property_room_unique" UNIQUE("property_id", "room_number")
);
--> statement-breakpoint

CREATE TABLE "tenancies" (
    "id" serial PRIMARY KEY NOT NULL,
    "application_id" integer NOT NULL,
    "user_id" integer NOT NULL,
    "room_id" integer NOT NULL,
    "start_date" timestamp NOT NULL,
    "end_date" timestamp,
    "status" "tenancy_status" DEFAULT 'active' NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "tenancies_application_id_unique" UNIQUE("application_id")
);
--> statement-breakpoint

-- Hapus tabel Admin lama
ALTER TABLE "Admin" DISABLE ROW LEVEL SECURITY;
--> statement-breakpoint
DROP TABLE "Admin" CASCADE;
--> statement-breakpoint

-- Pertahankan tabel users
ALTER TABLE "users" ALTER COLUMN "created_at" SET NOT NULL;
--> statement-breakpoint
ALTER TABLE "users" ALTER COLUMN "updated_at" SET NOT NULL;
--> statement-breakpoint

-- Relasi foreign key
ALTER TABLE "bills"
ADD CONSTRAINT "bills_tenancy_id_tenancies_id_fk"
FOREIGN KEY ("tenancy_id") REFERENCES "public"."tenancies"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "complaints"
ADD CONSTRAINT "complaints_tenancy_id_tenancies_id_fk"
FOREIGN KEY ("tenancy_id") REFERENCES "public"."tenancies"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "notifications"
ADD CONSTRAINT "notifications_user_id_users_id_fk"
FOREIGN KEY ("user_id") REFERENCES "public"."users"("id")
ON DELETE cascade ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "payments"
ADD CONSTRAINT "payments_bill_id_bills_id_fk"
FOREIGN KEY ("bill_id") REFERENCES "public"."bills"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "properties"
ADD CONSTRAINT "properties_owner_id_users_id_fk"
FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "properties"
ADD CONSTRAINT "properties_category_id_categories_id_fk"
FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id")
ON DELETE set null ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "property_facilities"
ADD CONSTRAINT "property_facilities_property_id_properties_id_fk"
FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id")
ON DELETE cascade ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "property_facilities"
ADD CONSTRAINT "property_facilities_facility_id_facilities_id_fk"
FOREIGN KEY ("facility_id") REFERENCES "public"."facilities"("id")
ON DELETE cascade ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "rental_applications"
ADD CONSTRAINT "rental_applications_user_id_users_id_fk"
FOREIGN KEY ("user_id") REFERENCES "public"."users"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "rental_applications"
ADD CONSTRAINT "rental_applications_room_id_rooms_id_fk"
FOREIGN KEY ("room_id") REFERENCES "public"."rooms"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "rooms"
ADD CONSTRAINT "rooms_property_id_properties_id_fk"
FOREIGN KEY ("property_id") REFERENCES "public"."properties"("id")
ON DELETE cascade ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "tenancies"
ADD CONSTRAINT "tenancies_application_id_rental_applications_id_fk"
FOREIGN KEY ("application_id") REFERENCES "public"."rental_applications"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "tenancies"
ADD CONSTRAINT "tenancies_user_id_users_id_fk"
FOREIGN KEY ("user_id") REFERENCES "public"."users"("id")
ON DELETE restrict ON UPDATE no action;
--> statement-breakpoint

ALTER TABLE "tenancies"
ADD CONSTRAINT "tenancies_room_id_rooms_id_fk"
FOREIGN KEY ("room_id") REFERENCES "public"."rooms"("id")
ON DELETE restrict ON UPDATE no action;

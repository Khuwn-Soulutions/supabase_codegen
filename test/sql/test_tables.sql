create type "public"."User_Role" as enum ('admin', 'user');

create table "public"."test_generate" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "is_nullable" text,
    "is_array" text[],
    "is_not_nullable" text not null
);


alter table "public"."test_generate" enable row level security;

create table "public"."users" (
    "email" character varying(255) not null,
    "acc_name" character varying(255),
    "phone_number" character varying(20),
    "contacts" text[],
    "role" User_Role not null,
    "created_at" timestamp with time zone default CURRENT_TIMESTAMP
);

alter table "public"."users" enable row level security;


CREATE UNIQUE INDEX test_generate_pkey ON public.test_generate USING btree (id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (email);

alter table "public"."test_generate" add constraint "test_generate_pkey" PRIMARY KEY using index "test_generate_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

grant delete on table "public"."test_generate" to "anon";

grant insert on table "public"."test_generate" to "anon";

grant references on table "public"."test_generate" to "anon";

grant select on table "public"."test_generate" to "anon";

grant trigger on table "public"."test_generate" to "anon";

grant truncate on table "public"."test_generate" to "anon";

grant update on table "public"."test_generate" to "anon";

grant delete on table "public"."test_generate" to "authenticated";

grant insert on table "public"."test_generate" to "authenticated";

grant references on table "public"."test_generate" to "authenticated";

grant select on table "public"."test_generate" to "authenticated";

grant trigger on table "public"."test_generate" to "authenticated";

grant truncate on table "public"."test_generate" to "authenticated";

grant update on table "public"."test_generate" to "authenticated";

grant delete on table "public"."test_generate" to "service_role";

grant insert on table "public"."test_generate" to "service_role";

grant references on table "public"."test_generate" to "service_role";

grant select on table "public"."test_generate" to "service_role";

grant trigger on table "public"."test_generate" to "service_role";

grant truncate on table "public"."test_generate" to "service_role";

grant update on table "public"."test_generate" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";



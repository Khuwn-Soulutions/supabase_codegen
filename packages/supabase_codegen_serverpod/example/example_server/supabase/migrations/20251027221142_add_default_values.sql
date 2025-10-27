-- Default values table
create table "public"."default_values" (
    "id" uuid not null default gen_random_uuid(),
    "default_date_time" timestamp with time zone not null default now(),
    "default_bool" boolean default true,
    "default_double" double precision default '10.5'::double precision,
    "default_int" bigint default '10'::bigint,
    "default_string" text default 'This is a string'::text
);


alter table "public"."default_values" enable row level security;

CREATE UNIQUE INDEX default_values_pkey ON public.default_values USING btree (id);

alter table "public"."default_values" add constraint "default_values_pkey" PRIMARY KEY using index "default_values_pkey";

grant delete on table "public"."default_values" to "anon";

grant insert on table "public"."default_values" to "anon";

grant references on table "public"."default_values" to "anon";

grant select on table "public"."default_values" to "anon";

grant trigger on table "public"."default_values" to "anon";

grant truncate on table "public"."default_values" to "anon";

grant update on table "public"."default_values" to "anon";

grant delete on table "public"."default_values" to "authenticated";

grant insert on table "public"."default_values" to "authenticated";

grant references on table "public"."default_values" to "authenticated";

grant select on table "public"."default_values" to "authenticated";

grant trigger on table "public"."default_values" to "authenticated";

grant truncate on table "public"."default_values" to "authenticated";

grant update on table "public"."default_values" to "authenticated";

grant delete on table "public"."default_values" to "service_role";

grant insert on table "public"."default_values" to "service_role";

grant references on table "public"."default_values" to "service_role";

grant select on table "public"."default_values" to "service_role";

grant trigger on table "public"."default_values" to "service_role";

grant truncate on table "public"."default_values" to "service_role";

grant update on table "public"."default_values" to "service_role";

-- # Add default to created_at for recipes table

alter table "public"."recipes" alter column "created_at" set default now();



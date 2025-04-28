alter table "public"."test_generate" add column "date_col" date default '2001-01-01'::date;

alter table "public"."test_generate" add column "is_string" text not null default 'N/A'::text;

alter table "public"."test_generate" add column "num_array" smallint[] default '{1,2}'::smallint[];

alter table "public"."test_generate" add column "timestamp" timestamp with time zone not null default '2001-01-01 00:00:00+00'::timestamp with time zone;

alter table "public"."test_generate" alter column "created_at" set default (now() AT TIME ZONE 'utc'::text);

alter table "public"."test_generate" alter column "is_array" set default '{a,b}'::text[];

alter table "public"."test_generate" alter column "is_bool" set default true;

alter table "public"."test_generate" alter column "is_double" set default '0.1'::real;

alter table "public"."test_generate" alter column "is_double" set data type real using "is_double"::real;

alter table "public"."test_generate" alter column "is_int" set default '1'::smallint;

alter table "public"."test_generate" alter column "is_json" set default '{"test": 1}'::jsonb;



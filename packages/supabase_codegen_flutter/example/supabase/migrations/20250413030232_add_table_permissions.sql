create policy "Enable insert access for all users"
on "public"."test_generate"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."test_generate"
as permissive
for select
to public
using (true);


create policy "Enable insert access for all users"
on "public"."users"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."users"
as permissive
for select
to public
using (true);




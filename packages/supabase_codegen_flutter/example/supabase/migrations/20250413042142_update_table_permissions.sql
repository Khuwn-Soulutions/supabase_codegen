create policy "Enable delete access for all users"
on "public"."users"
as permissive
for delete
to public
using (true);


create policy "Enable update access for all users"
on "public"."users"
as permissive
for update
to public
using (true)
with check (true);




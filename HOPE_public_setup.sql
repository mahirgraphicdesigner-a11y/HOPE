-- HOPE public/no-login mode. WARNING: anyone with the URL can read, upload and delete all content.
alter table public.hope_items alter column user_id drop not null;

do $$ declare p record; begin
 for p in select policyname from pg_policies where schemaname='public' and tablename='hope_items'
 loop execute format('drop policy if exists %I on public.hope_items',p.policyname); end loop;
end $$;
alter table public.hope_items enable row level security;
create policy hope_public_read on public.hope_items for select to anon, authenticated using (true);
create policy hope_public_insert on public.hope_items for insert to anon, authenticated with check (true);
create policy hope_public_delete on public.hope_items for delete to anon, authenticated using (true);
grant select, insert, delete on public.hope_items to anon, authenticated;

update storage.buckets set public=true where id='hope-files';
do $$ declare p record; begin
 for p in select policyname from pg_policies where schemaname='storage' and tablename='objects'
 and (coalesce(qual,'') ilike '%hope-files%' or coalesce(with_check,'') ilike '%hope-files%')
 loop execute format('drop policy if exists %I on storage.objects',p.policyname); end loop;
end $$;
create policy hope_files_public_read on storage.objects for select to anon, authenticated using (bucket_id='hope-files');
create policy hope_files_public_upload on storage.objects for insert to anon, authenticated with check (bucket_id='hope-files');
create policy hope_files_public_delete on storage.objects for delete to anon, authenticated using (bucket_id='hope-files');

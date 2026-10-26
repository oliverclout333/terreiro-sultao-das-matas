-- Execute no SQL Editor de um projeto NOVO do Supabase.
-- Depois de criar seu usuário em Authentication > Users,
-- substitua o UUID abaixo e execute a última linha de INSERT separadamente.
create extension if not exists pgcrypto;
create table if not exists public.administradores (user_id uuid primary key references auth.users(id) on delete cascade);
create table if not exists public.filhos (id uuid primary key default gen_random_uuid(),nome text not null check(length(nome)<=140),telefone text, data_entrada date,ativo boolean not null default true,created_at timestamptz default now());
create table if not exists public.mensalidades (id uuid primary key default gen_random_uuid(),filho_id uuid not null references public.filhos(id) on delete cascade,ano integer not null check(ano between 2000 and 2200),mes integer not null check(mes between 1 and 12),valor numeric(10,2) not null default 150,data_pagamento date not null default current_date,observacao text,created_at timestamptz default now(),unique(filho_id,ano,mes));
create table if not exists public.trabalhos (id uuid primary key default gen_random_uuid(),filho_id uuid not null references public.filhos(id) on delete cascade,titulo text not null,observacoes text,data_trabalho date,status text not null default 'pendente' check(status in ('pendente','concluido')),created_at timestamptz default now());
alter table public.administradores enable row level security;
alter table public.filhos enable row level security;
alter table public.mensalidades enable row level security;
alter table public.trabalhos enable row level security;
-- Não há acesso público; somente usuários com ID cadastrado em administradores.
create policy "leitura admins" on public.administradores for select to authenticated using (user_id=auth.uid());
create policy "filhos admins" on public.filhos for all to authenticated using (exists(select 1 from public.administradores where user_id=auth.uid())) with check (exists(select 1 from public.administradores where user_id=auth.uid()));
create policy "mensalidades admins" on public.mensalidades for all to authenticated using (exists(select 1 from public.administradores where user_id=auth.uid())) with check (exists(select 1 from public.administradores where user_id=auth.uid()));
create policy "trabalhos admins" on public.trabalhos for all to authenticated using (exists(select 1 from public.administradores where user_id=auth.uid())) with check (exists(select 1 from public.administradores where user_id=auth.uid()));
-- Em uma segunda execução, após criar usuário no Auth, rode:
-- insert into public.administradores (user_id) values ('COLE_AQUI_O_UUID_DO_USUARIO');

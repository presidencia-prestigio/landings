-- Tabla de respuestas de las landings públicas.
-- Ejecutar una sola vez en el SQL Editor del proyecto de Supabase (o como migración).
-- Modelo de seguridad:
--   * anon (el navegador del visitante, con la publishable key) solo puede INSERTAR
--     en cinco columnas: formulario, nombre, correo, telefono, respuestas.
--   * Nadie anónimo ni autenticado puede leer, actualizar ni borrar.
--   * Las respuestas se leen desde el panel de Supabase o con la secret key (service_role).

create table if not exists public.respuestas (
  id          uuid        primary key default gen_random_uuid(),
  creado_en   timestamptz not null    default now(),
  formulario  text        not null,
  nombre      text,
  correo      text,
  telefono    text,
  respuestas  jsonb       not null    default '{}'::jsonb,

  -- etiqueta de la landing: minúsculas, números y guiones (p. ej. "ensayo")
  constraint respuestas_formulario_formato check (formulario ~ '^[a-z0-9][a-z0-9-]{0,59}$'),
  constraint respuestas_nombre_largo       check (char_length(nombre)   <= 120),
  constraint respuestas_correo_largo       check (char_length(correo)   <= 254),
  constraint respuestas_telefono_largo     check (char_length(telefono) <= 40),
  constraint respuestas_respuestas_objeto  check (jsonb_typeof(respuestas) = 'object'),
  constraint respuestas_respuestas_tamano  check (octet_length(respuestas::text) <= 8000)
);

comment on table public.respuestas is 'Envíos de las landings públicas. Inserción anónima; lectura solo con service_role.';

-- Para filtrar por landing y fecha desde el panel.
create index if not exists respuestas_formulario_creado_idx
  on public.respuestas (formulario, creado_en desc);

-- RLS activa: sin una política que lo permita, nada pasa.
alter table public.respuestas enable row level security;

-- Privilegios: Supabase concede todo a anon y authenticated por defecto en tablas nuevas.
-- Se retira todo y se concede solo INSERT en las cinco columnas permitidas.
revoke all on table public.respuestas from anon, authenticated;
grant insert (formulario, nombre, correo, telefono, respuestas) on table public.respuestas to anon;

-- Política de inserción para anon. Repite los límites en el WITH CHECK para que la
-- política no sea "siempre verdadera" (aviso rls_policy_always_true del Security Advisor).
drop policy if exists "anon inserta respuestas" on public.respuestas;
create policy "anon inserta respuestas"
  on public.respuestas
  for insert
  to anon
  with check (
    formulario ~ '^[a-z0-9][a-z0-9-]{0,59}$'
    and coalesce(char_length(nombre), 0)   <= 120
    and coalesce(char_length(correo), 0)   <= 254
    and coalesce(char_length(telefono), 0) <= 40
    and jsonb_typeof(respuestas) = 'object'
    and octet_length(respuestas::text) <= 8000
  );

-- No se crean políticas SELECT / UPDATE / DELETE: con RLS activa quedan denegadas
-- para anon y authenticated. service_role omite RLS y es quien lee los datos.

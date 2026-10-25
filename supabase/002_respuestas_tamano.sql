-- Amplía el tamaño máximo de "respuestas" de 8 KB a 32 KB.
-- Necesario para formularios largos (por ejemplo, gm-r3). Ejecutar después de 001.

alter table public.respuestas drop constraint if exists respuestas_respuestas_tamano;
alter table public.respuestas
  add constraint respuestas_respuestas_tamano check (octet_length(respuestas::text) <= 32000);

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
    and octet_length(respuestas::text) <= 32000
  );

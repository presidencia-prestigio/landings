# Landings

Landings públicas con formulario, servidas con GitHub Pages. Cada landing es una carpeta con un solo `index.html`. Las respuestas se guardan en Supabase, en la tabla `public.respuestas`.

La raíz (`/`) no enlaza ninguna landing: cada una se comparte solo por su link directo, por ejemplo `https://<usuario>.github.io/landings/ensayo/`. Todas llevan `noindex` para que no aparezcan en buscadores.

## Estructura

| Ruta | Qué es |
|---|---|
| `index.html` | Portada neutra. No lista las landings. |
| `_plantilla/` | Plantilla base. **No acepta envíos** (`activo: false`). |
| `ensayo/` | Primera landing. Guarda con la etiqueta `formulario = "ensayo"`. |
| `supabase/001_respuestas.sql` | Tabla, permisos y política RLS. |
| `.nojekyll` | Evita que GitHub Pages oculte las carpetas que empiezan con `_`. |

## Crear una landing nueva

1. Copia `_plantilla/` a una carpeta nueva con un nombre corto en minúsculas, por ejemplo `taller-liderazgo/`. Ese nombre será parte del link.
2. En el `index.html` nuevo, edita el bloque `CONFIG` al inicio del script:
   - `formulario`: la etiqueta con que se guardarán las respuestas. Solo minúsculas, números y guiones (máximo 60). Puede ser igual al nombre de la carpeta.
   - `activo: true`
   - `supabaseUrl` y `publishableKey`: los del proyecto (Supabase → Project Settings → API Keys).
3. Cambia título, descripción y mensaje de gracias (buscando el texto de la plantilla), y quita el aviso "Plantilla · no acepta envíos".
4. Ajusta `PREGUNTAS`. Si la pregunta tiene `campo` (`nombre`, `correo` o `telefono`), se guarda en esa columna. Sin `campo`, se guarda dentro de `respuestas` (jsonb) con su `id`.
5. Sube el cambio a `main`. GitHub Pages lo publica en uno o dos minutos.

## Seguridad

- La `publishableKey` es pública por diseño. Lo que protege los datos son los permisos de la tabla:
  - El rol `anon` solo puede **insertar** en `formulario`, `nombre`, `correo`, `telefono` y `respuestas`.
  - Nadie anónimo puede leer, actualizar ni borrar. Tampoco puede fijar `id` ni `creado_en`.
  - La política RLS y las restricciones `CHECK` limitan el largo de cada campo y exigen que `respuestas` sea un objeto de máximo 8 KB.
- Nunca pongas la **secret key** (`sb_secret_...`) ni la `service_role` en una landing.
- Contra bots: un campo trampa oculto (honeypot) y un tiempo mínimo de 4 segundos. Si alguno se activa, la landing muestra "gracias" y no envía nada.

## Ver las respuestas

En Supabase → Table Editor → `respuestas`, o con SQL:

```sql
select creado_en, formulario, nombre, correo, telefono, respuestas
from public.respuestas
where formulario = 'ensayo'
order by creado_en desc;
```

## Comportamiento de la landing

- Una pregunta por pantalla, con barra de progreso y botón para volver.
- Enter avanza. En preguntas de texto largo, Ctrl + Enter o ⌘ + Enter.
- Si el JavaScript no corre (por ejemplo, en una vista previa), se ve el título y un aviso para abrir el link en el navegador.
- Respeta `prefers-reduced-motion`: sin animaciones si el sistema lo pide.
- Si el envío falla, muestra un aviso y conserva las respuestas para reintentar.

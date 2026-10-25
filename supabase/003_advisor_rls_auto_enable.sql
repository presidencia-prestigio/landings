-- Corrige 2 avisos del Security Advisor (ya aplicado en el proyecto "Landings").
-- public.rls_auto_enable() es la función del disparador de eventos ensure_rls y era
-- ejecutable por anon y authenticated. El disparador sigue funcionando: Postgres no
-- revisa EXECUTE al dispararlo.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

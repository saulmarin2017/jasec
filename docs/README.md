# Documentación del proyecto JASEC / SIAR

Carpeta para ir guardando documentación del proyecto: guías, notas de reuniones, decisiones técnicas, capturas de flujos, etc.

## Contenido

| Archivo / carpeta | Descripción |
|-------------------|-------------|
| [../Grok-Build-Workflow.md](../Grok-Build-Workflow.md) | **Flujo de trabajo Grok Build** (fuente de verdad; pendientes + ORDS al iniciar) |
| [../grok.md](../grok.md) | Referencia histórica / compatibilidad (redirige al workflow) |
| [pendientes/](pendientes/) | **Handover:** info importante, conexión ORDS, checklist de reunión y backlog |
| `guia_rapida_configuracion.docx` | Guía ORDS, tokens, HTTPS y compilación del APK (copia de referencia) |
| *(agregar aquí)* | Nuevos `.md`, `.docx`, `.pdf`, diagramas, etc. |

## Copia empaquetada en la app

La guía que usa la aplicación móvil está en:

`assets/docs/guia_rapida_configuracion.docx`

Si actualizás el Word, conviene mantener sincronizada la copia de `docs/` y la de `assets/docs/` (y registrar en `pubspec.yaml` si cambia el nombre del archivo).

## Convención de nombres

- Usar minúsculas y guiones: `notas-sincronizacion-2026.md`
- Fecha en el nombre si aplica: `reunion-2026-06-05.md`
- Prefijos opcionales: `guia-`, `nota-`, `decision-`, `fix-`

## Qué no guardar aquí

- Credenciales, contraseñas ni tokens en texto plano
- Archivos generados por build (`build/`)
- Bases de datos locales (`jasec2025.db`) salvo que sea una plantilla vacía acordada con el equipo
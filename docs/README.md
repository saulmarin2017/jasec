# Documentación del proyecto JASEC / SIAR

Documentación **compartible** del proyecto (repo / VM del cliente).

## Contenido en este repositorio

| Archivo / carpeta | Descripción |
|-------------------|-------------|
| `guia_rapida_configuracion.docx` | Guía ORDS, tokens, HTTPS y compilación del APK (referencia) |

## Copia empaquetada en la app

La guía que usa la aplicación móvil está en:

`assets/docs/guia_rapida_configuracion.docx`

Si se actualiza el Word, mantener sincronizadas la copia de `docs/` y la de `assets/docs/` (y `pubspec.yaml` si cambia el nombre).

## Qué no va en el repositorio (solo local Navasoft)

Estas carpetas/archivos están en **`.gitignore`** y **no** deben quedar en la VM del cliente al clonar:

- `Grok-Build-Workflow.md`, `grok.md` — flujo de trabajo con Grok Build  
- `docs/pendientes/` — análisis, handover, reuniones, planes, manuales de trabajo internos  
- Manuales VM de análisis (`docs/Manual_VM_JASEC_SIAR*.docx`)  
- Bases locales (`*.db`), secretos y keystores  

Eso se conserva en la máquina de desarrollo de Navasoft, no se publica en el remoto que use JASEC.

## Qué no guardar en docs versionados

- Credenciales, contraseñas ni tokens en texto plano  
- Archivos de build (`build/`)  
- Bases de datos locales con datos reales  

-- =========================
-- ODS.HD_PRESTAMOS_REFINANCIADOS
-- =========================

--BORRAR CAMPOS SOLICITUDES.
ALTER TABLE ODS.MD_SOLICITUDES DROP COLUMN NU_PLAZOS;
ALTER TABLE ODS.HD_SOLICITUDES DROP COLUMN NU_PLAZOS;


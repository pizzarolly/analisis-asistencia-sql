-- =========================================
-- PROYECTO: ANALISIS DE ASISTENCIA LABORAL
-- =========================================

-- 1. Jornadas activas sin marca de entrada
SELECT
    j.id_jornada,
    e.identificacion,
    j.fecha,
    j.hora_inicio_programada,
    ra.hora_entrada
FROM jornada j
LEFT JOIN registro_asistencia ra
    ON ra.jornada_id = j.id_jornada
JOIN empleado_detalle ed
    ON ed.id_detalle = j.empleado_detalle_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id
WHERE j.activo = 1
  AND ra.hora_entrada IS NULL;


-- 2. Jornadas activas sin marca de salida
SELECT
    j.id_jornada,
    e.identificacion,
    j.fecha,
    j.hora_fin_programada,
    ra.hora_salida
FROM jornada j
LEFT JOIN registro_asistencia ra
    ON ra.jornada_id = j.id_jornada
JOIN empleado_detalle ed
    ON ed.id_detalle = j.empleado_detalle_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id
WHERE j.activo = 1
  AND ra.hora_salida IS NULL;


-- 3. Atrasos
SELECT
    j.id_jornada,
    e.identificacion,
    j.fecha,
    j.hora_inicio_programada,
    ra.hora_entrada,
    TIMESTAMPDIFF(MINUTE, j.hora_inicio_programada, ra.hora_entrada) AS minutos_atraso
FROM jornada j
JOIN registro_asistencia ra
    ON ra.jornada_id = j.id_jornada
JOIN empleado_detalle ed
    ON ed.id_detalle = j.empleado_detalle_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id
WHERE j.activo = 1
  AND ra.hora_entrada > j.hora_inicio_programada;


-- 4. Horas extra
SELECT
    j.id_jornada,
    e.identificacion,
    j.fecha,
    j.hora_fin_programada,
    ra.hora_salida,
    TIMESTAMPDIFF(MINUTE, j.hora_fin_programada, ra.hora_salida) AS minutos_extra
FROM jornada j
JOIN registro_asistencia ra
    ON ra.jornada_id = j.id_jornada
JOIN empleado_detalle ed
    ON ed.id_detalle = j.empleado_detalle_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id
WHERE j.activo = 1
  AND ra.hora_salida > j.hora_fin_programada;


-- 5. Jornadas con contratos no vigentes
SELECT
    j.id_jornada,
    e.identificacion,
    j.fecha,
    cl.fecha_termino,
    cl.motivo_salida
FROM jornada j
JOIN contrato_laboral cl
    ON cl.id_contrato = j.contrato_id
JOIN empleado_detalle ed
    ON ed.id_detalle = j.empleado_detalle_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id
WHERE j.activo = 1
  AND (
      (cl.fecha_termino IS NOT NULL AND j.fecha > cl.fecha_termino)
      OR cl.motivo_salida IS NOT NULL
  );


-- 6. Inconsistencia de área
SELECT
    ed.id_detalle,
    e.identificacion,
    ed.area_id AS area_empleado,
    cl.area_id AS area_contrato
FROM empleado_detalle ed
JOIN contrato_laboral cl
    ON cl.id_contrato = ed.contrato_vigente_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id
WHERE ed.area_id <> cl.area_id;


-- 7. Estado general de jornada
SELECT
    j.id_jornada,
    e.identificacion,
    j.fecha,
    ra.hora_entrada,
    ra.hora_salida,
    CASE
        WHEN j.activo = 0 THEN 'Jornada inactiva'
        WHEN ra.jornada_id IS NULL THEN 'Sin registro'
        WHEN ra.hora_entrada IS NULL THEN 'Sin entrada'
        WHEN ra.hora_salida IS NULL THEN 'Sin salida'
        WHEN ra.hora_entrada > j.hora_inicio_programada THEN 'Atraso'
        WHEN ra.hora_salida < j.hora_fin_programada THEN 'Salida anticipada'
        WHEN ra.hora_salida > j.hora_fin_programada THEN 'Horas extra'
        ELSE 'Normal'
    END AS estado
FROM jornada j
LEFT JOIN registro_asistencia ra
    ON ra.jornada_id = j.id_jornada
JOIN empleado_detalle ed
    ON ed.id_detalle = j.empleado_detalle_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id;


-- 8. Métricas globales
SELECT
    COUNT(*) AS total_jornadas,
    SUM(CASE WHEN j.activo = 1 THEN 1 ELSE 0 END) AS activas,
    SUM(CASE WHEN ra.hora_entrada IS NULL THEN 1 ELSE 0 END) AS sin_entrada,
    SUM(CASE WHEN ra.hora_salida IS NULL THEN 1 ELSE 0 END) AS sin_salida,
    SUM(CASE WHEN ra.hora_entrada > j.hora_inicio_programada THEN 1 ELSE 0 END) AS atrasos,
    SUM(CASE WHEN ra.hora_salida > j.hora_fin_programada THEN 1 ELSE 0 END) AS horas_extra
FROM jornada j
LEFT JOIN registro_asistencia ra
    ON ra.jornada_id = j.id_jornada;

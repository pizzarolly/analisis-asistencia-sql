-- =========================================
-- PROYECTO: ANALISIS DE ASISTENCIA LABORAL
-- =========================================

-- 1. Jornadas activas sin marcas SELECT
    j.id_jornada,
    e.identificacion,
    CONCAT(
        e.nombre, ' ',
        IFNULL(e.segundo_nombre, ''), ' ',
        e.apellido_paterno, ' ',
        e.apellido_materno
    ) AS nombre_completo,
    j.fecha,
    j.hora_inicio_programada,
    j.hora_fin_programada,
    ra.hora_entrada,
    ra.hora_salida,

    CASE
        WHEN ra.jornada_id IS NULL THEN 'Sin registro de asistencia'
        WHEN ra.hora_entrada IS NULL AND ra.hora_salida IS NULL THEN 'Sin entrada y salida'
        WHEN ra.hora_entrada IS NULL THEN 'Sin entrada'
        WHEN ra.hora_salida IS NULL THEN 'Sin salida'
    END AS tipo_inconsistencia

FROM jornada j
JOIN empleado_detalle ed
    ON ed.id_detalle = j.empleado_detalle_id
JOIN empleado e
    ON e.id_empleado = ed.empleado_id
LEFT JOIN registro_asistencia ra
    ON ra.jornada_id = j.id_jornada

WHERE j.activo = 1
  AND (
        ra.jornada_id IS NULL
        OR ra.hora_entrada IS NULL
        OR ra.hora_salida IS NULL
      )

ORDER BY tipo_inconsistencia, j.fecha, j.id_jornada;

-- 2. Atrasos
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


-- 3. Horas extra
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


-- 4. Jornadas con contratos no vigentes
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


-- 5. Inconsistencia de área
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


-- 6. Estado general de jornada
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


-- 7. Métricas globales
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

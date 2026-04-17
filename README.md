#  Análisis de Asistencia Laboral con SQL

##  Descripción del Proyecto
Este proyecto consiste en el análisis de datos de asistencia laboral utilizando SQL, con el objetivo de identificar inconsistencias operacionales en registros de jornadas, tales como atrasos, ausencias de marcaje, salidas anticipadas y horas extra.

El modelo de datos fue diseñado en base a escenarios reales de gestión de asistencia laboral, utilizando datos completamente simulados.

---

##  Objetivo
Detectar y analizar inconsistencias entre jornadas programadas y registros reales de asistencia, apoyando la toma de decisiones y el control operativo.

---

##  Modelo de Datos
El proyecto utiliza una base de datos relacional compuesta por las siguientes entidades principales:

- **empleado**: información personal del trabajador
- **empleado_detalle**: relación laboral y contrato vigente
- **contrato_laboral**: condiciones contractuales
- **jornada**: turnos programados
- **registro_asistencia**: marcas de entrada y salida
- **area**: área organizacional
- **puesto**: cargo del trabajador
- **tipo_jornada**: clasificación del turno

---

##  Análisis Realizados

Se desarrollaron consultas SQL para detectar:

- Jornadas sin marca de entrada
- Jornadas sin marca de salida
- Jornadas sin registros de asistencia
- Atrasos en el inicio de la jornada
- Salidas anticipadas
- Horas extra
- Jornadas asignadas a contratos no vigentes
- Inconsistencias entre área del empleado y área del contrato

---

##  Métricas Generadas

- Total de jornadas analizadas
- Jornadas con inconsistencias
- Porcentaje de incumplimiento
- Cantidad de atrasos
- Cantidad de jornadas sin marcaje
- Jornadas con horas extra

---

##  Tecnologías Utilizadas

- SQL (MySQL)
- MySQL Workbench

---

##  Consideraciones

Este proyecto utiliza datos completamente simulados con fines educativos y de portafolio.  
No contiene información real ni sensible.

---

##  Resultados

El análisis permitió identificar múltiples inconsistencias operacionales en los registros de asistencia, destacando:

- Falta de registros de entrada y salida
- Desviaciones en horarios programados
- Jornadas con asignaciones incorrectas respecto a contratos vigentes

---

##  Autor

**Tomás Orellana**  
Analista de Datos en formación  

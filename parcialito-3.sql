-- -- -- -- -- -- -- --
-- A ******************
-- -- -- -- -- -- -- --
WITH aprobadas AS (
    SELECT n.padron, COUNT(*) AS materias_aprobadas
		FROM notas n
		WHERE n.nota >= 4
		GROUP BY (n.padron)
)


SELECT a.padron, a.apellido
FROM alumnos a, aprobadas ap
WHERE a.padron = ap.padron
AND ap.materias_aprobadas = (SELECT MAX(materias_aprobadas) FROM aprobadas);

-- -- -- -- -- -- -- --
-- B ******************
-- -- -- -- -- -- -- --
WITH presente_7114_7115 AS (
    SELECT DISTINCT n.padron 
		FROM notas n
	WHERE n.codigo = 71
		AND (n.numero = 14 OR n.numero = 15)
), presente_7501_7515 AS (
	SELECT DISTINCT n.padron 
		FROM notas n
	WHERE (n.codigo = 75 AND (n.numero = 1 OR n.numero = 15))
)

SELECT DISTINCT a.padron, a.apellido
		FROM alumnos a, notas n
	WHERE a.padron = n.padron
		AND n.padron IN (SELECT padron FROM presente_7114_7115)
		AND n.padron NOT IN (SELECT padron FROM presente_7501_7515)


-- -- -- -- -- -- -- --
-- C ******************
-- -- -- -- -- -- -- --
WITH promedio_nota_materia AS (
    SELECT n.codigo, n.numero, ROUND(AVG(nota), 2) AS promedio  
		FROM notas n
	GROUP BY (n.codigo, n.numero)
), materias_carrera AS (
	SELECT DISTINCT c.codigo AS cod_carrera, c.nombre AS nombre_carrera, n.codigo AS cod_departamento, n.numero AS num_materia
		FROM carreras c, inscripto_en ie, notas n
	WHERE c.codigo = ie.codigo
		AND ie.padron = n.padron
)


SELECT mc.cod_carrera, mc.nombre_carrera, mc.cod_departamento, ROUND(AVG(pnm.promedio ), 2)
	FROM promedio_nota_materia pnm, materias_carrera mc
WHERE pnm.codigo = mc.cod_departamento
	AND pnm.numero = mc.num_materia
GROUP BY (mc.cod_carrera, mc.nombre_carrera, mc.cod_departamento)


-- -- -- -- -- -- -- --
-- D ******************
-- -- -- -- -- -- -- --

WITH cant_nota_por_materias AS (
    SELECT n.padron, n.codigo, n.numero, COUNT(*) AS cant_notas_por_materia
		FROM notas n
	GROUP BY (n.padron, n.codigo, n.numero)
	ORDER BY padron ASC
), cant_materias AS (
	SELECT padron, COUNT(cant_notas_por_materia) AS cant_materias
		FROM cant_nota_por_materias
	GROUP BY (padron)
	ORDER BY padron ASC
), promedio AS (
	SELECT n.padron, ROUND(AVG(n.nota), 2) AS promedio  
		FROM notas n
	GROUP BY (n.padron)
)

SELECT cm.padron, a.apellido, p.promedio
	FROM cant_materias cm, promedio p, alumnos a
	WHERE cm.cant_materias > 3
		AND cm.padron = p.padron
		AND p.padron = a.padron
		AND p.promedio >= 5
	ORDER BY padron ASC

-- -- -- -- -- -- -- --
-- E ******************
-- -- -- -- -- -- -- --

WITH alumnos_mas_antiguos AS (
    SELECT a.padron 
		FROM alumnos a
	WHERE a.fecha_ingreso <= (SELECT MIN(fecha_ingreso) FROM alumnos)
)

SELECT n.padron, n.codigo AS cod_departamento, n.numero AS num_materia, n.nota 
	FROM notas n, alumnos_mas_antiguos ama
	WHERE n.padron = ama.padron

-- 1) Buscar los alumnos que tiene notas en más de 3 materias
-- 2) De los alumnos de 1, buscar los que tienen un promedio de 5 o más
-- -- -- -- -- -- -- --
-- F ******************
-- -- -- -- -- -- -- --
WITH materias_aprobadas_por_71000 AS (
    SELECT n.codigo, n.numero
		FROM notas n
	WHERE n.padron = 71000
		AND n.nota >= 4
)

SELECT a.padron
	FROM alumnos a 
	WHERE NOT EXISTS (
		SELECT 1 FROM materias_aprobadas_por_71000 map71
			WHERE NOT EXISTS (
				SELECT 1 FROM notas n
				WHERE n.padron = a.padron
				AND n.codigo = map71.codigo
				AND n.numero = map71.numero
			) 
	)
	ORDER BY a.padron ASC
    
-- 1) Obtener todas las materias que aprobó el estudiante de padrón 71000
-- 2) Obtener todos los estudiantes que tienen notas en todas las materias de 1
-- Los alumnos para los que no exista materia
-- en los que no exista una nota de ESE alumno en ESA materia
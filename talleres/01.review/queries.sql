-- Equipos por departamento
SELECT d.name, count(t.name)
FROM teams t JOIN departments d 
ON t.department_id = d.id 
GROUP BY t.department_id;

-- Equipos por zona
SELECT z.name, count(t.name)
FROM teams t JOIN zones z 
ON t.department_id = z.id 
GROUP BY t.department_id;

-- Departamento con mayores equipos
SELECT x.name, x.tc
FROM (SELECT t2.name, count(t1.name) as tc
FROM teams t1 JOIN departments t2
ON t1.department_id = t2.id 
GROUP BY t2.name) as x JOIN (SELECT max(z.team_count) as max_teams
FROM (SELECT d.name, count(t.name) as team_count
FROM teams t JOIN departments d 
ON t.department_id = d.id 
GROUP BY t.department_id) as z) as y
ON x.tc = y.max_teams;

-- Departamento con menos equipos.
SELECT x.name, x.tc
FROM (SELECT t2.name, count(t1.name) as tc
FROM teams t1 JOIN departments t2
ON t1.department_id = t2.id 
GROUP BY t2.name) as x JOIN (SELECT min(z.team_count) as max_teams
FROM (SELECT d.name, count(t.name) as team_count
FROM teams t JOIN departments d 
ON t.department_id = d.id 
GROUP BY t.department_id) as z) as y
ON x.tc = y.max_teams;

-- Equipo con mayores estrellas.
SELECT t.name, t.num_stars 
FROM teams t JOIN
(
SELECT max(t.num_stars) as max_s
FROM teams t
) as t2 on t.num_stars = t2.max_s;

-- Promedio de estrellas de los equipos de las zonas.
SELECT z.name, avg(t.num_stars)
FROM zones z JOIN teams t
ON t.zone_id = z.id 
GROUP BY z.name;

-- Cantidad de seguidores por zonas.
SELECT b.name, sum(a.followers_quantity)
FROM (SELECT t.name, t.zone_id, fq.followers_quantity
FROM teams t JOIN follower_quantities fq
ON t.id = fq.team_id) as a JOIN 
(
SELECT z.id, z.name
FROM zones z 
) as b
ON a.zone_id = b.id
GROUP BY b.name;

-- Si la cantidad de seguidores de una zona es mayor a 10000, debe decir es equipo grande, de lo contrario debe decir equipos pequeños.
SELECT b.name,
CASE 
	WHEN SUM(a.followers_quantity) > 15000 THEN 'BIG'
	ELSE 'SMALL'
END AS zone_size
FROM (SELECT t.name, t.zone_id, fq.followers_quantity
FROM teams t JOIN follower_quantities fq
ON t.id = fq.team_id) as a JOIN 
(
SELECT z.id, z.name
FROM zones z 
) as b
ON a.zone_id = b.id
GROUP BY b.name;

-- Cuál es el que más tiene % de probabilidad de ganar una Copa.
SELECT t.name, s.one_trophy 
FROM teams t JOIN statistics s
ON t.id = s.team_id
JOIN
(
SELECT max(s.one_trophy) as max_pos
FROM statistics s 
) as b
ON s.one_trophy = b.max_pos 

-- Cuál es el que tiene mayor probabilidad de ganar 2 copas.
SELECT t.name, s.two_or_more_trophies
FROM teams t JOIN statistics s
ON t.id = s.team_id
JOIN
(
SELECT max(s.two_or_more_trophies) as max_pos
FROM statistics s 
) as b
ON s.two_or_more_trophies = b.max_pos 

-- Ordenar las zonas de mayor a menor las que más tiene probabilidad de ganar más de dos copas.
-- Debido a que una zona puede tener varios equipos, se tomo el promedio de las posibilidades de los equipos de la zona.
SELECT b.name, avg(a.two_or_more_trophies)
FROM (SELECT t.zone_id, t.name, s.two_or_more_trophies 
FROM teams t JOIN statistics s
ON t.id = s.team_id) as a
JOIN
(
SELECT z.id, z.name 
FROM zones z 
) as b
ON a.zone_id = b.id 
GROUP BY b.name
ORDER BY avg(a.two_or_more_trophies) desc;

-- Equipo con mayor posibilidaad de ganar una copa
-- Para esta query se busca al equipo con mayor posibilidad de gaanar una copa - Esto viene de lo concretado de la ultima clase
SELECT a.name, IF(a.one_trophy = b.max_pos, "FUTURO CAMPEON", "") as is_champ
FROM (
SELECT t.name, s.one_trophy 
FROM teams t JOIN statistics s
ON t.id = s.team_id
) as a
JOIN
(
SELECT max(s.one_trophy) as max_pos
FROM teams t JOIN statistics s
ON t.id = s.team_id
) as b
ON a.one_trophy = b.max_pos


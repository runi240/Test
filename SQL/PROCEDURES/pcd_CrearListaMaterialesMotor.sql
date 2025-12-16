CREATE DEFINER=`root`@`localhost` PROCEDURE `vw_CrearListaMaterialesMotor`(p_fabricante VARCHAR(45), p_potenica FLOAT)
BEGIN
	TRUNCATE TABLE `subtabla listado materiales`;
    
    INSERT INTO `subtabla listado materiales` (Referencia)
       WITH tabla_1 AS (
        SELECT 
            a.idDefinicionEstructurasMotores,
            b.Referencia,
            a.TipoEstructura,
            a.TipoComponente
        FROM `definicion estructuras motores` a
        LEFT JOIN componentes b 
            ON b.Tipo = a.TipoComponente
            AND b.`Potencia (kW)` >= p_potenica
            AND b.`Potencia (kW)` = (
                SELECT MIN(b2.`Potencia (kW)`)
                FROM componentes b2
                WHERE b2.Tipo = a.TipoComponente
                  AND b2.`Potencia (kW)` >= p_potenica
            )
        WHERE b.Fabricante = p_fabricante 
          AND a.DebeSerComlementoDe1 IS NULL
    ),

    tabla_2 AS (
        SELECT 
            a.idDefinicionEstructurasMotores,
            a.TipoEstructura,
            a.TipoComponente,
            b.Referencia AS Complemento1,
            c.Referencia AS Complemento2
        FROM `definicion estructuras motores` a
        LEFT JOIN tabla_1 b 
            ON a.DebeSerComlementoDe1 = b.idDefinicionEstructurasMotores
        LEFT JOIN tabla_1 c 
            ON a.DebeSerComlementoDe2 = c.idDefinicionEstructurasMotores
    ),

    tabla_3 AS (
        SELECT 
            a.idDefinicionEstructurasMotores,
            b.Referencia,
            a.TipoEstructura,
            a.TipoComponente,
            c.Complemento1,
            c.Complemento2
        FROM `definicion estructuras motores` a
        LEFT JOIN tabla_1 b 
            ON b.TipoComponente = a.TipoComponente
        LEFT JOIN tabla_2 c 
            ON c.TipoComponente = a.TipoComponente
    ),

    tabla_4 AS (
        SELECT 
            a.idDefinicionEstructurasMotores,
            a.Referencia,
            a.TipoEstructura,
            a.TipoComponente,
            a.Complemento1,
            a.Complemento2,
            MAX(b.Accesorio) AS Accesorio
        FROM tabla_3 a
        LEFT JOIN vw_relación_componentes_referencias b
            ON (b.Componente = a.Complemento1 OR (a.Complemento2 IS NOT NULL AND b.Componente = a.Complemento2))
            AND b.TipoAccesorio = a.TipoComponente
        GROUP BY 
            a.idDefinicionEstructurasMotores,
            a.Referencia,
            a.TipoEstructura,
            a.TipoComponente,
            a.Complemento1,
            a.Complemento2
        HAVING 
            COUNT(DISTINCT CASE WHEN b.Componente = a.Complemento1 THEN b.Componente END) = 1
            AND (a.Complemento2 IS NULL OR 
                 COUNT(DISTINCT CASE WHEN b.Componente = a.Complemento2 THEN b.Componente END) = 1)
    ),
    tabla_5 AS (
    SELECT 
        a.idDefinicionEstructurasMotores,
        COALESCE(b.Referencia, c.Accesorio) AS Referencia,
        a.TipoComponente
    FROM `definicion estructuras motores` a
    LEFT JOIN tabla_3 b 
        ON a.idDefinicionEstructurasMotores = b.idDefinicionEstructurasMotores
    LEFT JOIN tabla_4 c 
        ON a.idDefinicionEstructurasMotores = c.idDefinicionEstructurasMotores
    ORDER BY a.idDefinicionEstructurasMotores)
    
	SELECT referencia
    FROM tabla_5
    WHERE referencia IS NOT NULL;
END
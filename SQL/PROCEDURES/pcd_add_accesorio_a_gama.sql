CREATE DEFINER=`root`@`localhost` PROCEDURE `pcd_add_accesorio_a_gama`(
    IN prefijo VARCHAR(50),
    IN refAccesorio VARCHAR(50)
)
BEGIN
    DECLARE accesorioID INT;

    -- Obtener el id del accesorio según su referencia
    SELECT idComponentes
    INTO accesorioID
    FROM componentes
    WHERE referencia = refAccesorio
    LIMIT 1;

    -- Insertar todas las coincidencias
    INSERT INTO relación_accesorios (idComponentes, idAccesorio)
    SELECT idComponentes, accesorioID
    FROM componentes
	WHERE referencia LIKE CONCAT(prefijo, '%');
END
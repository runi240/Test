CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW vw_relación_componentes_referencias AS
    SELECT 
        n1.Referencia AS Componente, n2.Referencia AS Accesorio
    FROM
        ((relación_accesorios
        JOIN componentes n1 ON ((relación_accesorios.idComponentes = n1.idComponentes)))
        JOIN componentes n2 ON ((relación_accesorios.idAccesorio = n2.idComponentes)))
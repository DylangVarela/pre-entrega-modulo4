SET search_path TO practica_m4;

-- =====================================================
-- 1. RENTABILIDAD POR CATEGORIA
-- =====================================================
-- Problema de negocio:
-- Permite conocer qué categorías generan mayores ingresos
-- y cuántas unidades se vendieron de cada una.
-- Esta información ayuda a identificar las categorías
-- con mejor rendimiento comercial.
--
-- Umbral definido en 500 porque permite identificar
-- categorías con ingresos superiores a ese valor
-- y comparar su rendimiento comercial.
-- =====================================================

SELECT
    cat.nombre_categoria AS categoria,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(v.cantidad * p.precio), 0) AS ingreso_total
FROM ventas AS v
INNER JOIN productos AS p
    ON v.producto_id = p.producto_id
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.categoria_id
GROUP BY
    cat.categoria_id,
    cat.nombre_categoria
HAVING SUM(v.cantidad * p.precio) > 500
ORDER BY ingreso_total DESC;

-- =====================================================
-- 2. CLIENTES SIN COMPRAS
-- =====================================================
-- Problema de negocio:
-- Permite identificar los clientes registrados que
-- todavía no realizaron ninguna compra.
-- Esta información puede utilizarse para desarrollar
-- campañas de marketing y estrategias para conseguir
-- nuevas ventas.
--
-- LEFT JOIN permite conservar todos los clientes.
-- COALESCE muestra 0 cuando no existen compras.
-- =====================================================

SELECT
    c.cliente_id,
    c.nombre AS cliente,
    COALESCE(COUNT(v.venta_id), 0) AS cantidad_compras
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.cliente_id = v.cliente_id
GROUP BY
    c.cliente_id,
    c.nombre
HAVING COUNT(v.venta_id) = 0
ORDER BY c.nombre;


-- =====================================================
-- 3. TOP DE COMPRAS POR CLIENTE
-- =====================================================
-- Problema de negocio:
-- Permite conocer cuál es el producto que más veces
-- compró cada cliente y cuándo realizó su última compra.
-- Esta información ayuda a conocer las preferencias
-- de los clientes y personalizar futuras promociones.
--
-- La subconsulta correlacionada cuenta las compras
-- de cada producto para cada cliente y ordena de mayor
-- a menor. LIMIT 1 devuelve el producto más comprado.
--
-- MAX(fecha) permite conocer la última transacción.
-- =====================================================

SELECT
    c.nombre AS cliente,

    (
        SELECT p.nombre
        FROM ventas AS v2
        INNER JOIN productos AS p
            ON p.producto_id = v2.producto_id
        WHERE v2.cliente_id = c.cliente_id
        GROUP BY p.producto_id, p.nombre
        ORDER BY COUNT(*) DESC, p.nombre ASC
        LIMIT 1
    ) AS producto_mas_comprado,

    MAX(v.fecha) AS ultima_transaccion

FROM clientes AS c
LEFT JOIN ventas AS v
    ON v.cliente_id = c.cliente_id

GROUP BY
    c.cliente_id,
    c.nombre

ORDER BY c.nombre;
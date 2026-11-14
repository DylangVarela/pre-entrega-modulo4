-- =====================================================
-- PREENTREGA: ANALISIS AVANZADO CON WINDOW FUNCTIONS
-- Base de datos: PostgreSQL
-- =====================================================

-- OBJETIVO:
-- Analizar las ventas mensuales por categoria,
-- calcular rankings, ventas acumuladas y comparar
-- cada mes contra el promedio historico de su categoria.

WITH ventas_mensuales AS (

    -- =================================================
    -- CTE 1: VENTAS MENSUALES
    -- Agrupa las ventas por mes y categoria.
    -- Calcula el total vendido en cada periodo.
    -- =================================================

    SELECT
        DATE_TRUNC('month', v.fecha) AS mes,
        c.nombre_categoria AS categoria,
        SUM(v.cantidad * p.precio) AS venta_total

    FROM ventas v

    INNER JOIN productos p
        ON v.producto_id = p.producto_id

    INNER JOIN categorias c
        ON p.id_categoria = c.categoria_id

    GROUP BY
        DATE_TRUNC('month', v.fecha),
        c.nombre_categoria
),
metricas_ventana AS (

    -- =================================================
    -- CTE 2: METRICAS DE VENTANA
    -- Calcula el ranking mensual de cada categoria
    -- y el acumulado historico de ventas por categoria.
    -- =================================================

    SELECT
        mes,
        categoria,
        venta_total,

        -- Ranking de categorias dentro de cada mes.
        RANK() OVER (
            PARTITION BY mes
            ORDER BY venta_total DESC
        ) AS ranking,

        -- Ventas acumuladas de cada categoria
        -- a lo largo de los diferentes meses.
        SUM(venta_total) OVER (
            PARTITION BY categoria
            ORDER BY mes
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS acumulado

    FROM ventas_mensuales
)

-- =====================================================
-- CONSULTA FINAL
-- Compara las ventas mensuales contra el promedio
-- historico de ventas de cada categoria.
-- =====================================================

SELECT
    mes,
    categoria,
    venta_total,
    ranking,
    acumulado,

    CASE
        WHEN venta_total >= AVG(venta_total) OVER (
            PARTITION BY categoria
        )
        THEN 'Exitoso'
        ELSE 'Bajo el promedio'
    END AS comparativa

FROM metricas_ventana

ORDER BY
    mes ASC,
    ranking ASC;
CREATE TABLE IF NOT EXISTS inventory (
    product_id INTEGER PRIMARY KEY,
    stock INTEGER NOT NULL
);
INSERT INTO inventory (product_id, stock)
VALUES
    (42, 18),
    (43, 7),
    (44, 0)
ON CONFLICT (product_id) DO NOTHING;
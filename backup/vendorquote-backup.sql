-- VendorQuote Database Backup (FAKE DATA FOR TRAINING)
-- Generated: 2026-03-15 08:00:00
-- Database: vendorquote_prod

CREATE TABLE IF NOT EXISTS vendors (
  id INT PRIMARY KEY AUTO_INCREMENT,
  vendor_name VARCHAR(255) NOT NULL,
  contact_email VARCHAR(255),
  tier VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO vendors (vendor_name, contact_email, tier) VALUES
  ('TechSupply Inc', 'quotes@techsupply.example', 'preferred'),
  ('DataCorp Solutions', 'sales@datacorp.example', 'standard'),
  ('CloudHost LLC', 'enterprise@cloudhost.example', 'strategic');

CREATE TABLE IF NOT EXISTS quotes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  vendor_id INT,
  sku VARCHAR(100),
  base_price DECIMAL(10,2),
  discount_pct DECIMAL(5,2),
  status VARCHAR(50),
  FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

INSERT INTO quotes (vendor_id, sku, base_price, discount_pct, status) VALUES
  (1, 'TS-SRV-2400', 12500.00, 12.00, 'approved'),
  (2, 'DC-LIC-ENT', 8900.00, 18.00, 'approved'),
  (3, 'CH-YEAR-PREMIUM', 24000.00, 20.00, 'pending');

-- End of backup

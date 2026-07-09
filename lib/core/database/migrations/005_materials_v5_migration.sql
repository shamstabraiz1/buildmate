-- ============================================================================
-- BuildMate DB Migration: v4 → v5
-- Phase 4 – Materials Management
-- ============================================================================

-- ─── 1. Extend materials table ────────────────────────────────────────────────
ALTER TABLE materials ADD COLUMN materialNumber     TEXT NOT NULL DEFAULT '';
ALTER TABLE materials ADD COLUMN category           TEXT NOT NULL DEFAULT 'other';
ALTER TABLE materials ADD COLUMN customCategory     TEXT;
ALTER TABLE materials ADD COLUMN quantityPurchased  REAL NOT NULL DEFAULT 0;
ALTER TABLE materials ADD COLUMN quantityUsed       REAL NOT NULL DEFAULT 0;
ALTER TABLE materials ADD COLUMN reorderLevel       REAL NOT NULL DEFAULT 0;
ALTER TABLE materials ADD COLUMN status             TEXT NOT NULL DEFAULT 'available';
ALTER TABLE materials ADD COLUMN imagePath          TEXT;
ALTER TABLE materials ADD COLUMN notes              TEXT;
-- NOTE: projectId and vendorId and unitPrice and unit were already present
-- in the v4 _createDB definition. Skip ALTER if they already exist.

-- ─── 2. Extend vendors table ──────────────────────────────────────────────────
ALTER TABLE vendors ADD COLUMN rating  REAL NOT NULL DEFAULT 0;
ALTER TABLE vendors ADD COLUMN notes   TEXT;

-- ─── 3. Create material_transactions table ────────────────────────────────────
CREATE TABLE IF NOT EXISTS material_transactions (
  id          TEXT PRIMARY KEY,
  uuid        TEXT NOT NULL,
  materialId  TEXT NOT NULL,
  projectId   TEXT NOT NULL,
  vendorId    TEXT,           -- FK → vendors.id (nullable; use for purchased/returned)
  type        TEXT NOT NULL,  -- purchased | used | returned | adjustment | damaged
  quantity    REAL NOT NULL,
  unitPrice   REAL,           -- snapshot of price at time of purchase
  date        TEXT NOT NULL,  -- ISO8601
  notes       TEXT,
  createdAt   TEXT NOT NULL,
  updatedAt   TEXT NOT NULL,
  isDeleted   INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_mat_txn_materialId ON material_transactions(materialId);
CREATE INDEX IF NOT EXISTS idx_mat_txn_projectId  ON material_transactions(projectId);

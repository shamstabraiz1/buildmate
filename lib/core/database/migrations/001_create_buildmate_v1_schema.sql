PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  client_name TEXT,
  location TEXT,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('planned', 'active', 'paused', 'completed', 'cancelled')),
  start_date TEXT,
  end_date TEXT,
  estimated_budget_cents INTEGER NOT NULL DEFAULT 0 CHECK (estimated_budget_cents >= 0),
  currency_code TEXT NOT NULL DEFAULT 'USD',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  archived_at TEXT
);

CREATE TABLE IF NOT EXISTS vendors (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  contact_person TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  vendor_type TEXT NOT NULL DEFAULT 'supplier'
    CHECK (vendor_type IN ('supplier', 'contractor', 'labour_contractor', 'transport', 'other')),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  archived_at TEXT
);

CREATE TABLE IF NOT EXISTS labour (
  id TEXT PRIMARY KEY,
  project_id TEXT,
  vendor_id TEXT,
  full_name TEXT NOT NULL,
  phone TEXT,
  role TEXT,
  wage_type TEXT NOT NULL DEFAULT 'daily'
    CHECK (wage_type IN ('hourly', 'daily', 'weekly', 'monthly', 'contract')),
  wage_rate_cents INTEGER NOT NULL DEFAULT 0 CHECK (wage_rate_cents >= 0),
  currency_code TEXT NOT NULL DEFAULT 'USD',
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'released')),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  archived_at TEXT,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  vendor_id TEXT,
  labour_id TEXT,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL DEFAULT 'miscellaneous'
    CHECK (
      category IN (
        'materials',
        'labour',
        'equipment',
        'transport',
        'permits',
        'utilities',
        'subcontractor',
        'miscellaneous'
      )
    ),
  expense_date TEXT NOT NULL,
  amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
  currency_code TEXT NOT NULL DEFAULT 'USD',
  payment_status TEXT NOT NULL DEFAULT 'unpaid'
    CHECK (payment_status IN ('unpaid', 'partial', 'paid', 'cancelled')),
  receipt_path TEXT,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  archived_at TEXT,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL,
  FOREIGN KEY (labour_id) REFERENCES labour(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS attendance (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  labour_id TEXT NOT NULL,
  work_date TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'present'
    CHECK (status IN ('present', 'absent', 'half_day', 'paid_leave', 'unpaid_leave')),
  check_in_time TEXT,
  check_out_time TEXT,
  hours_worked REAL NOT NULL DEFAULT 0 CHECK (hours_worked >= 0),
  overtime_hours REAL NOT NULL DEFAULT 0 CHECK (overtime_hours >= 0),
  wage_amount_cents INTEGER NOT NULL DEFAULT 0 CHECK (wage_amount_cents >= 0),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (labour_id) REFERENCES labour(id) ON DELETE CASCADE,
  UNIQUE (project_id, labour_id, work_date)
);

CREATE TABLE IF NOT EXISTS materials (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  vendor_id TEXT,
  expense_id TEXT,
  name TEXT NOT NULL,
  category TEXT,
  unit TEXT NOT NULL DEFAULT 'unit',
  quantity REAL NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  unit_cost_cents INTEGER NOT NULL DEFAULT 0 CHECK (unit_cost_cents >= 0),
  total_cost_cents INTEGER NOT NULL DEFAULT 0 CHECK (total_cost_cents >= 0),
  purchase_date TEXT,
  delivery_date TEXT,
  status TEXT NOT NULL DEFAULT 'ordered'
    CHECK (status IN ('planned', 'ordered', 'delivered', 'used', 'returned', 'cancelled')),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  archived_at TEXT,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL,
  FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS payments (
  id TEXT PRIMARY KEY,
  project_id TEXT,
  vendor_id TEXT,
  labour_id TEXT,
  expense_id TEXT,
  amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
  currency_code TEXT NOT NULL DEFAULT 'USD',
  payment_date TEXT NOT NULL,
  payment_method TEXT NOT NULL DEFAULT 'cash'
    CHECK (
      payment_method IN (
        'cash',
        'bank_transfer',
        'card',
        'cheque',
        'mobile_wallet',
        'other'
      )
    ),
  reference_number TEXT,
  status TEXT NOT NULL DEFAULT 'completed'
    CHECK (status IN ('pending', 'completed', 'cancelled', 'refunded')),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  archived_at TEXT,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL,
  FOREIGN KEY (labour_id) REFERENCES labour(id) ON DELETE SET NULL,
  FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS settings (
  id TEXT PRIMARY KEY,
  project_id TEXT,
  setting_key TEXT NOT NULL,
  setting_value TEXT NOT NULL,
  value_type TEXT NOT NULL DEFAULT 'string'
    CHECK (value_type IN ('string', 'int', 'double', 'bool', 'json')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  UNIQUE (project_id, setting_key)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_settings_global_key
ON settings(setting_key)
WHERE project_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_archived_at ON projects(archived_at);

CREATE INDEX IF NOT EXISTS idx_vendors_name ON vendors(name);
CREATE INDEX IF NOT EXISTS idx_vendors_type ON vendors(vendor_type);

CREATE INDEX IF NOT EXISTS idx_labour_project_id ON labour(project_id);
CREATE INDEX IF NOT EXISTS idx_labour_vendor_id ON labour(vendor_id);
CREATE INDEX IF NOT EXISTS idx_labour_status ON labour(status);

CREATE INDEX IF NOT EXISTS idx_expenses_project_id ON expenses(project_id);
CREATE INDEX IF NOT EXISTS idx_expenses_vendor_id ON expenses(vendor_id);
CREATE INDEX IF NOT EXISTS idx_expenses_labour_id ON expenses(labour_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);
CREATE INDEX IF NOT EXISTS idx_expenses_payment_status ON expenses(payment_status);

CREATE INDEX IF NOT EXISTS idx_attendance_project_id ON attendance(project_id);
CREATE INDEX IF NOT EXISTS idx_attendance_labour_id ON attendance(labour_id);
CREATE INDEX IF NOT EXISTS idx_attendance_work_date ON attendance(work_date);

CREATE INDEX IF NOT EXISTS idx_materials_project_id ON materials(project_id);
CREATE INDEX IF NOT EXISTS idx_materials_vendor_id ON materials(vendor_id);
CREATE INDEX IF NOT EXISTS idx_materials_expense_id ON materials(expense_id);
CREATE INDEX IF NOT EXISTS idx_materials_status ON materials(status);

CREATE INDEX IF NOT EXISTS idx_payments_project_id ON payments(project_id);
CREATE INDEX IF NOT EXISTS idx_payments_vendor_id ON payments(vendor_id);
CREATE INDEX IF NOT EXISTS idx_payments_labour_id ON payments(labour_id);
CREATE INDEX IF NOT EXISTS idx_payments_expense_id ON payments(expense_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_date ON payments(payment_date);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

CREATE INDEX IF NOT EXISTS idx_settings_project_id ON settings(project_id);

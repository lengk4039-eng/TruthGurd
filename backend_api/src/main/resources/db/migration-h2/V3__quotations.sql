CREATE TABLE quotations (
    id                  UUID PRIMARY KEY,
    user_id             UUID         NOT NULL REFERENCES users (id),
    package_id          UUID         NOT NULL REFERENCES insurance_packages (id),
    preferred_plan_months INTEGER    NOT NULL,
    notes               TEXT,
    status              VARCHAR(32)  NOT NULL,
    quoted_premium      NUMERIC(12, 2),
    valid_until         DATE,
    sales_notes         TEXT,
    policy_id           UUID REFERENCES policies (id),
    created_at          TIMESTAMP WITH TIME ZONE  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quotations_user ON quotations (user_id);
CREATE INDEX idx_quotations_status ON quotations (status);

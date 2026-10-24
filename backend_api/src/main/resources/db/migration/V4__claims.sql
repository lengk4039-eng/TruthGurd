CREATE TABLE claims (
    id            UUID PRIMARY KEY,
    claim_number  VARCHAR(50) NOT NULL UNIQUE,
    user_id       UUID NOT NULL REFERENCES users(id),
    policy_id     UUID NOT NULL REFERENCES policies(id),
    type          VARCHAR(20) NOT NULL,
    status        VARCHAR(20) NOT NULL,
    description   VARCHAR(2000) NOT NULL,
    amount        NUMERIC(12, 2) NOT NULL,
    incident_date DATE NOT NULL,
    photo_url     VARCHAR(500),
    review_notes  VARCHAR(2000),
    submitted_at  TIMESTAMPTZ NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_claims_user ON claims (user_id);
CREATE INDEX idx_claims_policy ON claims (policy_id);
CREATE INDEX idx_claims_status ON claims (status);

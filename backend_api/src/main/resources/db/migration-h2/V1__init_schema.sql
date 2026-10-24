CREATE TABLE users (
    id              UUID PRIMARY KEY,
    full_name       VARCHAR(255) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    phone           VARCHAR(50)  NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    role            VARCHAR(20)  NOT NULL,
    kyc_verified    BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP    NOT NULL
);

CREATE TABLE insurance_packages (
    id              UUID PRIMARY KEY,
    category        VARCHAR(20)    NOT NULL,
    name            VARCHAR(255)   NOT NULL,
    tagline         VARCHAR(500)   NOT NULL,
    description     VARCHAR(2000)  NOT NULL,
    monthly_price   NUMERIC(12, 2) NOT NULL,
    coverage_amount NUMERIC(14, 2) NOT NULL,
    duration_months INT            NOT NULL,
    featured        BOOLEAN        NOT NULL DEFAULT FALSE,
    active          BOOLEAN        NOT NULL DEFAULT TRUE,
    rating          DOUBLE PRECISION NOT NULL DEFAULT 4.7,
    review_count    INT            NOT NULL DEFAULT 0
);

CREATE TABLE package_benefits (
    package_id UUID NOT NULL REFERENCES insurance_packages(id) ON DELETE CASCADE,
    position   INT  NOT NULL,
    benefit    VARCHAR(500),
    PRIMARY KEY (package_id, position)
);

CREATE TABLE policies (
    id                      UUID PRIMARY KEY,
    policy_number           VARCHAR(50) NOT NULL UNIQUE,
    user_id                 UUID REFERENCES users(id),
    package_id              UUID NOT NULL REFERENCES insurance_packages(id),
    status                  VARCHAR(20) NOT NULL,
    source                  VARCHAR(30) NOT NULL,
    start_date              DATE NOT NULL,
    end_date                DATE NOT NULL,
    total_premium           NUMERIC(12, 2) NOT NULL,
    amount_paid             NUMERIC(12, 2) NOT NULL DEFAULT 0,
    date_of_birth_on_record DATE,
    created_at              TIMESTAMP NOT NULL
);

CREATE INDEX idx_policies_user ON policies(user_id);

CREATE TABLE payments (
    id               UUID PRIMARY KEY,
    policy_id        UUID NOT NULL REFERENCES policies(id),
    invoice_number   VARCHAR(50) NOT NULL UNIQUE,
    amount           NUMERIC(12, 2) NOT NULL,
    due_date         DATE NOT NULL,
    paid_date        DATE,
    status           VARCHAR(20) NOT NULL,
    method           VARCHAR(20),
    transaction_ref  VARCHAR(100),
    created_at       TIMESTAMP NOT NULL
);

CREATE INDEX idx_payments_policy ON payments(policy_id);

CREATE TABLE notifications (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES users(id),
    type        VARCHAR(20) NOT NULL,
    title       VARCHAR(255) NOT NULL,
    body        VARCHAR(1000) NOT NULL,
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP NOT NULL
);

CREATE INDEX idx_notifications_user ON notifications(user_id);

-- Demo accounts (password for both: "Password123")
INSERT INTO users (id, full_name, email, phone, password_hash, role, kyc_verified, created_at) VALUES
('11111111-1111-1111-1111-111111111111', 'TrustGuard Admin', 'admin@trustguard.example', '+1 555-0100',
 '$2b$10$jwThG2WNtJ/8goV8kvJlQ.SyNgaj8sJz5jWKBvTkgkHue4/oJMi1q', 'ADMIN', true, now()),
('22222222-2222-2222-2222-222222222222', 'Jordan Lee', 'jordan.lee@email.com', '+1 555-0142',
 '$2b$10$jwThG2WNtJ/8goV8kvJlQ.SyNgaj8sJz5jWKBvTkgkHue4/oJMi1q', 'CUSTOMER', true, now());

-- Packages
INSERT INTO insurance_packages (id, category, name, tagline, description, monthly_price, coverage_amount, duration_months, featured, active, rating, review_count) VALUES
('a0000000-0000-0000-0000-000000000001', 'HEALTH', 'Health Shield Basic', 'Everyday medical cover, no surprises',
 'Solid coverage for everyday health needs -- outpatient visits, emergencies, and an annual checkup, all with a straightforward claims process.',
 45.00, 50000.00, 12, false, true, 4.7, 0),
('a0000000-0000-0000-0000-000000000002', 'HEALTH', 'Health Shield Premium', 'Complete care for you and your family',
 'Our most complete health plan -- specialist visits, dental and vision, and maternity care, with no waiting period so cover starts the day you buy it.',
 89.00, 150000.00, 12, true, true, 4.7, 482),
('a0000000-0000-0000-0000-000000000003', 'LIFE', 'Life Secure Term 20', 'Affordable protection for your family''s future',
 'A 20-year term life policy that pays out for your loved ones when it matters most, with an accelerated payout if you''re diagnosed with a terminal illness.',
 32.00, 250000.00, 240, false, true, 4.7, 0),
('a0000000-0000-0000-0000-000000000004', 'LIFE', 'Life Secure Whole Life', 'Lifetime cover that builds cash value',
 'Coverage that never expires, with a savings component that grows over time and can be borrowed against when you need it.',
 68.00, 500000.00, 999, false, true, 4.7, 201),
('a0000000-0000-0000-0000-000000000005', 'VEHICLE', 'AutoGuard Essential', 'Legally covered, budget-friendly',
 'Meets the essentials -- third-party liability, roadside help, and windshield cover for daily drivers.',
 38.00, 30000.00, 12, false, true, 4.7, 0),
('a0000000-0000-0000-0000-000000000006', 'VEHICLE', 'AutoGuard Comprehensive', 'Full protection, zero depreciation',
 'Own-damage and third-party cover in one plan, with zero depreciation on claims and engine protection for total peace of mind.',
 72.00, 80000.00, 12, true, true, 4.7, 356),
('a0000000-0000-0000-0000-000000000007', 'HOME', 'HomeSafe Renters', 'Protect what''s yours, wherever you rent',
 'Covers your belongings against fire and theft, plus temporary relocation if your rental becomes unlivable.',
 18.00, 25000.00, 12, false, true, 4.7, 0),
('a0000000-0000-0000-0000-000000000008', 'HOME', 'HomeSafe Owners', 'Complete cover for the place you own',
 'Structure and belongings, natural disaster cover, and liability protection for homeowners.',
 55.00, 200000.00, 12, false, true, 4.7, 164),
('a0000000-0000-0000-0000-000000000009', 'TRAVEL', 'TravelEase Single Trip', 'One trip, fully covered',
 'Trip cancellation, lost baggage, and emergency medical cover abroad for a single upcoming trip.',
 15.00, 20000.00, 1, false, true, 4.7, 0),
('a0000000-0000-0000-0000-00000000000a', 'TRAVEL', 'TravelEase Annual Multi-Trip', 'Unlimited trips, one annual plan',
 'Unlimited trips under 30 days each, with medical evacuation and adventure sports cover included.',
 25.00, 40000.00, 12, true, true, 4.7, 98);

INSERT INTO package_benefits (package_id, position, benefit) VALUES
('a0000000-0000-0000-0000-000000000001', 0, 'Outpatient care'),
('a0000000-0000-0000-0000-000000000001', 1, 'Emergency room visits'),
('a0000000-0000-0000-0000-000000000001', 2, 'Annual health checkup'),
('a0000000-0000-0000-0000-000000000001', 3, 'Prescription discount'),
('a0000000-0000-0000-0000-000000000002', 0, 'Everything in Basic'),
('a0000000-0000-0000-0000-000000000002', 1, 'Specialist consultations'),
('a0000000-0000-0000-0000-000000000002', 2, 'Dental & vision'),
('a0000000-0000-0000-0000-000000000002', 3, 'Maternity care'),
('a0000000-0000-0000-0000-000000000002', 4, 'No waiting period'),
('a0000000-0000-0000-0000-000000000003', 0, '20-year term'),
('a0000000-0000-0000-0000-000000000003', 1, 'Accidental death benefit'),
('a0000000-0000-0000-0000-000000000003', 2, 'Terminal illness payout'),
('a0000000-0000-0000-0000-000000000003', 3, 'No medical exam under 40'),
('a0000000-0000-0000-0000-000000000004', 0, 'Lifetime coverage'),
('a0000000-0000-0000-0000-000000000004', 1, 'Cash value growth'),
('a0000000-0000-0000-0000-000000000004', 2, 'Flexible premiums'),
('a0000000-0000-0000-0000-000000000004', 3, 'Loan against policy'),
('a0000000-0000-0000-0000-000000000005', 0, 'Third-party liability'),
('a0000000-0000-0000-0000-000000000005', 1, '24/7 roadside assistance'),
('a0000000-0000-0000-0000-000000000005', 2, 'Windshield cover'),
('a0000000-0000-0000-0000-000000000006', 0, 'Everything in Essential'),
('a0000000-0000-0000-0000-000000000006', 1, 'Own-damage cover'),
('a0000000-0000-0000-0000-000000000006', 2, 'Zero depreciation'),
('a0000000-0000-0000-0000-000000000006', 3, 'Engine protection'),
('a0000000-0000-0000-0000-000000000006', 4, '24/7 claim support'),
('a0000000-0000-0000-0000-000000000007', 0, 'Personal belongings'),
('a0000000-0000-0000-0000-000000000007', 1, 'Fire & theft'),
('a0000000-0000-0000-0000-000000000007', 2, 'Temporary relocation'),
('a0000000-0000-0000-0000-000000000008', 0, 'Structure & belongings'),
('a0000000-0000-0000-0000-000000000008', 1, 'Natural disaster cover'),
('a0000000-0000-0000-0000-000000000008', 2, 'Liability protection'),
('a0000000-0000-0000-0000-000000000008', 3, 'Home office equipment'),
('a0000000-0000-0000-0000-000000000009', 0, 'Trip cancellation'),
('a0000000-0000-0000-0000-000000000009', 1, 'Lost baggage'),
('a0000000-0000-0000-0000-000000000009', 2, 'Medical emergency abroad'),
('a0000000-0000-0000-0000-00000000000a', 0, 'Unlimited trips under 30 days'),
('a0000000-0000-0000-0000-00000000000a', 1, 'Medical evacuation'),
('a0000000-0000-0000-0000-00000000000a', 2, 'Flight delay compensation'),
('a0000000-0000-0000-0000-00000000000a', 3, 'Adventure sports cover');

-- Jordan Lee's policies
INSERT INTO policies (id, policy_number, user_id, package_id, status, source, start_date, end_date, total_premium, amount_paid, date_of_birth_on_record, created_at) VALUES
('b0000000-0000-0000-0000-000000000001', 'POL-2024-0091', '22222222-2222-2222-2222-222222222222', 'a0000000-0000-0000-0000-000000000002',
 'ACTIVE', 'APP_PURCHASE', CURRENT_DATE - INTERVAL '7 months', CURRENT_DATE + INTERVAL '5 months', 1068.00, 623.00, NULL, now()),
('b0000000-0000-0000-0000-000000000002', 'POL-2024-0142', '22222222-2222-2222-2222-222222222222', 'a0000000-0000-0000-0000-000000000006',
 'ACTIVE', 'LINKED_EXISTING', CURRENT_DATE - INTERVAL '10 months', CURRENT_DATE + INTERVAL '2 months', 864.00, 720.00, NULL, now()),
('b0000000-0000-0000-0000-000000000003', 'POL-2023-0087', '22222222-2222-2222-2222-222222222222', 'a0000000-0000-0000-0000-000000000003',
 'ACTIVE', 'APP_PURCHASE', CURRENT_DATE - INTERVAL '16 months', CURRENT_DATE + INTERVAL '224 months', 7680.00, 512.00, NULL, now()),
('b0000000-0000-0000-0000-000000000004', 'POL-2022-0055', '22222222-2222-2222-2222-222222222222', 'a0000000-0000-0000-0000-000000000007',
 'EXPIRED', 'APP_PURCHASE', CURRENT_DATE - INTERVAL '24 months', CURRENT_DATE - INTERVAL '12 months', 216.00, 216.00, NULL, now());

-- Unclaimed offline policy for the "link an existing policy" demo flow
-- (policy number TG-OFFLINE-7734, date of birth 1990-05-12)
INSERT INTO policies (id, policy_number, user_id, package_id, status, source, start_date, end_date, total_premium, amount_paid, date_of_birth_on_record, created_at) VALUES
('b0000000-0000-0000-0000-000000000005', 'TG-OFFLINE-7734', NULL, 'a0000000-0000-0000-0000-000000000008',
 'PENDING', 'LINKED_EXISTING', CURRENT_DATE - INTERVAL '6 months', CURRENT_DATE + INTERVAL '6 months', 660.00, 330.00, DATE '1990-05-12', now());

-- Payments
INSERT INTO payments (id, policy_id, invoice_number, amount, due_date, paid_date, status, method, transaction_ref, created_at) VALUES
('c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'INV-2024-100001', 89.00,
 CURRENT_DATE - INTERVAL '2 months', CURRENT_DATE - INTERVAL '2 months', 'PAID', 'CARD', 'SEED-0001', now()),
('c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'INV-2024-100002', 89.00,
 CURRENT_DATE - INTERVAL '1 months', CURRENT_DATE - INTERVAL '1 months', 'PAID', 'CARD', 'SEED-0002', now()),
('c0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001', 'INV-2024-100003', 89.00,
 CURRENT_DATE + INTERVAL '12 days', NULL, 'PENDING', NULL, NULL, now()),
('c0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000002', 'INV-2024-200001', 72.00,
 CURRENT_DATE - INTERVAL '1 months', CURRENT_DATE - INTERVAL '1 months', 'PAID', 'E_WALLET', 'SEED-0003', now()),
('c0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000002', 'INV-2024-200002', 72.00,
 CURRENT_DATE - INTERVAL '9 days', NULL, 'OVERDUE', NULL, NULL, now()),
('c0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000003', 'INV-2023-300001', 32.00,
 CURRENT_DATE - INTERVAL '1 months', CURRENT_DATE - INTERVAL '1 months', 'PAID', 'BANK_TRANSFER', 'SEED-0004', now()),
('c0000000-0000-0000-0000-000000000007', 'b0000000-0000-0000-0000-000000000003', 'INV-2023-300002', 32.00,
 CURRENT_DATE + INTERVAL '16 days', NULL, 'PENDING', NULL, NULL, now()),
('c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000004', 'INV-2022-400001', 18.00,
 CURRENT_DATE - INTERVAL '13 months', CURRENT_DATE - INTERVAL '13 months', 'PAID', 'CARD', 'SEED-0005', now());

-- Notifications
INSERT INTO notifications (id, user_id, type, title, body, is_read, created_at) VALUES
('d0000000-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 'PAYMENT', 'Payment overdue',
 'Your AutoGuard Comprehensive payment of $72 is 9 days overdue. Pay now to avoid a lapse in cover.', false, now() - INTERVAL '1 day'),
('d0000000-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'POLICY', 'Your Home policy has expired',
 'HomeSafe Renters expired. Renew or browse a new home plan to stay protected.', false, now() - INTERVAL '3 days'),
('d0000000-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', 'PAYMENT', 'Payment received',
 'We received your $89 payment for Health Shield Premium. Thank you!', true, now() - INTERVAL '30 days'),
('d0000000-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', 'PROMO', 'New: Travel Annual Multi-Trip',
 'Unlimited trips under one annual plan, now 10% off for your first year.', true, now() - INTERVAL '6 days'),
('d0000000-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', 'SYSTEM', 'Identity verified',
 'Your KYC verification is complete. You now have full access to claims and support.', true, now() - INTERVAL '400 days');

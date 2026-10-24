UPDATE insurance_packages
SET description = 'Our most complete health plan -- specialist visits, dental and vision, and maternity care. Illness cover starts after a 30-day waiting period; accidents are covered from day one.'
WHERE id = 'a0000000-0000-0000-0000-000000000002';

UPDATE package_benefits
SET benefit = 'Accident cover from day one'
WHERE package_id = 'a0000000-0000-0000-0000-000000000002'
  AND benefit = 'No waiting period';

UPDATE insurance_packages
SET claim_policy = replace(
    claim_policy,
    'Tell us about the incident within 30 days and submit all documents within 90 days.',
    'Tell us about the incident as soon as possible and file the claim within 90 days.'
)
WHERE category = 'HEALTH';

ALTER TABLE insurance_packages ADD COLUMN waiting_period_days INT NOT NULL DEFAULT 30;
ALTER TABLE insurance_packages ADD COLUMN claim_window_days INT NOT NULL DEFAULT 90;
ALTER TABLE insurance_packages ADD COLUMN claim_policy VARCHAR(3000);
ALTER TABLE insurance_packages ADD COLUMN claim_documents VARCHAR(2000);
ALTER TABLE insurance_packages ADD COLUMN exclusions VARCHAR(2000);
ALTER TABLE insurance_packages ADD COLUMN legal_terms VARCHAR(5000);

ALTER TABLE claims ADD COLUMN reviewed_at TIMESTAMP WITH TIME ZONE;

UPDATE insurance_packages SET
  waiting_period_days = 30,
  claim_window_days = 90,
  claim_policy = 'Health claims are assessed against the schedule of benefits in your policy. Tell us about the incident within 30 days and submit all documents within 90 days. Illness claims carry a 30-day waiting period from the policy start date; accidental injury claims can be filed from day one. Reimbursement covers eligible, medically necessary treatment and is paid after any deductible, co-payment or limit shown on your policy schedule.',
  claim_documents = 'Completed claim form|Hospital or clinic invoices and receipts|Medical report, discharge summary or doctor''s note|Prescription or treatment plan|Photo ID and policy certificate',
  exclusions = 'Pre-existing conditions during the waiting period|Cosmetic or elective procedures|Experimental or unproven treatment|Self-inflicted injury or injury during illegal activity|Treatment not prescribed by a licensed provider|Treatment covered by another insurer',
  legal_terms = 'Cover begins on the policy start date and only after the first premium is paid. Premiums must be kept up to date: cover is suspended while any installment is overdue and claims cannot be filed until the account is current. This is a contract of reimbursement, not a guarantee of payment. Benefits, limits, waiting periods and exclusions apply. You must give true and complete information; fraud or material misrepresentation may void the policy and any related claim. We may ask for additional evidence and, where permitted, recover paid amounts from third parties responsible for the loss. Personal data is processed only to administer the policy and the claim. Complaints should be raised with TrustGuard support before pursuing any statutory remedy. This is demonstration wording, not legal advice, and does not override the law of your country of residence.'
WHERE category = 'HEALTH';

UPDATE insurance_packages SET
  waiting_period_days = 90,
  claim_window_days = 180,
  claim_policy = 'A life claim can be filed by the nominated beneficiary or legal representative. Notify TrustGuard as soon as reasonably possible and submit the required documents within 180 days of death. Non-accidental death is covered after a 90-day waiting period from the policy start date; accidental death is covered from day one. The benefit payable is the sum insured on your policy schedule less any outstanding premium.',
  claim_documents = 'Claim notification form|Certified death certificate|Policy certificate|Beneficiary photo ID and proof of relationship|Medical records and treating doctor''s report|Police or accident report, where applicable',
  exclusions = 'Death by suicide within 12 months of cover starting|Death from an undisclosed pre-existing condition|War, riot or terrorism|Injury while committing an illegal act|Death while under the influence of alcohol or drugs',
  legal_terms = 'Cover begins on the policy start date and only after the first premium is paid. Cover remains conditional on premiums being current; an overdue installment suspends the policy until paid. The sum insured, benefit limits, waiting periods and exclusions in your policy schedule form part of this contract. All information on the application must be true and complete; non-disclosure or misrepresentation may void the policy and any claim. We may request medical or official records and may investigate a claim. Benefits are paid to the nominated beneficiary or the estate once the claim is approved. Personal data is processed only to administer the policy and the claim. Complaints should be raised with TrustGuard support before pursuing any statutory remedy. This is demonstration wording, not legal advice.'
WHERE category = 'LIFE';

UPDATE insurance_packages SET
  waiting_period_days = 14,
  claim_window_days = 30,
  claim_policy = 'Report every incident to TrustGuard and, where required by law, to the police within 24 hours. Submit the required documents within 30 days. Cover starts after a 14-day waiting period and only while the policy is active and premiums are current. Repairs must be approved before work begins. We may inspect the vehicle and ask you to use an approved repairer. Payout is limited to the insured value and reduced by any excess, depreciation and salvage value.',
  claim_documents = 'Police or incident report|Photos of the damage|Repair estimate from an approved garage|Driver''s licence and vehicle registration|Policy certificate|Third-party details, if another vehicle was involved',
  exclusions = 'Driving without a valid licence|Driving under the influence of alcohol or drugs|Wear and tear or mechanical breakdown|Racing, rallies or commercial use not declared|Damage from an intentional act|Theft where the vehicle was left unlocked or unsecured',
  legal_terms = 'Cover begins on the policy start date and only after the first premium is paid. Cover is suspended while any installment is overdue and claims cannot be filed until the account is current. The insured value, excess, limits, waiting periods and exclusions in your policy schedule form part of this contract. You must give true and complete information and tell us about any change that affects the risk. Fraud or material misrepresentation may void the policy and any claim. We may inspect the vehicle, appoint an assessor and, where permitted, recover paid amounts from a responsible third party. Personal data is processed only to administer the policy and the claim. Complaints should be raised with TrustGuard support before pursuing any statutory remedy. This is demonstration wording, not legal advice.'
WHERE category = 'VEHICLE';

UPDATE insurance_packages SET
  waiting_period_days = 14,
  claim_window_days = 30,
  claim_policy = 'Report loss or damage as soon as possible and within 30 days. Cover applies during the policy period while premiums are paid and after a 14-day waiting period from the cover start date. We may inspect the property and ask for proof of ownership or a valuation. Payment is limited to the sum insured for the relevant section and reduced by any excess. Emergency repairs needed to prevent further damage should be photographed and documented before work is done.',
  claim_documents = 'Photos or video of the damage|Police or fire service report|Inventory of damaged or stolen items|Receipts, valuations or proof of ownership|Repair or replacement estimate',
  exclusions = 'Normal wear and tear or gradual deterioration|Pest infestation or mould, unless caused by an insured event|Intentional damage by the policyholder|Property left unoccupied for more than 30 consecutive days|High-value items not declared or listed|Loss caused by illegal activity',
  legal_terms = 'Cover begins on the policy start date and only after the first premium is paid. Cover is suspended while any installment is overdue and claims cannot be filed until the account is current. The sum insured, section limits, excess, waiting periods and exclusions in your policy schedule form part of this contract. You must give true and complete information about the property and any change that affects the risk. Fraud or material misrepresentation may void the policy and any claim. We may inspect the property, appoint a loss adjuster and, where permitted, recover paid amounts from a responsible third party. Personal data is processed only to administer the policy and the claim. Complaints should be raised with TrustGuard support before pursuing any statutory remedy. This is demonstration wording, not legal advice.'
WHERE category = 'HOME';

UPDATE insurance_packages SET
  waiting_period_days = 0,
  claim_window_days = 30,
  claim_policy = 'Travel claims must be filed within 30 days of the event or the end of the trip, whichever is later. Cover begins on the policy start date once the premium is paid and applies to the trips and travellers listed on the policy. Keep all receipts, tickets and reports. Non-emergency medical treatment must be arranged by a licensed provider; where possible, contact the 24/7 assistance line before treatment. Benefits are paid up to the limits on the policy schedule and exclude costs recoverable from another insurer or a carrier.',
  claim_documents = 'Booking confirmation, tickets and itinerary|Invoices and receipts for the loss|Medical report and hospital bills, if applicable|Carrier delay, cancellation or baggage report|Police report for theft or loss|Photo ID and policy certificate',
  exclusions = 'Pre-existing medical conditions|Adventure or extreme sports not listed on the policy|Travel against medical advice|Loss of valuables left unattended|Loss caused by alcohol, drugs or illegal activity|Costs recoverable from an airline, hotel or another insurer',
  legal_terms = 'Cover begins on the policy start date and only after the first premium is paid. It applies only to the travellers, destinations and dates named on the policy. Limits, excess, waiting periods and exclusions in your policy schedule form part of this contract. You must tell us about any change to your trip or health that affects the risk. Fraud or material misrepresentation may void the policy and any claim. We may ask for additional evidence and, where permitted, recover paid amounts from a carrier or another responsible party. Personal data is processed only to administer the policy and the claim. Complaints should be raised with TrustGuard support before pursuing any statutory remedy. This is demonstration wording, not legal advice.'
WHERE category = 'TRAVEL';

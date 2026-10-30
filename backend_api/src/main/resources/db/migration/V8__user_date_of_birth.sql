-- Insurance requires an adult policyholder. Nullable so accounts created
-- before this rule keep working; registration now always supplies it.
ALTER TABLE users ADD COLUMN date_of_birth DATE;

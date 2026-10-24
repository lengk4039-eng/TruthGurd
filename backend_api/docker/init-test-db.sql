-- Runs once when the Postgres container is first created. Gives the test
-- suite (see AbstractIntegrationTest) its own database on the same server,
-- separate from the "trustguard" one the app uses for local development, so
-- tests never see data left over from manual poking around in dev.
CREATE DATABASE trustguard_test;

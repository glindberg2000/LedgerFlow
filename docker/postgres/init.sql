CREATE USER ledgerflow WITH PASSWORD 'ledgerflow';
CREATE DATABASE ledgerflow;
GRANT ALL PRIVILEGES ON DATABASE ledgerflow TO ledgerflow;
\c ledgerflow
ALTER SCHEMA public OWNER TO ledgerflow; 
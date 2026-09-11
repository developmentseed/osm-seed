# OSM Replication Job Container

This container is responsible for creating OSM delta replication files using [osmdbt](https://github.com/openstreetmap/osmdbt) tools. It generates replication files every minute and uploads them to S3 with integrity verification.

## What it does

The container runs a continuous replication process that:

1. **Executes replication cycle every minute**:
   - Runs `osmdbt-get-log` to fetch changes from PostgreSQL logical replication
   - Runs `osmdbt-create-diff` to generate `.osc.gz` files and `state.txt` files

2. **Uploads files to S3**:
   - Uploads `.osc.gz` files (e.g., `870.osc.gz`)
   - Uploads general `state.txt` (controls replication sequence)
   - Uploads specific `state.txt` files (e.g., `870.state.txt` for `870.osc.gz`)
   - All files are verified for integrity before upload

3. **Manages replication state**:
   - Uses local `state.txt` to control replication sequence
   - Recovers `state.txt` from S3 on container restart
   - Continues from the last known sequence automatically

4. **Error handling and monitoring**:
   - Verifies file integrity (gzip test, size checks)
   - Sends Slack notifications for errors and corruption
   - Automatically cleans up incomplete/orphaned files (`.lock`, `.log`, corrupted files)
   - Removes orphaned state files without matching `.osc.gz` files

5. **Self-healing**:
   - Detects and removes corrupted files
   - Regenerates files if corruption is detected
   - Maintains sequence continuity

## Technology Stack

- **osmdbt v0.9**: OSM Database Replication Tools from OpenStreetMap
- **Base Image**: Debian Bookworm (for library version consistency)
- **PostgreSQL**: Uses logical replication slot for change tracking
- **AWS S3**: For storing replication files
- **Slack**: Optional notifications for errors

## Configuration

### Required Environment Variables

The container requires environment variables from these files:

- [.env.db.example](../../envs/.env.db.example) - Database connection
- [.env.db-utils.example](../../envs/.env.db-utils.example) - Database utilities
- [.env.cloudprovider.example](../../envs/.env.cloudprovider.example) - Cloud storage configuration

**Note**: Rename the above files as `.env.db`, `.env.db-utils` and `.env.cloudprovider`

### Key Environment Variables

#### Database Configuration
- `POSTGRES_HOST` - PostgreSQL hostname
- `POSTGRES_PORT` - PostgreSQL port (default: 5432)
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user (must have replication and SELECT permissions)
- `POSTGRES_PASSWORD` - Database password
- `REPLICATION_SLOT` - Logical replication slot name (default: `osm_repl`)

**Important**: The database user must have the following permissions:
- `REPLICATION` privilege (to read from logical replication slot)
- `SELECT` permission on the `changesets` table (required by `osmdbt-create-diff`)

To grant these permissions, run as a database administrator:
```sql
-- Create user with replication privilege
CREATE ROLE osmdbt_user WITH REPLICATION LOGIN PASSWORD 'your_password';

-- Grant SELECT on changesets table
GRANT SELECT ON TABLE changesets TO osmdbt_user;
```

#### S3 Configuration
- `CLOUDPROVIDER` - Cloud provider (default: `aws`)
- `AWS_S3_BUCKET` - S3 bucket name for replication files
- `REPLICATION_FOLDER` - Folder path in S3 bucket (default: `replication`)

#### Slack Notifications (Optional)
- `ENABLE_SEND_SLACK_MESSAGE` - Enable Slack notifications (default: `false`)
- `SLACK_WEBHOOK_URL` - Slack webhook URL for notifications
- `ENVIRONMENT` - Environment name for notifications (e.g., `production`, `staging`)

#### Working Directory
- `WORKING_DIRECTORY` - Working directory path (default: `/mnt/data`)

## Running the Container

### Using Docker Compose

```sh
docker-compose run replication-job
```

### Using Docker

```sh
docker run \
  --env-file ./envs/.env.db \
  --env-file ./envs/.env.replication-job \
  --env-file ./envs/.env.cloudprovider \
  -v ${PWD}/data/replication-job-data:/mnt/data \
  --network osm-seed_default \
  -it osmseed-replication-job:v1
```

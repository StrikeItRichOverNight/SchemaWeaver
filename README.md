# SchemaWeaver
Simplifies the process of migrating database schemas between different databases like Oracle, PostgreSQL... / Oracle、PostgreSQL などの異なるデータベース間でのデータベーススキーマ移行プロセスを簡素化します。


# How to install Oracle

## Using Oracle 23ai Free (Express Edition)

### 1. Pull the Oracle 23ai Free Image

```bash
docker pull container-registry.oracle.com/database/free:latest
```

This gets the latest Oracle Database 23ai Free edition.

### 2. Run Oracle 23ai Container

```bash
docker run -d \
  --name oracle23ai \
  -p 1521:1521 \
  -p 5500:5500 \
  -e ORACLE_PWD=YourPassword123 \
  -e ORACLE_CHARACTERSET=AL32UTF8 \
  -v oracle23ai-data:/opt/oracle/oradata \
  container-registry.oracle.com/database/free:latest
```

### 3. If You Have an Existing Container

If you already have an Oracle XE container running, you'll need to:

**Stop and remove the old container:**
```bash
docker stop oracle-xe
docker rm oracle-xe
```

**If you want to keep your old data**, backup first:
```bash
# Export your data before removing
docker exec oracle-xe expdp system/YourPassword123 directory=DATA_PUMP_DIR dumpfile=backup.dmp full=y
```

### 4. Monitor the Startup

```bash
docker logs -f oracle23ai
```

Wait for: `DATABASE IS READY TO USE!`

### 5. Connect to Oracle 23ai

```bash
docker exec -it oracle23ai sqlplus sys/YourPassword123@FREE as sysdba
```

**Connection details:**
- **Service Name:** FREE (not XE)
- **Port:** 1521
- **Username:** system or sys
- **Password:** Your ORACLE_PWD value

## Docker Compose for Oracle 23ai

Update your `docker-compose.yml`:

```yaml
version: '3.8'
services:
  oracle23ai:
    image: container-registry.oracle.com/database/free:latest
    container_name: oracle23ai
    ports:
      - "1521:1521"
      - "5500:5500"
    environment:
      - ORACLE_PWD=YourPassword123
      - ORACLE_CHARACTERSET=AL32UTF8
    volumes:
      - oracle23ai-data:/opt/oracle/oradata
    restart: unless-stopped

volumes:
  oracle23ai-data:
```

Then run:
```bash
docker-compose up -d
```

## Key Differences in 23ai

Oracle 23ai includes new features:
- **JSON Relational Duality** - Work with data as JSON or relational tables
- **SQL Domains** - Define reusable data validation rules
- **Table Value Constructors** - Enhanced INSERT syntax
- **Boolean data type** - Native boolean support
- **AI Vector Search** - Built-in vector similarity search

## Migrating Data from Old Container

If you need to migrate data from an older Oracle version:

1. **Export from old container:**
```bash
docker exec oracle-xe expdp system/password directory=DATA_PUMP_DIR dumpfile=mydata.dmp full=y
docker cp oracle-xe:/opt/oracle/admin/XE/dpdump/mydata.dmp ./mydata.dmp
```

2. **Import to 23ai:**
```bash
docker cp ./mydata.dmp oracle23ai:/opt/oracle/admin/FREE/dpdump/
docker exec oracle23ai impdp system/password directory=DATA_PUMP_DIR dumpfile=mydata.dmp full=y
```

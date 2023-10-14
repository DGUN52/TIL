- 아래의 sql로 기본세팅
```sql
show variables like 'general%';
show variables like 'log_output';
show variables like 'general_log_file';
SET GLOBAL general_log='ON';
set global log_output = 'file'; -- default
set global general_log_file='log/logging.log';
```

- 경로의 홈은 `C:\ProgramData\MySQL\MySQL Server 8.0\Data`

# Untropy-BE
backend server for untropy project


# procedure.sh
the bash script that runs the checks

# mongodb
the backup for the mongodb data

# untropy-be
the express backend server

Checks:
http://localhost:3000/checks [GET]
http://localhost:3000/checks/<Position> [GET]

Servers
http://localhost:3000/servers [GET]
http://localhost:3000/servers/<Server ID> [GET]
http://localhost:3000/servers [PUT] (add params in the 'x-www-form-urlencoded' body {name:test, ip:10.0.0.1, checks:1111111111111111111111111111111111111111111111111"})
http://localhost:3000/servers/<Server ID> [DELETE]

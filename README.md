# Untropy-BE
backend server for untropy project


### procedure.sh
the bash script that runs the checks

### mongodb
the backup for the mongodb data

### untropy-be
the express backend server
<br><br><br>
### Rest API
* Checks:<br>
```
http://localhost:3000/checks [GET]
```
```

http://localhost:3000/checks/<Position> [GET]
```

* Servers:<br>
```
http://localhost:3000/servers [GET] 
```

```
http://localhost:3000/servers/<Server ID> [GET] 
```

```
http://localhost:3000/servers [POST] 
```

*(add params in the 'x-www-form-urlencoded' body {name:test, ip:10.0.0.1, checks:1111111111111111111111111111111111111111111111111"}) <br>*
```
http://localhost:3000/servers/<Server ID> [DELETE]
```

```
http://localhost:3000/servers/<Server ID> [PUT]
```
* Queries: <br>

First parameter - the health status of the server<br>
Second parameters - the maximum number of minutes passed from the last check
```
http://localhost:3000/servers/<STATUS>/<MINUTES> [GET]
```

Group servers by health status
```
http://localhost:3000/servers/health [GET]
```

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
http://localhost:3000/checks [GET]<br>
```
```

http://localhost:3000/checks/<Position> [GET]<br>
```

* Servers:<br>
```
http://localhost:3000/servers [GET] <br>
```

```
http://localhost:3000/servers/<Server ID> [GET] <br>
```

```
http://localhost:3000/servers [PUT] <br>
```

*(add params in the 'x-www-form-urlencoded' body {name:test, ip:10.0.0.1, checks:1111111111111111111111111111111111111111111111111"}) <br>*
```
http://localhost:3000/servers/<Server ID> [DELETE] <br>
```


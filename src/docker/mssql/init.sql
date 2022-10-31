if (DB_ID('foodtrucks') is null)
begin
    CREATE DATABASE [foodtrucks]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'foodtrucks', FILENAME = N'/var/opt/mssql/data/foodtrucks.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'foodtrucks_log', FILENAME = N'/var/opt/mssql/data/foodtrucks_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )

end
CREATE DATABASE [proy3];
USE [proy3];

/*BORRA LOGIN SI EXISTE*/
IF EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'gabriel_login' )
BEGIN
    DROP LOGIN [gabriel_login]; 
END

/*CREA LOGIN SI NO EXISTE*/
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'gabriel_login' )
BEGIN
    CREATE LOGIN [gabriel_login] WITH PASSWORD = '123' MUST_CHANGE, CHECK_EXPIRATION = ON,
	DEFAULT_DATABASE=[proy3], DEFAULT_LANGUAGE=[us_english]; 
END

/*CREA ESQUEMA SI NO EXISTE*/
IF NOT EXISTS (SELECT schema_name 
    FROM information_schema.schemata 
    WHERE schema_name = 'PROYECTO' )
BEGIN
    EXEC sp_executesql N'CREATE SCHEMA PROYECTO;';
END

/*VERIFICAR SI SE CREÓ EL LOGIN*/
SELECT * FROM sys.sql_logins WHERE name = 'gabriel_login';


/*BORRAR USUARIO*/
/* DROP USER gabriel_user; */

/*CREA ESQUEMA SI NO EXISTE*/
IF USER_ID('gabriel_login') IS NULL
BEGIN
    CREATE USER gabriel_user FOR LOGIN gabriel_login;
END
    
ALTER USER gabriel_user WITH DEFAULT_SCHEMA = [PROYECTO];

/*LISTADO DE PERMISOS*/   
/* SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name; */

/*CREA UN ROL DE USUARIO*/
CREATE ROLE gabriel_rol AUTHORIZATION gabriel_user; 

/* ASIGNARLE UN ROL AL LOGIN */
/*sp_dropsrvrolemember  'gabriel_login','bulkadmin';*/
GO
sp_addsrvrolemember 'gabriel_login','sysadmin';
GO

ALTER AUTHORIZATION ON SCHEMA::[PROYECTO] TO [gabriel_user]

GO
EXEC sp_addrolemember N'gabriel_rol', N'gabriel_user'
GO

USE [proy3]
GO
EXEC sp_droprolemember N'db_accessadmin', N'gabriel_user'

/*********/

/*Crear una clave*/  
USE proy3; 
GO 
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'w1N'; 
GO 

/*Crear certificado */
USE proy3; 
GO 
	CREATE CERTIFICATE Certificado WITH SUBJECT = 'Proteccion Datos'; 
GO 

/*Y ahora se crea la clave simetrica */
USE proy3; 
GO 
	CREATE SYMMETRIC KEY Clave1 WITH ALGORITHM = AES_128 ENCRYPTION BY CERTIFICATE Certificado; 
GO 

USE proy3; 
GO 
	SELECT * FROM sys.symmetric_keys WHERE name = 'Clave1'; 
GO 
GO
USE [OLDB89694];
GO
-- -----------------------------------------------------
-- Table tblclient
-- -----------------------------------------------------
CREATE TABLE [PROYECTO].[tblclient](
  [tblclientid] INT NOT NULL IDENTITY,
  [tblclientusername] VARBINARY(MAX) NOT NULL,
  [tblclientpassword] VARBINARY(MAX) NOT NULL,
  [tblclientcreate] DATETIME NOT NULL,
  [tblclientmigrate] TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY ([tblclientid]));
  
-- -----------------------------------------------------
-- Table tblphone
-- -----------------------------------------------------  
CREATE TABLE [PROYECTO].[tblphone](
  [tblphoneid] INT NOT NULL IDENTITY,
  [tblphoneclientid] INT NOT NULL,
  [tblphonenumber] VARBINARY(MAX) NOT NULL,
  [tblphonecreate] DATETIME NOT NULL,
  [tblphonemigrate] TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY ([tblphoneid]),
  CONSTRAINT [fk_1] 
		FOREIGN KEY ([tblphoneclientid]) 
		REFERENCES [PROYECTO].[tblclient] ([tblclientid])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table tbladdress
-- -----------------------------------------------------  
CREATE TABLE [PROYECTO].[tbladdress](
  [tbladdressid] INT NOT NULL IDENTITY,
  [tbladdressclientid] INT NOT NULL,
  [tbladdressdetail] VARBINARY(MAX) NOT NULL,
  [tbladdresscreate] DATETIME NOT NULL,
  [tbladdressmigrate] TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY ([tbladdressid]),
  CONSTRAINT [fk_2] 
		FOREIGN KEY ([tbladdressclientid]) 
		REFERENCES [PROYECTO].[tblclient] ([tblclientid])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table tblemail
-- -----------------------------------------------------  
CREATE TABLE [PROYECTO].[tblemail](
  [tblemailid] INT NOT NULL IDENTITY,
  [tblemailclientid] INT NOT NULL,
  [tblemaildetail] VARBINARY(MAX) NOT NULL,
  [tblemailcreate] DATETIME NOT NULL,
  [tblemailmigrate] TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY ([tblemailid]),
  CONSTRAINT [fk_3] 
		FOREIGN KEY ([tblemailclientid]) 
		REFERENCES [PROYECTO].[tblclient] ([tblclientid])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION);
 
-- -----------------------------------------------------
-- Table tblcreditcard
-- -----------------------------------------------------   
CREATE TABLE [PROYECTO].[tblcreditcard](
  [tblcreditcardid] INT NOT NULL IDENTITY,
  [tblcreditcardclientid] INT NOT NULL,
  [tblcreditcarddetail] VARBINARY(MAX) NOT NULL,
  [tblcreditcardcreate] DATETIME NOT NULL,
  [tblcreditcardmigrate] TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY ([tblcreditcardid]),
  CONSTRAINT [fk_4] 
		FOREIGN KEY ([tblcreditcardclientid]) 
		REFERENCES [PROYECTO].[tblclient] ([tblclientid])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table tblproduct
-- -----------------------------------------------------    
CREATE TABLE [PROYECTO].[tblproduct](
  [tblproductid] INT NOT NULL IDENTITY,
  [tblproductname] VARCHAR(50) NOT NULL,
  [tblproductprice] DECIMAL(10,2) NOT NULL,
  [tblproductcreate] DATETIME NOT NULL,
  [tblproductmigrate] TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY ([tblproductid]));
  
-- -----------------------------------------------------
-- Table tblorder
-- -----------------------------------------------------  
CREATE TABLE [PROYECTO].[tblorder](
  [tblorderid] INT NOT NULL IDENTITY,
  [tblorderidproduct] INT NOT NULL,
  [tblorderidclient] INT NOT NULL,
  [tblordermount] DECIMAL(10,2) NOT NULL,
  [tblordercreate] DATETIME NOT NULL,
  [tblordermigrate] TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY ([tblorderid]),
  CONSTRAINT [fk_5] 
		FOREIGN KEY ([tblorderidproduct]) 
		REFERENCES [PROYECTO].[tblproduct] ([tblproductid])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
  CONSTRAINT [fk_6] 
		FOREIGN KEY ([tblorderidclient]) 
		REFERENCES [PROYECTO].[tblclient] ([tblclientid])
		ON DELETE NO ACTION
		ON UPDATE NO ACTION);
/*****************/
-- Desencriptar los datos  
USE proy3; 
GO 
OPEN SYMMETRIC KEY Clave1 DECRYPTION BY CERTIFICATE Certificado; 
GO 
-- Leer los datos 
SELECT TOP 1000 [tblclientid]
      ,[tblclientusername]
      ,CONVERT(varchar, DecryptByKey([tblclientpassword]))
      ,[tblclientmigrate]
  FROM [proy3].[PROYECTO].[tblclient]
   
-- Close the symmetric key 
CLOSE SYMMETRIC KEY Clave1; 
GO 
/*********************/
USE proy3;
GO 
-- Abrir la clave Clave1 
OPEN SYMMETRIC KEY Clave1 DECRYPTION BY CERTIFICATE Certificado; 
GO 

	INSERT INTO [proy3].[PROYECTO].[tblclient]([tblclientusername],[tblclientpassword],[tblclientmigrate])
	VALUES (EncryptByKey(Key_GUID('Clave1'),'gabriel'), EncryptByKey(Key_GUID('Clave1'),'12345'),0);      
GO
-- Cerrar la clave 
CLOSE SYMMETRIC KEY Clave1; 
GO 
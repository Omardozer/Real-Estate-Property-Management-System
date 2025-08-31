IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE TABLE [properties] (
    [PropertyID] int NOT NULL IDENTITY,
    [Address] varchar(max) NOT NULL,
    [Owner] varchar(max) NOT NULL,
    [Type] varchar(max) NOT NULL,
    [Status] varchar(max) NOT NULL,
    CONSTRAINT [PK_properties] PRIMARY KEY ([PropertyID])
);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241018170206_first migrate', N'9.0.8');

ALTER TABLE [properties] DROP CONSTRAINT [PK_properties];

EXEC sp_rename N'[properties]', N'Property', 'OBJECT';

ALTER TABLE [Property] ADD CONSTRAINT [PK_Property] PRIMARY KEY ([PropertyID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241018170854_Add Tenant', N'9.0.8');

ALTER TABLE [Property] DROP CONSTRAINT [PK_Property];

EXEC sp_rename N'[Property]', N'properties', 'OBJECT';

ALTER TABLE [properties] ADD CONSTRAINT [PK_properties] PRIMARY KEY ([PropertyID]);

CREATE TABLE [tenants] (
    [TenantID] int NOT NULL IDENTITY,
    [Name] varchar(max) NOT NULL,
    [ContactInformation] varchar(max) NOT NULL,
    [PropertyID] int NOT NULL,
    CONSTRAINT [PK_tenants] PRIMARY KEY ([TenantID]),
    CONSTRAINT [FK_tenants_properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [properties] ([PropertyID]) ON DELETE CASCADE
);

CREATE INDEX [IX_tenants_PropertyID] ON [tenants] ([PropertyID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241018171624_fix db', N'9.0.8');

CREATE TABLE [leases] (
    [LeaseID] int NOT NULL IDENTITY,
    [PropertyID] int NOT NULL,
    [StartDate] datetime2 NOT NULL,
    [EndDate] datetime2 NOT NULL,
    [Terms] varchar(max) NOT NULL,
    [TenantID] int NULL,
    CONSTRAINT [PK_leases] PRIMARY KEY ([LeaseID]),
    CONSTRAINT [FK_leases_properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [properties] ([PropertyID]) ON DELETE CASCADE,
    CONSTRAINT [FK_leases_tenants_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [tenants] ([TenantID])
);

CREATE INDEX [IX_leases_PropertyID] ON [leases] ([PropertyID]);

CREATE INDEX [IX_leases_TenantID] ON [leases] ([TenantID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241018172440_add Leases', N'9.0.8');

ALTER TABLE [leases] DROP CONSTRAINT [FK_leases_tenants_TenantID];

DROP INDEX [IX_leases_TenantID] ON [leases];
DECLARE @var sysname;
SELECT @var = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[leases]') AND [c].[name] = N'TenantID');
IF @var IS NOT NULL EXEC(N'ALTER TABLE [leases] DROP CONSTRAINT [' + @var + '];');
UPDATE [leases] SET [TenantID] = 0 WHERE [TenantID] IS NULL;
ALTER TABLE [leases] ALTER COLUMN [TenantID] int NOT NULL;
ALTER TABLE [leases] ADD DEFAULT 0 FOR [TenantID];
CREATE INDEX [IX_leases_TenantID] ON [leases] ([TenantID]);

ALTER TABLE [leases] ADD CONSTRAINT [FK_leases_tenants_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [tenants] ([TenantID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241018180757_test conflict', N'9.0.8');

CREATE TABLE [issues] (
    [IssueID] int NOT NULL IDENTITY,
    [TenantID] int NOT NULL,
    [Description] varchar(max) NOT NULL,
    [DateReported] datetime2 NOT NULL,
    [Status] varchar(max) NOT NULL,
    CONSTRAINT [PK_issues] PRIMARY KEY ([IssueID]),
    CONSTRAINT [FK_issues_tenants_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [tenants] ([TenantID]) ON DELETE CASCADE
);

CREATE TABLE [payments] (
    [PaymentID] int NOT NULL IDENTITY,
    [TenantID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Date] datetime2 NOT NULL,
    [Status] varchar(max) NOT NULL,
    CONSTRAINT [PK_payments] PRIMARY KEY ([PaymentID]),
    CONSTRAINT [FK_payments_tenants_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [tenants] ([TenantID]) ON DELETE CASCADE
);

CREATE TABLE [users] (
    [UserID] int NOT NULL IDENTITY,
    [Username] varchar(max) NOT NULL,
    [Password] varchar(max) NOT NULL,
    [Role] varchar(max) NOT NULL,
    CONSTRAINT [PK_users] PRIMARY KEY ([UserID])
);

CREATE INDEX [IX_issues_TenantID] ON [issues] ([TenantID]);

CREATE INDEX [IX_payments_TenantID] ON [payments] ([TenantID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241018184026_insert useless Tabels', N'9.0.8');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241018184539_update Tenant', N'9.0.8');

ALTER TABLE [properties] ADD [CreatedDate] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';

ALTER TABLE [properties] ADD [Description] varchar(max) NOT NULL DEFAULT '';

ALTER TABLE [properties] ADD [PricePerDay] decimal(18,2) NOT NULL DEFAULT 0.0;

ALTER TABLE [leases] ADD [CreatedDate] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';

CREATE TABLE [PropertyImage] (
    [ImageID] int NOT NULL IDENTITY,
    [ImagePath] varchar(max) NOT NULL,
    [PropertyID] int NOT NULL,
    CONSTRAINT [PK_PropertyImage] PRIMARY KEY ([ImageID]),
    CONSTRAINT [FK_PropertyImage_properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [properties] ([PropertyID]) ON DELETE CASCADE
);

CREATE INDEX [IX_PropertyImage_PropertyID] ON [PropertyImage] ([PropertyID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241022005910_some_edits', N'9.0.8');

ALTER TABLE [PropertyImage] DROP CONSTRAINT [FK_PropertyImage_properties_PropertyID];

ALTER TABLE [PropertyImage] DROP CONSTRAINT [PK_PropertyImage];

EXEC sp_rename N'[PropertyImage]', N'PropertyImages', 'OBJECT';

EXEC sp_rename N'[PropertyImages].[IX_PropertyImage_PropertyID]', N'IX_PropertyImages_PropertyID', 'INDEX';

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'Status');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [properties] ALTER COLUMN [Status] varchar(max) NULL;

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'Description');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [properties] ALTER COLUMN [Description] varchar(max) NULL;

DECLARE @var3 sysname;
SELECT @var3 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'CreatedDate');
IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var3 + '];');
ALTER TABLE [properties] ALTER COLUMN [CreatedDate] datetime2 NULL;

ALTER TABLE [PropertyImages] ADD CONSTRAINT [PK_PropertyImages] PRIMARY KEY ([ImageID]);

ALTER TABLE [PropertyImages] ADD CONSTRAINT [FK_PropertyImages_properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [properties] ([PropertyID]) ON DELETE CASCADE;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241022020429_some_edits2', N'9.0.8');

ALTER TABLE [PropertyImages] DROP CONSTRAINT [FK_PropertyImages_properties_PropertyID];

ALTER TABLE [PropertyImages] DROP CONSTRAINT [PK_PropertyImages];

EXEC sp_rename N'[PropertyImages]', N'PropertiesImages', 'OBJECT';

EXEC sp_rename N'[PropertiesImages].[IX_PropertyImages_PropertyID]', N'IX_PropertiesImages_PropertyID', 'INDEX';

ALTER TABLE [PropertiesImages] ADD CONSTRAINT [PK_PropertiesImages] PRIMARY KEY ([ImageID]);

ALTER TABLE [PropertiesImages] ADD CONSTRAINT [FK_PropertiesImages_properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [properties] ([PropertyID]) ON DELETE CASCADE;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241022022108_AddPropertyImageTable', N'9.0.8');

DECLARE @var4 sysname;
SELECT @var4 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'Status');
IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var4 + '];');
ALTER TABLE [properties] DROP COLUMN [Status];

EXEC sp_rename N'[tenants].[ContactInformation]', N'PhoneNumber', 'COLUMN';

DECLARE @var5 sysname;
SELECT @var5 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[tenants]') AND [c].[name] = N'Name');
IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [tenants] DROP CONSTRAINT [' + @var5 + '];');
ALTER TABLE [tenants] ALTER COLUMN [Name] varchar(100) NOT NULL;

DECLARE @var6 sysname;
SELECT @var6 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'Type');
IF @var6 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var6 + '];');
ALTER TABLE [properties] ALTER COLUMN [Type] varchar(50) NOT NULL;

DECLARE @var7 sysname;
SELECT @var7 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'Owner');
IF @var7 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var7 + '];');
ALTER TABLE [properties] ALTER COLUMN [Owner] varchar(100) NOT NULL;

DECLARE @var8 sysname;
SELECT @var8 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'Description');
IF @var8 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var8 + '];');
ALTER TABLE [properties] ALTER COLUMN [Description] varchar(1000) NULL;

DECLARE @var9 sysname;
SELECT @var9 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[properties]') AND [c].[name] = N'Address');
IF @var9 IS NOT NULL EXEC(N'ALTER TABLE [properties] DROP CONSTRAINT [' + @var9 + '];');
ALTER TABLE [properties] ALTER COLUMN [Address] varchar(255) NOT NULL;

ALTER TABLE [properties] ADD [Ownerphone] int NOT NULL DEFAULT 0;

DECLARE @var10 sysname;
SELECT @var10 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[payments]') AND [c].[name] = N'Status');
IF @var10 IS NOT NULL EXEC(N'ALTER TABLE [payments] DROP CONSTRAINT [' + @var10 + '];');
ALTER TABLE [payments] ALTER COLUMN [Status] varchar(50) NOT NULL;

DECLARE @var11 sysname;
SELECT @var11 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[leases]') AND [c].[name] = N'Terms');
IF @var11 IS NOT NULL EXEC(N'ALTER TABLE [leases] DROP CONSTRAINT [' + @var11 + '];');
ALTER TABLE [leases] ALTER COLUMN [Terms] varchar(1000) NOT NULL;

DECLARE @var12 sysname;
SELECT @var12 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[issues]') AND [c].[name] = N'Status');
IF @var12 IS NOT NULL EXEC(N'ALTER TABLE [issues] DROP CONSTRAINT [' + @var12 + '];');
ALTER TABLE [issues] ALTER COLUMN [Status] varchar(50) NOT NULL;

DECLARE @var13 sysname;
SELECT @var13 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[issues]') AND [c].[name] = N'Description');
IF @var13 IS NOT NULL EXEC(N'ALTER TABLE [issues] DROP CONSTRAINT [' + @var13 + '];');
ALTER TABLE [issues] ALTER COLUMN [Description] varchar(1000) NOT NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241023003535_validate', N'9.0.8');

DECLARE @var14 sysname;
SELECT @var14 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[payments]') AND [c].[name] = N'Status');
IF @var14 IS NOT NULL EXEC(N'ALTER TABLE [payments] DROP CONSTRAINT [' + @var14 + '];');
ALTER TABLE [payments] ALTER COLUMN [Status] varchar(max) NOT NULL;

ALTER TABLE [payments] ADD [CVV] varchar(max) NOT NULL DEFAULT '';

ALTER TABLE [payments] ADD [CreditCardNumber] varchar(max) NOT NULL DEFAULT '';

ALTER TABLE [payments] ADD [ExpirationDate] datetime2 NOT NULL DEFAULT '0001-01-01T00:00:00.0000000';

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20241023015940_pays', N'9.0.8');

CREATE TABLE [AspNetRoles] (
    [Id] varchar(450) NOT NULL,
    [Name] varchar(256) NULL,
    [NormalizedName] varchar(256) NULL,
    [ConcurrencyStamp] varchar(max) NULL,
    CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([Id])
);

CREATE TABLE [AspNetUsers] (
    [Id] varchar(450) NOT NULL,
    [UserName] varchar(256) NULL,
    [NormalizedUserName] varchar(256) NULL,
    [Email] varchar(256) NULL,
    [NormalizedEmail] varchar(256) NULL,
    [EmailConfirmed] bit NOT NULL,
    [PasswordHash] varchar(max) NULL,
    [SecurityStamp] varchar(max) NULL,
    [ConcurrencyStamp] varchar(max) NULL,
    [PhoneNumber] varchar(max) NULL,
    [PhoneNumberConfirmed] bit NOT NULL,
    [TwoFactorEnabled] bit NOT NULL,
    [LockoutEnd] datetimeoffset NULL,
    [LockoutEnabled] bit NOT NULL,
    [AccessFailedCount] int NOT NULL,
    CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([Id])
);

CREATE TABLE [AspNetRoleClaims] (
    [Id] int NOT NULL IDENTITY,
    [RoleId] varchar(450) NOT NULL,
    [ClaimType] varchar(max) NULL,
    [ClaimValue] varchar(max) NULL,
    CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserClaims] (
    [Id] int NOT NULL IDENTITY,
    [UserId] varchar(450) NOT NULL,
    [ClaimType] varchar(max) NULL,
    [ClaimValue] varchar(max) NULL,
    CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserLogins] (
    [LoginProvider] varchar(450) NOT NULL,
    [ProviderKey] varchar(450) NOT NULL,
    [ProviderDisplayName] varchar(max) NULL,
    [UserId] varchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
    CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserRoles] (
    [UserId] varchar(450) NOT NULL,
    [RoleId] varchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]),
    CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserTokens] (
    [UserId] varchar(450) NOT NULL,
    [LoginProvider] varchar(450) NOT NULL,
    [Name] varchar(450) NOT NULL,
    [Value] varchar(max) NULL,
    CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
    CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);

CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;

CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);

CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);

CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);

CREATE INDEX [EmailIndex] ON [AspNetUsers] ([NormalizedEmail]);

CREATE UNIQUE INDEX [UserNameIndex] ON [AspNetUsers] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250815130808_First', N'9.0.8');

ALTER TABLE [issues] DROP CONSTRAINT [FK_issues_tenants_TenantID];

ALTER TABLE [leases] DROP CONSTRAINT [FK_leases_properties_PropertyID];

ALTER TABLE [leases] DROP CONSTRAINT [FK_leases_tenants_TenantID];

ALTER TABLE [payments] DROP CONSTRAINT [FK_payments_tenants_TenantID];

ALTER TABLE [PropertiesImages] DROP CONSTRAINT [FK_PropertiesImages_properties_PropertyID];

ALTER TABLE [tenants] DROP CONSTRAINT [FK_tenants_properties_PropertyID];

ALTER TABLE [users] DROP CONSTRAINT [PK_users];

ALTER TABLE [tenants] DROP CONSTRAINT [PK_tenants];

ALTER TABLE [properties] DROP CONSTRAINT [PK_properties];

ALTER TABLE [payments] DROP CONSTRAINT [PK_payments];

ALTER TABLE [leases] DROP CONSTRAINT [PK_leases];

ALTER TABLE [issues] DROP CONSTRAINT [PK_issues];

EXEC sp_rename N'[users]', N'Users', 'OBJECT';

EXEC sp_rename N'[tenants]', N'Tenants', 'OBJECT';

EXEC sp_rename N'[properties]', N'Properties', 'OBJECT';

EXEC sp_rename N'[payments]', N'Payments', 'OBJECT';

EXEC sp_rename N'[leases]', N'Leases', 'OBJECT';

EXEC sp_rename N'[issues]', N'Issues', 'OBJECT';

EXEC sp_rename N'[Tenants].[IX_tenants_PropertyID]', N'IX_Tenants_PropertyID', 'INDEX';

EXEC sp_rename N'[Properties].[Ownerphone]', N'OwnerPhone', 'COLUMN';

EXEC sp_rename N'[Payments].[IX_payments_TenantID]', N'IX_Payments_TenantID', 'INDEX';

EXEC sp_rename N'[Leases].[IX_leases_TenantID]', N'IX_Leases_TenantID', 'INDEX';

EXEC sp_rename N'[Leases].[IX_leases_PropertyID]', N'IX_Leases_PropertyID', 'INDEX';

EXEC sp_rename N'[Issues].[IX_issues_TenantID]', N'IX_Issues_TenantID', 'INDEX';

DECLARE @var15 sysname;
SELECT @var15 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'Username');
IF @var15 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var15 + '];');
ALTER TABLE [Users] ALTER COLUMN [Username] nvarchar(max) NOT NULL;

DECLARE @var16 sysname;
SELECT @var16 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'Role');
IF @var16 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var16 + '];');
ALTER TABLE [Users] ALTER COLUMN [Role] nvarchar(max) NOT NULL;

DECLARE @var17 sysname;
SELECT @var17 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'Password');
IF @var17 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var17 + '];');
ALTER TABLE [Users] ALTER COLUMN [Password] nvarchar(max) NOT NULL;

DECLARE @var18 sysname;
SELECT @var18 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Tenants]') AND [c].[name] = N'PhoneNumber');
IF @var18 IS NOT NULL EXEC(N'ALTER TABLE [Tenants] DROP CONSTRAINT [' + @var18 + '];');
ALTER TABLE [Tenants] ALTER COLUMN [PhoneNumber] nvarchar(max) NOT NULL;

DECLARE @var19 sysname;
SELECT @var19 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Tenants]') AND [c].[name] = N'Name');
IF @var19 IS NOT NULL EXEC(N'ALTER TABLE [Tenants] DROP CONSTRAINT [' + @var19 + '];');
ALTER TABLE [Tenants] ALTER COLUMN [Name] nvarchar(100) NOT NULL;

DECLARE @var20 sysname;
SELECT @var20 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PropertiesImages]') AND [c].[name] = N'ImagePath');
IF @var20 IS NOT NULL EXEC(N'ALTER TABLE [PropertiesImages] DROP CONSTRAINT [' + @var20 + '];');
ALTER TABLE [PropertiesImages] ALTER COLUMN [ImagePath] nvarchar(max) NOT NULL;

DECLARE @var21 sysname;
SELECT @var21 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'Type');
IF @var21 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var21 + '];');
ALTER TABLE [Properties] ALTER COLUMN [Type] nvarchar(50) NOT NULL;

DECLARE @var22 sysname;
SELECT @var22 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'OwnerPhone');
IF @var22 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var22 + '];');
ALTER TABLE [Properties] ALTER COLUMN [OwnerPhone] nvarchar(max) NOT NULL;

DECLARE @var23 sysname;
SELECT @var23 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'Owner');
IF @var23 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var23 + '];');
ALTER TABLE [Properties] ALTER COLUMN [Owner] nvarchar(100) NOT NULL;

DECLARE @var24 sysname;
SELECT @var24 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'Description');
IF @var24 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var24 + '];');
ALTER TABLE [Properties] ALTER COLUMN [Description] nvarchar(1000) NULL;

DECLARE @var25 sysname;
SELECT @var25 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'CreatedDate');
IF @var25 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var25 + '];');
UPDATE [Properties] SET [CreatedDate] = '0001-01-01T00:00:00.0000000' WHERE [CreatedDate] IS NULL;
ALTER TABLE [Properties] ALTER COLUMN [CreatedDate] datetime2 NOT NULL;
ALTER TABLE [Properties] ADD DEFAULT '0001-01-01T00:00:00.0000000' FOR [CreatedDate];

DECLARE @var26 sysname;
SELECT @var26 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'Address');
IF @var26 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var26 + '];');
ALTER TABLE [Properties] ALTER COLUMN [Address] nvarchar(255) NOT NULL;

ALTER TABLE [Properties] ADD [Bathrooms] int NOT NULL DEFAULT 0;

ALTER TABLE [Properties] ADD [Bedrooms] int NOT NULL DEFAULT 0;

DECLARE @var27 sysname;
SELECT @var27 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'Status');
IF @var27 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var27 + '];');
ALTER TABLE [Payments] ALTER COLUMN [Status] nvarchar(max) NOT NULL;

DECLARE @var28 sysname;
SELECT @var28 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'CreditCardNumber');
IF @var28 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var28 + '];');
ALTER TABLE [Payments] ALTER COLUMN [CreditCardNumber] nvarchar(max) NOT NULL;

DECLARE @var29 sysname;
SELECT @var29 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'CVV');
IF @var29 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var29 + '];');
ALTER TABLE [Payments] ALTER COLUMN [CVV] nvarchar(max) NOT NULL;

DECLARE @var30 sysname;
SELECT @var30 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Leases]') AND [c].[name] = N'Terms');
IF @var30 IS NOT NULL EXEC(N'ALTER TABLE [Leases] DROP CONSTRAINT [' + @var30 + '];');
ALTER TABLE [Leases] ALTER COLUMN [Terms] nvarchar(1000) NOT NULL;

DECLARE @var31 sysname;
SELECT @var31 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Issues]') AND [c].[name] = N'Status');
IF @var31 IS NOT NULL EXEC(N'ALTER TABLE [Issues] DROP CONSTRAINT [' + @var31 + '];');
ALTER TABLE [Issues] ALTER COLUMN [Status] nvarchar(50) NOT NULL;

DECLARE @var32 sysname;
SELECT @var32 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Issues]') AND [c].[name] = N'Description');
IF @var32 IS NOT NULL EXEC(N'ALTER TABLE [Issues] DROP CONSTRAINT [' + @var32 + '];');
ALTER TABLE [Issues] ALTER COLUMN [Description] nvarchar(1000) NOT NULL;

DECLARE @var33 sysname;
SELECT @var33 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserTokens]') AND [c].[name] = N'Value');
IF @var33 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserTokens] DROP CONSTRAINT [' + @var33 + '];');
ALTER TABLE [AspNetUserTokens] ALTER COLUMN [Value] nvarchar(max) NULL;

DECLARE @var34 sysname;
SELECT @var34 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserTokens]') AND [c].[name] = N'Name');
IF @var34 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserTokens] DROP CONSTRAINT [' + @var34 + '];');
ALTER TABLE [AspNetUserTokens] ALTER COLUMN [Name] nvarchar(450) NOT NULL;

DECLARE @var35 sysname;
SELECT @var35 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserTokens]') AND [c].[name] = N'LoginProvider');
IF @var35 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserTokens] DROP CONSTRAINT [' + @var35 + '];');
ALTER TABLE [AspNetUserTokens] ALTER COLUMN [LoginProvider] nvarchar(450) NOT NULL;

DECLARE @var36 sysname;
SELECT @var36 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserTokens]') AND [c].[name] = N'UserId');
IF @var36 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserTokens] DROP CONSTRAINT [' + @var36 + '];');
ALTER TABLE [AspNetUserTokens] ALTER COLUMN [UserId] nvarchar(450) NOT NULL;

DECLARE @var37 sysname;
SELECT @var37 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'UserName');
IF @var37 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var37 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [UserName] nvarchar(256) NULL;

DECLARE @var38 sysname;
SELECT @var38 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'SecurityStamp');
IF @var38 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var38 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [SecurityStamp] nvarchar(max) NULL;

DECLARE @var39 sysname;
SELECT @var39 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'PhoneNumber');
IF @var39 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var39 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [PhoneNumber] nvarchar(max) NULL;

DECLARE @var40 sysname;
SELECT @var40 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'PasswordHash');
IF @var40 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var40 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [PasswordHash] nvarchar(max) NULL;

DROP INDEX [UserNameIndex] ON [AspNetUsers];
DECLARE @var41 sysname;
SELECT @var41 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'NormalizedUserName');
IF @var41 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var41 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [NormalizedUserName] nvarchar(256) NULL;
CREATE UNIQUE INDEX [UserNameIndex] ON [AspNetUsers] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;

DROP INDEX [EmailIndex] ON [AspNetUsers];
DECLARE @var42 sysname;
SELECT @var42 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'NormalizedEmail');
IF @var42 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var42 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [NormalizedEmail] nvarchar(256) NULL;
CREATE INDEX [EmailIndex] ON [AspNetUsers] ([NormalizedEmail]);

DECLARE @var43 sysname;
SELECT @var43 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'Email');
IF @var43 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var43 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [Email] nvarchar(256) NULL;

DECLARE @var44 sysname;
SELECT @var44 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'ConcurrencyStamp');
IF @var44 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var44 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [ConcurrencyStamp] nvarchar(max) NULL;

DECLARE @var45 sysname;
SELECT @var45 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'Id');
IF @var45 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var45 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [Id] nvarchar(450) NOT NULL;

DROP INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles];
DECLARE @var46 sysname;
SELECT @var46 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserRoles]') AND [c].[name] = N'RoleId');
IF @var46 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserRoles] DROP CONSTRAINT [' + @var46 + '];');
ALTER TABLE [AspNetUserRoles] ALTER COLUMN [RoleId] nvarchar(450) NOT NULL;
CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);

DECLARE @var47 sysname;
SELECT @var47 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserRoles]') AND [c].[name] = N'UserId');
IF @var47 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserRoles] DROP CONSTRAINT [' + @var47 + '];');
ALTER TABLE [AspNetUserRoles] ALTER COLUMN [UserId] nvarchar(450) NOT NULL;

DROP INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins];
DECLARE @var48 sysname;
SELECT @var48 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserLogins]') AND [c].[name] = N'UserId');
IF @var48 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserLogins] DROP CONSTRAINT [' + @var48 + '];');
ALTER TABLE [AspNetUserLogins] ALTER COLUMN [UserId] nvarchar(450) NOT NULL;
CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);

DECLARE @var49 sysname;
SELECT @var49 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserLogins]') AND [c].[name] = N'ProviderDisplayName');
IF @var49 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserLogins] DROP CONSTRAINT [' + @var49 + '];');
ALTER TABLE [AspNetUserLogins] ALTER COLUMN [ProviderDisplayName] nvarchar(max) NULL;

DECLARE @var50 sysname;
SELECT @var50 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserLogins]') AND [c].[name] = N'ProviderKey');
IF @var50 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserLogins] DROP CONSTRAINT [' + @var50 + '];');
ALTER TABLE [AspNetUserLogins] ALTER COLUMN [ProviderKey] nvarchar(450) NOT NULL;

DECLARE @var51 sysname;
SELECT @var51 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserLogins]') AND [c].[name] = N'LoginProvider');
IF @var51 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserLogins] DROP CONSTRAINT [' + @var51 + '];');
ALTER TABLE [AspNetUserLogins] ALTER COLUMN [LoginProvider] nvarchar(450) NOT NULL;

DROP INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims];
DECLARE @var52 sysname;
SELECT @var52 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserClaims]') AND [c].[name] = N'UserId');
IF @var52 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserClaims] DROP CONSTRAINT [' + @var52 + '];');
ALTER TABLE [AspNetUserClaims] ALTER COLUMN [UserId] nvarchar(450) NOT NULL;
CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);

DECLARE @var53 sysname;
SELECT @var53 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserClaims]') AND [c].[name] = N'ClaimValue');
IF @var53 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserClaims] DROP CONSTRAINT [' + @var53 + '];');
ALTER TABLE [AspNetUserClaims] ALTER COLUMN [ClaimValue] nvarchar(max) NULL;

DECLARE @var54 sysname;
SELECT @var54 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserClaims]') AND [c].[name] = N'ClaimType');
IF @var54 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserClaims] DROP CONSTRAINT [' + @var54 + '];');
ALTER TABLE [AspNetUserClaims] ALTER COLUMN [ClaimType] nvarchar(max) NULL;

DROP INDEX [RoleNameIndex] ON [AspNetRoles];
DECLARE @var55 sysname;
SELECT @var55 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoles]') AND [c].[name] = N'NormalizedName');
IF @var55 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoles] DROP CONSTRAINT [' + @var55 + '];');
ALTER TABLE [AspNetRoles] ALTER COLUMN [NormalizedName] nvarchar(256) NULL;
CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;

DECLARE @var56 sysname;
SELECT @var56 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoles]') AND [c].[name] = N'Name');
IF @var56 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoles] DROP CONSTRAINT [' + @var56 + '];');
ALTER TABLE [AspNetRoles] ALTER COLUMN [Name] nvarchar(256) NULL;

DECLARE @var57 sysname;
SELECT @var57 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoles]') AND [c].[name] = N'ConcurrencyStamp');
IF @var57 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoles] DROP CONSTRAINT [' + @var57 + '];');
ALTER TABLE [AspNetRoles] ALTER COLUMN [ConcurrencyStamp] nvarchar(max) NULL;

DECLARE @var58 sysname;
SELECT @var58 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoles]') AND [c].[name] = N'Id');
IF @var58 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoles] DROP CONSTRAINT [' + @var58 + '];');
ALTER TABLE [AspNetRoles] ALTER COLUMN [Id] nvarchar(450) NOT NULL;

DROP INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims];
DECLARE @var59 sysname;
SELECT @var59 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoleClaims]') AND [c].[name] = N'RoleId');
IF @var59 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoleClaims] DROP CONSTRAINT [' + @var59 + '];');
ALTER TABLE [AspNetRoleClaims] ALTER COLUMN [RoleId] nvarchar(450) NOT NULL;
CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);

DECLARE @var60 sysname;
SELECT @var60 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoleClaims]') AND [c].[name] = N'ClaimValue');
IF @var60 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoleClaims] DROP CONSTRAINT [' + @var60 + '];');
ALTER TABLE [AspNetRoleClaims] ALTER COLUMN [ClaimValue] nvarchar(max) NULL;

DECLARE @var61 sysname;
SELECT @var61 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoleClaims]') AND [c].[name] = N'ClaimType');
IF @var61 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoleClaims] DROP CONSTRAINT [' + @var61 + '];');
ALTER TABLE [AspNetRoleClaims] ALTER COLUMN [ClaimType] nvarchar(max) NULL;

ALTER TABLE [Users] ADD CONSTRAINT [PK_Users] PRIMARY KEY ([UserID]);

ALTER TABLE [Tenants] ADD CONSTRAINT [PK_Tenants] PRIMARY KEY ([TenantID]);

ALTER TABLE [Properties] ADD CONSTRAINT [PK_Properties] PRIMARY KEY ([PropertyID]);

ALTER TABLE [Payments] ADD CONSTRAINT [PK_Payments] PRIMARY KEY ([PaymentID]);

ALTER TABLE [Leases] ADD CONSTRAINT [PK_Leases] PRIMARY KEY ([LeaseID]);

ALTER TABLE [Issues] ADD CONSTRAINT [PK_Issues] PRIMARY KEY ([IssueID]);

ALTER TABLE [Issues] ADD CONSTRAINT [FK_Issues_Tenants_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [Tenants] ([TenantID]);

ALTER TABLE [Leases] ADD CONSTRAINT [FK_Leases_Properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [Properties] ([PropertyID]);

ALTER TABLE [Leases] ADD CONSTRAINT [FK_Leases_Tenants_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [Tenants] ([TenantID]);

ALTER TABLE [Payments] ADD CONSTRAINT [FK_Payments_Tenants_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [Tenants] ([TenantID]);

ALTER TABLE [PropertiesImages] ADD CONSTRAINT [FK_PropertiesImages_Properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [Properties] ([PropertyID]);

ALTER TABLE [Tenants] ADD CONSTRAINT [FK_Tenants_Properties_PropertyID] FOREIGN KEY ([PropertyID]) REFERENCES [Properties] ([PropertyID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250817000139_AddBedroomsBathroomsToProperty', N'9.0.8');

DECLARE @var62 sysname;
SELECT @var62 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Users]') AND [c].[name] = N'Password');
IF @var62 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var62 + '];');
ALTER TABLE [Users] DROP COLUMN [Password];

EXEC sp_rename N'[Users].[UserID]', N'Id', 'COLUMN';

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250817220617_Auth', N'9.0.8');

ALTER TABLE [Issues] DROP CONSTRAINT [FK_Issues_Tenants_TenantID];

ALTER TABLE [Leases] DROP CONSTRAINT [FK_Leases_Tenants_TenantID];

DROP TABLE [Tenants];

DROP TABLE [Users];

DECLARE @var63 sysname;
SELECT @var63 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'Owner');
IF @var63 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var63 + '];');
ALTER TABLE [Properties] DROP COLUMN [Owner];

DECLARE @var64 sysname;
SELECT @var64 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Properties]') AND [c].[name] = N'OwnerPhone');
IF @var64 IS NOT NULL EXEC(N'ALTER TABLE [Properties] DROP CONSTRAINT [' + @var64 + '];');
ALTER TABLE [Properties] DROP COLUMN [OwnerPhone];

ALTER TABLE [Properties] ADD [OwnerID] uniqueidentifier NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000';

DROP INDEX [IX_Payments_TenantID] ON [Payments];
DECLARE @var65 sysname;
SELECT @var65 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'TenantID');
IF @var65 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var65 + '];');
ALTER TABLE [Payments] ALTER COLUMN [TenantID] uniqueidentifier NOT NULL;
CREATE INDEX [IX_Payments_TenantID] ON [Payments] ([TenantID]);

DROP INDEX [IX_Leases_TenantID] ON [Leases];
DECLARE @var66 sysname;
SELECT @var66 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Leases]') AND [c].[name] = N'TenantID');
IF @var66 IS NOT NULL EXEC(N'ALTER TABLE [Leases] DROP CONSTRAINT [' + @var66 + '];');
ALTER TABLE [Leases] ALTER COLUMN [TenantID] uniqueidentifier NOT NULL;
CREATE INDEX [IX_Leases_TenantID] ON [Leases] ([TenantID]);

ALTER TABLE [Leases] ADD [OwnerID] uniqueidentifier NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000';

DROP INDEX [IX_Issues_TenantID] ON [Issues];
DECLARE @var67 sysname;
SELECT @var67 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Issues]') AND [c].[name] = N'TenantID');
IF @var67 IS NOT NULL EXEC(N'ALTER TABLE [Issues] DROP CONSTRAINT [' + @var67 + '];');
ALTER TABLE [Issues] ALTER COLUMN [TenantID] uniqueidentifier NOT NULL;
CREATE INDEX [IX_Issues_TenantID] ON [Issues] ([TenantID]);

DECLARE @var68 sysname;
SELECT @var68 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserTokens]') AND [c].[name] = N'UserId');
IF @var68 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserTokens] DROP CONSTRAINT [' + @var68 + '];');
ALTER TABLE [AspNetUserTokens] ALTER COLUMN [UserId] uniqueidentifier NOT NULL;

DECLARE @var69 sysname;
SELECT @var69 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'PhoneNumber');
IF @var69 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var69 + '];');
UPDATE [AspNetUsers] SET [PhoneNumber] = N'' WHERE [PhoneNumber] IS NULL;
ALTER TABLE [AspNetUsers] ALTER COLUMN [PhoneNumber] nvarchar(max) NOT NULL;
ALTER TABLE [AspNetUsers] ADD DEFAULT N'' FOR [PhoneNumber];

DECLARE @var70 sysname;
SELECT @var70 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUsers]') AND [c].[name] = N'Id');
IF @var70 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUsers] DROP CONSTRAINT [' + @var70 + '];');
ALTER TABLE [AspNetUsers] ALTER COLUMN [Id] uniqueidentifier NOT NULL;

ALTER TABLE [AspNetUsers] ADD [Name] nvarchar(100) NOT NULL DEFAULT N'';

ALTER TABLE [AspNetUsers] ADD [Role] nvarchar(max) NOT NULL DEFAULT N'';

DROP INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles];
DECLARE @var71 sysname;
SELECT @var71 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserRoles]') AND [c].[name] = N'RoleId');
IF @var71 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserRoles] DROP CONSTRAINT [' + @var71 + '];');
ALTER TABLE [AspNetUserRoles] ALTER COLUMN [RoleId] uniqueidentifier NOT NULL;
CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);

DECLARE @var72 sysname;
SELECT @var72 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserRoles]') AND [c].[name] = N'UserId');
IF @var72 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserRoles] DROP CONSTRAINT [' + @var72 + '];');
ALTER TABLE [AspNetUserRoles] ALTER COLUMN [UserId] uniqueidentifier NOT NULL;

DROP INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins];
DECLARE @var73 sysname;
SELECT @var73 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserLogins]') AND [c].[name] = N'UserId');
IF @var73 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserLogins] DROP CONSTRAINT [' + @var73 + '];');
ALTER TABLE [AspNetUserLogins] ALTER COLUMN [UserId] uniqueidentifier NOT NULL;
CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);

DROP INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims];
DECLARE @var74 sysname;
SELECT @var74 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetUserClaims]') AND [c].[name] = N'UserId');
IF @var74 IS NOT NULL EXEC(N'ALTER TABLE [AspNetUserClaims] DROP CONSTRAINT [' + @var74 + '];');
ALTER TABLE [AspNetUserClaims] ALTER COLUMN [UserId] uniqueidentifier NOT NULL;
CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);

DECLARE @var75 sysname;
SELECT @var75 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoles]') AND [c].[name] = N'Id');
IF @var75 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoles] DROP CONSTRAINT [' + @var75 + '];');
ALTER TABLE [AspNetRoles] ALTER COLUMN [Id] uniqueidentifier NOT NULL;

DROP INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims];
DECLARE @var76 sysname;
SELECT @var76 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[AspNetRoleClaims]') AND [c].[name] = N'RoleId');
IF @var76 IS NOT NULL EXEC(N'ALTER TABLE [AspNetRoleClaims] DROP CONSTRAINT [' + @var76 + '];');
ALTER TABLE [AspNetRoleClaims] ALTER COLUMN [RoleId] uniqueidentifier NOT NULL;
CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);

CREATE INDEX [IX_Properties_OwnerID] ON [Properties] ([OwnerID]);

CREATE INDEX [IX_Leases_OwnerID] ON [Leases] ([OwnerID]);

ALTER TABLE [Issues] ADD CONSTRAINT [FK_Issues_AspNetUsers_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Leases] ADD CONSTRAINT [FK_Leases_AspNetUsers_OwnerID] FOREIGN KEY ([OwnerID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Leases] ADD CONSTRAINT [FK_Leases_AspNetUsers_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Payments] ADD CONSTRAINT [FK_Payments_AspNetUsers_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Properties] ADD CONSTRAINT [FK_Properties_AspNetUsers_OwnerID] FOREIGN KEY ([OwnerID]) REFERENCES [AspNetUsers] ([Id]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250817232749_Authoo', N'9.0.8');

ALTER TABLE [AspNetUserClaims] DROP CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId];

ALTER TABLE [AspNetUserLogins] DROP CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId];

ALTER TABLE [AspNetUserRoles] DROP CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId];

ALTER TABLE [AspNetUserTokens] DROP CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId];

ALTER TABLE [Issues] DROP CONSTRAINT [FK_Issues_AspNetUsers_TenantID];

ALTER TABLE [Leases] DROP CONSTRAINT [FK_Leases_AspNetUsers_OwnerID];

ALTER TABLE [Leases] DROP CONSTRAINT [FK_Leases_AspNetUsers_TenantID];

ALTER TABLE [Payments] DROP CONSTRAINT [FK_Payments_AspNetUsers_TenantID];

ALTER TABLE [Properties] DROP CONSTRAINT [FK_Properties_AspNetUsers_OwnerID];

ALTER TABLE [AspNetUsers] DROP CONSTRAINT [PK_AspNetUsers];

EXEC sp_rename N'[AspNetUsers].[Id]', N'ID', 'COLUMN';

ALTER TABLE [AspNetUsers] ADD [Id] uniqueidentifier NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000';

ALTER TABLE [AspNetUsers] ADD CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([Id]);

ALTER TABLE [AspNetUserClaims] ADD CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [AspNetUserLogins] ADD CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [AspNetUserRoles] ADD CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [AspNetUserTokens] ADD CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Issues] ADD CONSTRAINT [FK_Issues_AspNetUsers_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Leases] ADD CONSTRAINT [FK_Leases_AspNetUsers_OwnerID] FOREIGN KEY ([OwnerID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Leases] ADD CONSTRAINT [FK_Leases_AspNetUsers_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Payments] ADD CONSTRAINT [FK_Payments_AspNetUsers_TenantID] FOREIGN KEY ([TenantID]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Properties] ADD CONSTRAINT [FK_Properties_AspNetUsers_OwnerID] FOREIGN KEY ([OwnerID]) REFERENCES [AspNetUsers] ([Id]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250817235113_Authoooo', N'9.0.8');

ALTER TABLE [Payments] DROP CONSTRAINT [FK_Payments_AspNetUsers_TenantID];

DROP INDEX [IX_Payments_TenantID] ON [Payments];

DECLARE @var77 sysname;
SELECT @var77 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Payments]') AND [c].[name] = N'TenantID');
IF @var77 IS NOT NULL EXEC(N'ALTER TABLE [Payments] DROP CONSTRAINT [' + @var77 + '];');
ALTER TABLE [Payments] DROP COLUMN [TenantID];

ALTER TABLE [Payments] ADD [ApplicationUserId] uniqueidentifier NULL;

ALTER TABLE [Payments] ADD [LeaseID] int NOT NULL DEFAULT 0;

CREATE INDEX [IX_Payments_ApplicationUserId] ON [Payments] ([ApplicationUserId]);

CREATE INDEX [IX_Payments_LeaseID] ON [Payments] ([LeaseID]);

ALTER TABLE [Payments] ADD CONSTRAINT [FK_Payments_AspNetUsers_ApplicationUserId] FOREIGN KEY ([ApplicationUserId]) REFERENCES [AspNetUsers] ([Id]);

ALTER TABLE [Payments] ADD CONSTRAINT [FK_Payments_Leases_LeaseID] FOREIGN KEY ([LeaseID]) REFERENCES [Leases] ([LeaseID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250817235402_Authoooooo', N'9.0.8');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250817235854_Authooooooo', N'9.0.8');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250818000530_Yarab', N'9.0.8');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250818002415_Yarabb', N'9.0.8');

COMMIT;
GO


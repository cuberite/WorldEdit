CREATE TABLE IF NOT EXISTS "PlayerSelection" (
	`uuid` TEXT PRIMARY KEY,
	`MinX` INTEGER,
	`MaxX` INTEGER,
	`MinY` INTEGER,
	`MaxY` INTEGER,
	`MinZ` INTEGER,
	`MaxZ` INTEGER
);

CREATE TABLE IF NOT EXISTS "DatabaseInfo" (
	`DatabaseVersion` INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "NamedPlayerSelection" (
	`uuid`     TEXT,
	`selname`  TEXT,
	`MinX`     INTEGER,
	`MaxX`     INTEGER,
	`MinY`     INTEGER,
	`MaxY`     INTEGER,
	`MinZ`     INTEGER,
	`MaxZ`     INTEGER,
	PRIMARY KEY(`uuid`, `selname`)
);

INSERT INTO "DatabaseInfo" (`DatabaseVersion`)
VALUES (1)

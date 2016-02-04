SELECT `MinX`, `MaxX`, `MinY`, `MaxY`, `MinZ`, `MaxZ` 
FROM "NamedPlayerSelection"
WHERE `uuid` = $playeruuid
AND `selname` = $selname
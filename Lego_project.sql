CREATE DATABASE IF NOT EXISTS Lego_db;
USE Lego_db;

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE Users (
	UserId INT AUTO_INCREMENT PRIMARY KEY,
    UserName VARCHAR(50),
    Email VARCHAR(50),
    TotalOwendPieces INT
);

CREATE TABLE LegoSets (
	SetID INT AUTO_INCREMENT PRIMARY KEY,
    SetName VARCHAR(50),
    YearReleased VARCHAR(50),
    SetPrice INT
);

CREATE TABLE LegoPieces (
	PieceID INT AUTO_INCREMENT PRIMARY KEY,
    PieceName VARCHAR(50),
    PieceType VARCHAR(50),
    PieceColor VARCHAR(50),
    PiecePrice INT
);

CREATE TABLE UserLegoSets(
	UserID INT,
    SetID INT,
    NumberOfSets INT,
    PRIMARY KEY (UserID, SetID),
    FOREIGN KEY (UserID ) REFERENCES Users (UserID),
    FOREIGN KEY (SetID ) REFERENCES LegoSets (SetID)
);
    
CREATE TABLE UserLegoPieces(
	UserID INT,
    PieceID INT,
    NumberOfPieces INT,
    PRIMARY KEY (UserID, PieceID),
    FOREIGN KEY (UserID ) REFERENCES Users (UserID),
    FOREIGN KEY (PieceID ) REFERENCES LegoPieces (PieceID)
);

CREATE TABLE LegoSetPieces(
	PieceID INT,
    SetID INT,
	NumberOfPieces INT,
    PRIMARY KEY (PieceID, SetID),
    FOREIGN KEY (PieceID ) REFERENCES LegoPieces (PieceID),
    FOREIGN KEY (SetID ) REFERENCES LegoSets (SetID)
);

INSERT INTO LegoPieces (PieceName, PieceType, PieceColor, PiecePrice) VALUES
('Brick 2x4', 'brick', 'Red', 10),
('Brick 2x4', 'brick', 'Blue', 11),
('Brick 2x4', 'brick', 'Yellow', 14),
('Brick 2x4', 'brick', 'Green', 5),
('Brick 2x4', 'brick', 'Pink', 50),
('Brick 1x2', 'brick', 'Red', 5),
('Brick 1x2', 'brick', 'Blue', 10),
('Brick 1x2', 'brick', 'Yellow', 3),
('Brick 1x2', 'brick', 'Green', 5),
('Plate 2x2', 'plate', 'Yellow', 9),
('Plate 2x2', 'plate', 'Red', 15),
('Plate 2x2', 'plate', 'Blue', 6),
('Plate 2x2', 'plate', 'Green', 2),
('Plate 1x4', 'plate', 'Green', 11),
('Plate 1x4', 'plate', 'Yellow', 20),
('Plate 1x4', 'plate', 'Blue', 16),
('Plate 1x4', 'plate', 'Red', 8),
('Slope 2x4', 'slope', 'Red', 15),
('Slope 2x4', 'slope', 'Blue', 6),
('Slope 1x2', 'slope', 'Blue', 8),
('Slope 2x2', 'slope', 'Yellow', 12),
('Slope 1x4', 'slope', 'Green', 10);

SELECT * FROM LegoPieces ORDER BY PieceType;

INSERT INTO Users (UserName, Email, totalOwendPieces) VALUES
('John Doe', 'johndoe@example.com', 0),
('Bob Johnson', 'bjohnson@example.com', 0);

SELECT * FROM users;

INSERT INTO LegoSets (SetName, YearReleased, SetPrice) VALUES
('Blue Car', '2021', 99),
('All slopes', '2019', 70),
('yellow Flower', '2023', 200),
('Brick wall', '2001', 50),
('Rainbow', '2003', 200);

SELECT * FROM LegoSets;

INSERT INTO LegoSetPieces ( SetID, PieceID, NumberOfPieces ) VALUES
-- Blue Car
(1, 2, 3),
(1, 7, 3),
(1, 11, 1),
(1, 19, 1),
-- all slopes
(2, 18, 1),
(2, 19, 1),
(2, 20, 1),
(2, 21, 1),
(2, 22, 1),
-- yellow flower
(3, 21, 1),
(3, 15, 4),
-- Brick wall
(4, 1, 15),
-- Rainbow
(5, 1, 1),
(5, 2, 1),
(5, 3, 1),
(5, 4, 1),
(5, 5, 1);

SELECT * FROM LEgoSetPieces ORDER BY SetID;

DELIMITER // 
CREATE TRIGGER IncreaseNumOfUserPiecesWithInsert 
AFTER INSERT ON UserLegoPieces
FOR EACH ROW
BEGIN
	UPDATE Users
	SET totalOwendPieces = totalOwendPieces + NEW.NumberOfPieces
    WHERE userID = NEW.userID;
END;
// DELIMITER ;

DELIMITER // 
CREATE TRIGGER IncreaseNumOfUserPiecesWithUpdate 
AFTER UPDATE ON UserLegoPieces
FOR EACH ROW
BEGIN
	UPDATE Users
	SET totalOwendPieces = totalOwendPieces + NEW.NumberOfPieces - OLD.NumberOfPieces
    WHERE userID = NEW.userID;
END;
// DELIMITER ;

DELIMITER //
CREATE PROCEDURE updateOrInsert ( IN inUserID INT, IN inPieceID INT, IN inNumberOfPieces INT
)
BEGIN
	DECLARE ExistsInUser INT DEFAULT 0;
	SELECT Count(*) From UserLegoPieces WHERE inPieceID = pieceID AND inUserID = UserID INTO ExistsInUser;
    IF existsInUser = 0 
    THEN 
    INSERT INTO UserLegoPieces (userID, PieceID, NumberOfPieces ) VALUES
    (inUserID, inPieceID, inNumberOfPieces );
    ELSE 
	UPDATE UserLegoPieces 
    SET NumberOfPieces = NumberOfPieces + inNumberOfPieces 
    WHERE inPieceID = pieceID AND inUserID = UserID;
    END IF;
END;
// DELIMITER ;	

DELIMITER //
CREATE PROCEDURE AddSetToUser (
IN inUserID INT, IN inSetID INT)
BEGIN
	DECLARE tempSetID, tempPieceID, tempNumberOfPieces INT;
    DECLARE SetExistsInUser INT DEFAULT 0;
	SELECT Count(*) From UserLegoSets WHERE inSetID = SetID AND inUserID = UserID INTO SetExistsInUser;
    IF SetexistsInUser = 0 
    THEN 
		INSERT INTO UserLegoSets (userID, SetID, NumberOfSets ) VALUES
		(inUserID, inSetID, 1 );
    ELSE 
		UPDATE UserLegoSets 
		SET NumberOfSets = NumberOfSets + 1 
		WHERE inSetID = SetID AND inUserID = UserID;
    END IF;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS TempLegoSetPieces (
        PieceID INT,
        SetID INT,
        NumberOfPieces INT
    );
    INSERT INTO TempLegoSetPieces (PieceID, SetID, NumberOfPieces)
    SELECT PieceID, SetID, NumberOfPieces FROM LegoSetPieces WHERE inSetID = SetID; 
    WHILE ( SELECT COUNT(*) FROM TempLegoSetPieces ) > 0 DO
		SELECT PieceID, SetID, NumberOfPieces INTO tempPieceId, tempSetID, TempNumberOfPieces 
        FROM TempLegoSetPieces LIMIT 1;
        CALL updateOrInsert( inUserID, tempPieceID, tempNumberOfPieces );
        
        DELETE FROM TempLegoSetPieces WHERE PieceID = tempPieceID;
	END WHILE;
    
    DROP TEMPORARY TABLE IF EXISTS TempLegoSetPieces;
END;
// DELIMITER ;



DELIMITER //
CREATE PROCEDURE GetMissingPieces (
IN inUserID INT,
IN inSetID INT
)
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS TempMissingPieces (
		PieceID INT,
        PieceName VARCHAR(50),
        PieceType VARCHAR(50),
        PieceColor VARCHAR(50),
        RequiredNumberOfPieces INT    
    );
    
    INSERT INTO TempMissingPieces ( PieceID, PieceName, PieceType, PieceColor, RequiredNumberOfPieces )
    SELECT
		LegoSetPieces.PieceID,
        LegoPieces.PieceName,
        LegoPieces.PieceType,
        LegoPieces.PieceColor,
        (LegoSetPieces.NumberOfPieces - COALESCE(UserLegoPieces.NumberOfPieces, 0)) AS RequiredNumberOfPieces
	FROM LegoSetPieces
	JOIN LegoPieces ON LegoSetPieces.PieceID = LegoPieces.PieceID
	LEFT JOIN UserLegoPieces ON LegoSetPieces.PieceID = UserLegoPieces.PieceID AND UserLegoPieces.UserID = inUserID
    WHERE
		LegoSetPieces.SetID = inSetID
        AND ( UserLegoPieces.NumberOfPieces IS NULL OR UserLegoPieces.NumberOfPieces < LegoSetPieces.NumberOfPieces );
	
    SELECT * FROM TempMissingPieces;
    
    DROP TEMPORARY TABLE IF EXISTS TempMissingPieces;
END;

// DELIMITER ;

DELIMITER //
CREATE FUNCTION CompareSetToPiecesPrice(InSetID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE TotalPiecesCost INT;
    DECLARE TempSetPrice INT;
    DECLARE PriceDifference INT;
    
    SELECT SUM(LegoPieces.PiecePrice * LegoSetPieces.NumberOfPieces) INTO TotalPiecesCost
    FROM LegoPieces
    JOIN LegoSetPieces ON LegoPieces.PieceID = LegoSetPieces.PieceID
    WHERE LegoSetPieces.SetID = InSetID;
    
    SELECT SetPrice INTO TempSetPrice
    FROM LegoSets
    WHERE SetID = InSetID;
    
    SET PriceDifference = TotalPiecesCost - TempSetPrice;
    RETURN PriceDifference;
END// 
DELIMITER ;


CREATE VIEW ValueOfInventory AS 
SELECT users.UserID, users.UserName, 
SUM(UserLegoPieces.NumberOfPieces * LegoPieces.PiecePrice) AS TotalValue
FROM userLegoPieces
RIGHT JOIN Users ON userLegoPieces.UserID = users.UserID 
LEFT JOIN LegoPieces ON userLegoPieces.pieceID = LegoPieces.pieceID 
GROUP BY Users.UserID, Users.UserName;



SELECT * FROM ValueOfInventory;

INSERT INTO UserLegoPieces (userID, PieceID, NumberOfPieces ) VALUES
    (1, 1, 1 );

CALL GetMissingPieces(1,1);

SELECT CompareSetToPiecesPrice(1);

CALL AddSetToUser(1,1);

SELECT * FROM userLegoPieces;
SELECT * FROM userLegoSets;
SELECT * FROM users;

DROP PROCEDURE Addsettouser;
DROP PROCEDURE updateOrInsert;

DROP VIEW ValueOfInventory;

DROP TABLE users;
DROP TABLE legoSets;
DROP TABLE legopieces;

DROP TABLE legosetpieces;
DROP TABLE userLegosets;
DROP TABLE userLegoPieces;

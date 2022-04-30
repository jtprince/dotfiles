## analysis.tdf
sqlite3 analysis.tdf

```
.schema
```

```
CREATE TABLE GlobalMetadata (
    Key TEXT PRIMARY KEY,
    Value TEXT
    );
CREATE TABLE PropertyDefinitions (
    Id INTEGER PRIMARY KEY,
    PermanentName TEXT NOT NULL,
    Type INTEGER NOT NULL,
    DisplayGroupName TEXT NOT NULL,
    DisplayName TEXT NOT NULL,
    DisplayValueText TEXT NOT NULL,
    DisplayFormat TEXT NOT NULL,
    DisplayDimension TEXT NOT NULL,
    Description TEXT NOT NULL
);
CREATE UNIQUE INDEX PropertyDefinitionsIndex ON PropertyDefinitions (PermanentName);
CREATE TABLE PropertyGroups (
    Id INTEGER PRIMARY KEY
) WITHOUT ROWID;
CREATE TABLE GroupProperties (
    PropertyGroup INTEGER NOT NULL,
    Property INTEGER NOT NULL,
    Value NOT NULL,
    PRIMARY KEY (PropertyGroup, Property),
    FOREIGN KEY (PropertyGroup) REFERENCES PropertyGroups (Id),
    FOREIGN KEY (Property) REFERENCES PropertyDefinitions (Id)
) WITHOUT ROWID;
CREATE TABLE FrameProperties (
    Frame INTEGER NOT NULL,
    Property INTEGER NOT NULL,
    Value NOT NULL,
    PRIMARY KEY (Frame, Property),
    FOREIGN KEY (Frame) REFERENCES Frames (Id)
    FOREIGN KEY (Property) REFERENCES PropertyDefinitions (Id)
) WITHOUT ROWID;
CREATE TABLE FrameMsMsInfo (
    Frame INTEGER PRIMARY KEY,
    Parent INTEGER,
    TriggerMass REAL NOT NULL,
    IsolationWidth REAL NOT NULL,
    PrecursorCharge INTEGER,
    CollisionEnergy REAL NOT NULL,
    FOREIGN KEY (Frame) REFERENCES Frames (Id)
);
CREATE TABLE CalibrationInfo (
    KeyPolarity CHAR(1) CHECK (KeyPolarity IN ('+', '-')),
    KeyName TEXT,
    Value TEXT,
    PRIMARY KEY (KeyPolarity, KeyName)
    );
CREATE TABLE Segments (
    Id INTEGER PRIMARY KEY,
    FirstFrame INTEGER NOT NULL,
    LastFrame INTEGER NOT NULL,
    IsCalibrationSegment BOOLEAN NOT NULL,
    FOREIGN KEY (FirstFrame) REFERENCES Frames (Id),
    FOREIGN KEY (LastFrame) REFERENCES Frames (Id)
);
CREATE VIEW Properties AS
    SELECT s.Id Frame, pd.Id Property, COALESCE(fp.Value, gp.Value) Value
    FROM Frames s
    JOIN PropertyDefinitions pd
    LEFT JOIN GroupProperties gp ON gp.PropertyGroup=s.PropertyGroup AND gp.Property=pd.Id
    LEFT JOIN FrameProperties fp ON fp.Frame=s.Id AND fp.Property=pd.Id
/* Properties(Frame,Property,Value) */;
CREATE TABLE ErrorLog (
    Frame INTEGER NOT NULL,
    Scan INTEGER,
    Message TEXT NOT NULL
);
CREATE TABLE MzCalibration (
    Id INTEGER PRIMARY KEY,
    ModelType INTEGER NOT NULL,
    DigitizerTimebase REAL NOT NULL,
    DigitizerDelay REAL NOT NULL,
    T1 REAL NOT NULL,
    T2 REAL NOT NULL,
    dC1 REAL NOT NULL,
    dC2 REAL NOT NULL,
    C0
, C1, C2, C3, C4);
CREATE TABLE Frames (
    Id INTEGER PRIMARY KEY,
    Time REAL NOT NULL,
    Polarity CHAR(1) CHECK (Polarity IN ('+', '-')) NOT NULL,
    ScanMode INTEGER NOT NULL,
    MsMsType INTEGER NOT NULL,
    TimsId INTEGER,
    MaxIntensity INTEGER NOT NULL,
    SummedIntensities INTEGER NOT NULL,
    NumScans INTEGER NOT NULL,
    NumPeaks INTEGER NOT NULL,
    MzCalibration INTEGER NOT NULL,
    T1 REAL NOT NULL,
    T2 REAL NOT NULL,
    TimsCalibration INTEGER NOT NULL,
    PropertyGroup INTEGER,
    AccumulationTime REAL NOT NULL,
    RampTime REAL NOT NULL,
    FOREIGN KEY (MzCalibration) REFERENCES MzCalibration (Id),
    FOREIGN KEY (TimsCalibration) REFERENCES TimsCalibration (Id),
    FOREIGN KEY (PropertyGroup) REFERENCES PropertyGroups (Id)
);
CREATE UNIQUE INDEX FramesTimeIndex ON Frames (Time);
CREATE TABLE TimsCalibration (
    Id INTEGER PRIMARY KEY,
    ModelType INTEGER NOT NULL,
    C0
, C1, C2, C3, C4, C5, C6, C7, C8, C9);
CREATE TABLE DiaFrameMsMsWindowGroups (
   Id INTEGER PRIMARY KEY);
CREATE TABLE DiaFrameMsMsWindows (
   WindowGroup INTEGER NOT NULL,
   ScanNumBegin INTEGER NOT NULL,
   ScanNumEnd INTEGER NOT NULL,
   IsolationMz REAL NOT NULL,
   IsolationWidth REAL NOT NULL,
   CollisionEnergy REAL NOT NULL,
   PRIMARY KEY(WindowGroup, ScanNumBegin),
   FOREIGN KEY (WindowGroup) REFERENCES DiaFrameMsMsWindowGroups (Id)
) WITHOUT ROWID;
CREATE TABLE DiaFrameMsMsInfo (
   Frame INTEGER PRIMARY KEY,
   WindowGroup INTEGER NOT NULL,
   FOREIGN KEY (Frame) REFERENCES Frames (Id),
   FOREIGN KEY (WindowGroup) REFERENCES DiaFrameMsMsWindowGroups (Id)
);
CREATE TABLE Precursors (Id INTEGER PRIMARY KEY,
LargestPeakMz REAL NOT NULL,
AverageMz REAL NOT NULL,
MonoisotopicMz REAL,
Charge INTEGER,
ScanNumber REAL NOT NULL,
Intensity REAL NOT NULL,
Parent INTEGER,
FOREIGN KEY(Parent) REFERENCES Frames(Id)
);
CREATE INDEX PrecursorsParentIndex ON Precursors (Parent);
CREATE TABLE PasefFrameMsMsInfo (
   Frame INTEGER NOT NULL,
   ScanNumBegin INTEGER NOT NULL,
   ScanNumEnd INTEGER NOT NULL,
   IsolationMz REAL NOT NULL,
   IsolationWidth REAL NOT NULL,
   CollisionEnergy REAL NOT NULL,
   Precursor INTEGER,
   PRIMARY KEY(Frame, ScanNumBegin),
   FOREIGN KEY(Frame) REFERENCES Frames(Id),
   FOREIGN KEY(Precursor) REFERENCES Precursors(Id)
) WITHOUT ROWID;
CREATE INDEX PasefFrameMsMsInfoPrecursorIndex ON PasefFrameMsMsInfo (Precursor);
```

### CalibrationInfo

select KeyName from CalibrationInfo;
```
CalibrationDateTime
CalibrationMobilogramDescription
CalibrationSoftware
CalibrationSoftwareVersion
CalibrationUser
MassesCorrectedCalibration
MassesPreviousCalibration
MeasuredMassPeakIntensities
MeasuredMobilityPeakIntensities
MeasuredTimesOfFlight
MeasuredTimsVoltages
MobilitiesCorrectedCalibration
MobilitiesPreviousCalibration
MobilityCalibrationDateTime
MobilityCalibrationUser
MobilityStandardDeviationPercent
MzCalibrationMode
MzCalibrationSpectrumDescription
MzStandardDeviationPPM
ReferenceMassList
ReferenceMassPeakNames
ReferenceMobilityList
ReferenceMobilityPeakNames
ReferencePeakMasses
ReferencePeakMobilities
CalibrationDateTime
CalibrationMobilogramDescription
CalibrationSoftware
CalibrationSoftwareVersion
CalibrationUser
MassesCorrectedCalibration
MassesPreviousCalibration
MeasuredMassPeakIntensities
MeasuredMobilityPeakIntensities
MeasuredTimesOfFlight
MeasuredTimsVoltages
MobilitiesCorrectedCalibration
MobilitiesPreviousCalibration
MobilityCalibrationDateTime
MobilityCalibrationUser
MobilityStandardDeviationPercent
MzCalibrationMode
MzCalibrationSpectrumDescription
MzStandardDeviationPPM
ReferenceMassList
ReferenceMassPeakNames
ReferenceMobilityList
ReferenceMobilityPeakNames
ReferencePeakMasses
ReferencePeakMobilities
```

### FrameProperties

Precursors

### DiaFrameMsMsInfo


### Frames


### Properties


### DiaFrameMsMsWindowGroups


### GlobalMetadata



### PropertyDefinitions


### DiaFrameMsMsWindows


### GroupProperties


### PropertyGroups


### ErrorLog


### MzCalibration


### Segments


### FrameMsMsInfo


### PasefFrameMsMsInfo


### TimsCalibration

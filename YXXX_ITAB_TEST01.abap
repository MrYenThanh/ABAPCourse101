*&---------------------------------------------------------------------*
*& Report YXXX_ITAB_TEST01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YXXX_ITAB_TEST01 NO STANDARD PAGE HEADING.

*&---------------------------------------------------------------------*
*& DATA DECLARATION
*&---------------------------------------------------------------------*

* Declare a structure TY_REPORT for final report
TYPES: BEGIN OF TY_REPORT,
        COUNTRYFR  TYPE SPFLI-COUNTRYFR,
        CITYFROM   TYPE SPFLI-CITYFROM,
        COUNTRYTO  TYPE SPFLI-COUNTRYTO,
        CITYTO     TYPE SPFLI-CITYTO,
        FLDATE     TYPE SFLIGHT-FLDATE,
        CARRID     TYPE SPFLI-CARRID,
        CONNID     TYPE SPFLI-CONNID,
        DEPTIME    TYPE SPFLI-DEPTIME,
        ARRTIME    TYPE SPFLI-ARRTIME,
        PERIOD     TYPE SPFLI-PERIOD,
        SEATSMAX   TYPE SFLIGHT-SEATSMAX,   " So ghe khoang Economy
        SEATSMAX_B TYPE SFLIGHT-SEATSMAX_B, " So ghe khoang Business
        SEATSMAX_F TYPE SFLIGHT-SEATSMAX_F, " So ghe khoang First Class
        SEATSOCC   TYPE SFLIGHT-SEATSOCC,   " So ghe Economy da dat
        SEATSOCC_B TYPE SFLIGHT-SEATSOCC_B, " So ghe Business da dat
        SEATSOCC_F TYPE SFLIGHT-SEATSOCC_F, " So ghe First Class  da dat
       END OF   TY_REPORT.
* Declare a structure TY_COUNTRY to store Country Name
TYPES: BEGIN OF TY_COUNTRY,
        LAND1      TYPE T005T-LAND1, " Country Code
        LANDX      TYPE T005T-LANDX, " Country Name
       END OF   TY_COUNTRY.

* Create an internal table from TY_REPORT
DATA: GT_REPORT TYPE STANDARD TABLE OF TY_REPORT.
* Create a work area from TY_REPORT
DATA: GS_REPORT TYPE TY_REPORT.

* Create a sorted table from structure TY_COUNTRY to store Country Name
DATA: GT_COUNTRY_TEXT TYPE SORTED TABLE OF TY_COUNTRY
            WITH UNIQUE KEY LAND1.

* Create a sorted table from Table Name SCARR to store Airliner Name
DATA: GT_SCARR TYPE SORTED TABLE OF SCARR
            WITH NON-UNIQUE KEY CARRID.

*&---------------------------------------------------------------------*
*& SELECTION SCREEN
*&---------------------------------------------------------------------*

SELECTION-SCREEN SKIP 1.
* Create select-options S_FLDATE for SFLIGHT~FLDATE
SELECT-OPTIONS: S_FLDATE FOR  GS_REPORT-FLDATE.
* Create select-options S_CARRID for SPFLI~CARRID
SELECT-OPTIONS: S_CARRID FOR  GS_REPORT-CARRID.
* Create select-options S_CONNID for SPFLI~CONNID
SELECT-OPTIONS: S_CONNID FOR  GS_REPORT-CONNID.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: S_CTRFR  FOR GS_REPORT-COUNTRYFR.

SELECT-OPTIONS: S_CTYFR  FOR GS_REPORT-CITYFROM.

SELECT-OPTIONS: S_CTRTO  FOR GS_REPORT-COUNTRYTO.

SELECT-OPTIONS: S_CTYTO  FOR GS_REPORT-CITYTO.

SELECTION-SCREEN SKIP 1.

START-OF-SELECTION.

*- 1. Select data from SFLIGHT inner join SPFLI

* Select data from SFLIGHT inner join SPFLI
**************************************************************************************
*   Into: Standard Table of TY_REPORT
**************************************************************************************
*   Join Condition: SFLIGHT~CARRID = SPFLI~CARRID and SFLIGHT~CONNID = SPFLI~CONNID
**************************************************************************************
*   Query Condition:     SFLIGHT~FLDATE  IN S_FLDATE
*                    AND SPFLI~CARRID    IN S_CARRID
*                    AND SPFLI~CONNID    IN S_CONNID
*                    AND SPFLI~COUNTRYFR IN S_CTRFR
*                    AND SPFLI~CITYFROM  IN S_CTYFR
*                    AND SPFLI~COUNTRYTO IN S_CTRTO
*                    AND SPFLI~CITYTO    IN S_CTYTO
**************************************************************************************
*   Order By:        SPFLI~CITYFROM
*                    SPFLI~CITYTO
*                    SFLIGHT~FLDATE
*                    SPFLI~DEPTIME
*                    SPFLI~ARRTIME
**************************************************************************************
*   SELECT fields:   SFLIGHT~FLDATE      " Flight Date
*                    SPFLI~CARRID        " Airliner
*                    SPFLI~CONNID        " Flight Number
*                    SPFLI~COUNTRYFR     " From Country
*                    SPFLI~CITYFROM      " From City
*                    SPFLI~COUNTRYTO     " To Country
*                    SPFLI~CITYTO        " To City
*                    SPFLI~DEPTIME       " Departure Time
*                    SPFLI~ARRTIME       " Arrival Time
*                    SPFLI~PERIOD        " Flight Period in Days
*                    SFLIGHT~SEATSMAX,   " Max seats in Economy
*                    SFLIGHT~SEATSMAX_B, " Max seats in Business Class
*                    SFLIGHT~SEATSMAX_F, " Max seats in First Class
*                    SFLIGHT~SEATSOCC,   " Occupied seats in Economy
*                    SFLIGHT~SEATSOCC_B, " Occupied seats in Business Class
*                    SFLIGHT~SEATSOCC_F  " Occupied seats in First Class
**************************************************************************************

*- 2. Select data from Country Text Table T005T

* Select data from Country Text Table T005T
**************************************************************************************
*   Into: Sorted Table of TY_COUNTRY
**************************************************************************************
*   Join Condition:  N/A
**************************************************************************************
*   Query Condition: SPRAS (Language) = SY-LANGU (Logon Language)
**************************************************************************************
*   Order By:        N/A
**************************************************************************************
*   SELECT fields:   LAND1    " Country code
*                    LANDX    " Country Name
**************************************************************************************

*- 3. Select data from Airline Table SCARR

* Select data from Airline Table SCARR
**************************************************************************************
*   Into: Sorted Table of SCARR
**************************************************************************************
*   Join Condition:  N/A
**************************************************************************************
*   Query Condition: N/A
**************************************************************************************
*   Order By:        N/A
**************************************************************************************
*   SELECT fields:   *
**************************************************************************************

*- 4. Loop at internal table of TY_REPORT to output report
*
*     4.1. At new block of FLDATE, CARRID, CONNID, COUNTRYFR, CITYFROM, COUNTRYTO, CITYTO
*
*          Read Sorted Table of TY_COUNTRY into a work area (Work Area: Country From)
*               using table key LAND1 = COUNTRYFR of current looping record
*
*          Read Sorted Table of TY_COUNTRY into a work area (Work Area: Country To)
*               using table key LAND1 = COUNTRYTO of current looping record
*
*          Output Country From and Country To
*            WRITE: /(20) 'Country From :', (20) GS_COUNTRYFR-LANDX, (20) ' - Country From :', (20) GS_COUNTRYTO-LANDX.
*
*          Output City From and City To
*            WRITE: /(20) 'City From :', (20) GS_REPORT-CITYFROM, (20) ' - City To :', (20) GS_REPORT-CITYTO.
*
*          Output column header for the list of flights
*            WRITE: /(12) 'Flight Date',
*                    (12) 'Airline Cd',
*                    (20) 'Airline Name',
*                    (20) 'Flight Number',
*                    (20) 'Depart Time',
*                    (20) 'Arrival Time',
*                    (15) 'Free Seats'.
*
*     4.2. For every line of the loop
*
*          Read Sorted Table of SCARR into a work area
*               using table key CARRID = CARRID of current looping record
*
*          Calculate free seat: ( SEATSMAX - SEATSOCC ) + ( SEATSMAX_B - SEATSOCC_B ) + ( SEATSMAX_F - SEATSOCC_F )
*
*          Output list of flights
*            WRITE: /(12) FLDATE,
*                    (12) CARRID,
*                    (20) CARRNAME,
*                    (20) CONNID,
*                    (20) DEPTIME,
*                    (20) ARRTIME,
*                    (15) Calculated free seats.


  SELECT SFLIGHT~FLDATE,
         SPFLI~CARRID,
         SPFLI~CONNID,
         SPFLI~COUNTRYFR,
         SPFLI~CITYFROM,
         SPFLI~COUNTRYTO,
         SPFLI~CITYTO,
         SPFLI~DEPTIME,
         SPFLI~ARRTIME,
         SPFLI~PERIOD,
         SFLIGHT~SEATSMAX,   " So ghe khoang Economy
         SFLIGHT~SEATSMAX_B, " So ghe khoang Business
         SFLIGHT~SEATSMAX_F, " So ghe khoang First Class
         SFLIGHT~SEATSOCC,   " So ghe Economy da dat
         SFLIGHT~SEATSOCC_B, " So ghe Business da dat
         SFLIGHT~SEATSOCC_F  " So ghe First Class  da dat
    FROM SFLIGHT INNER JOIN SPFLI
      ON     SFLIGHT~CARRID = SPFLI~CARRID
         AND SFLIGHT~CONNID = SPFLI~CONNID
    INTO CORRESPONDING FIELDS OF TABLE @GT_REPORT
    WHERE SFLIGHT~FLDATE  IN @S_FLDATE
      AND SPFLI~CARRID    IN @S_CARRID
      AND SPFLI~CONNID    IN @S_CONNID
      AND SPFLI~COUNTRYFR IN @S_CTRFR
      AND SPFLI~CITYFROM  IN @S_CTYFR
      AND SPFLI~COUNTRYTO IN @S_CTRTO
      AND SPFLI~CITYTO    IN @S_CTYTO
    ORDER BY SPFLI~CITYFROM,
             SPFLI~CITYTO,
             SFLIGHT~FLDATE,
             SPFLI~DEPTIME,
             SPFLI~ARRTIME.

  SELECT LAND1 LANDX FROM T005T INTO TABLE GT_COUNTRY_TEXT
    WHERE SPRAS = SY-LANGU.

  SELECT * FROM SCARR INTO TABLE GT_SCARR.



  LOOP AT GT_REPORT INTO GS_REPORT.

    AT NEW CITYTO.
      READ TABLE GT_COUNTRY_TEXT INTO DATA(GS_COUNTRYFR)
        WITH TABLE KEY LAND1 = GS_REPORT-COUNTRYFR.

      READ TABLE GT_COUNTRY_TEXT INTO DATA(GS_COUNTRYTO)
        WITH TABLE KEY LAND1 = GS_REPORT-COUNTRYTO.

      WRITE: /(20) 'Country From :', (20) GS_COUNTRYFR-LANDX, (20) ' - Country From :', (20) GS_COUNTRYTO-LANDX.

      WRITE: /(20) 'City From :', (20) GS_REPORT-CITYFROM, (20) ' - City To :', (20) GS_REPORT-CITYTO.

      ULINE.

      FORMAT COLOR COL_HEADING.
        WRITE: /(12) 'Flight Date',
                (12) 'Airline Cd',
                (20) 'Airline Name',
                (20) 'Flight Number',
                (20) 'Depart Time',
                (20) 'Arrival Time',
                (15) 'Free Seats' RIGHT-JUSTIFIED.
      FORMAT COLOR OFF.

      ULINE.

    ENDAT.

    READ TABLE GT_SCARR INTO DATA(GS_SCARR)
      WITH TABLE KEY CARRID = GS_REPORT-CARRID.

    DATA(GD_FREE_SEATS) = GS_REPORT-SEATSMAX - GS_REPORT-SEATSOCC.
    GD_FREE_SEATS += GS_REPORT-SEATSMAX_B - GS_REPORT-SEATSOCC_B.
    GD_FREE_SEATS += GS_REPORT-SEATSMAX_F - GS_REPORT-SEATSOCC_F.

    FORMAT COLOR COL_NORMAL.
    WRITE: /(12) GS_REPORT-FLDATE,
            (12) GS_REPORT-CARRID,
            (20) GS_SCARR-CARRNAME,
            (20) GS_REPORT-CONNID,
            (20) GS_REPORT-DEPTIME,
            (20) GS_REPORT-ARRTIME,
            (15) GD_FREE_SEATS.
    FORMAT COLOR OFF.

    AT END OF CITYTO.
*      ULINE.
*      FORMAT COLOR COL_TOTAL.
*      WRITE: /(60) 'Total Free Seats',
*              (20) GD_TOTAL CURRENCY GS_SCARR-CURRCODE, (3) GS_SCARR-CURRCODE.
*      FORMAT COLOR OFF.
      ULINE.
      SKIP 1.

      NEW-PAGE.
    ENDAT.
  ENDLOOP.

*&---------------------------------------------------------------------*
*& Report YXXX_MOD_PART00
*&---------------------------------------------------------------------*
*& Starting Example
*&---------------------------------------------------------------------*
REPORT YXXX_MOD_PART00.

* Declare Flight Schedule structure
TYPES: BEGIN OF TY_FLISCH,
          CARRID      TYPE SPFLI-CARRID,    " Airline
          CARRNAME    TYPE SCARR-CARRNAME,  " Airline Name
          CONNID      TYPE SPFLI-CONNID,    " Flight Number
          CITYFROM    TYPE SPFLI-CITYFROM,
          CITYTO      TYPE SPFLI-CITYTO,
          COUNTRYFR   TYPE SPFLI-COUNTRYFR, " Country From
          COUNTRYFRNM TYPE T005T-LANDX,     " Country Name
          COUNTRYTO   TYPE SPFLI-COUNTRYTO, " Country to
          COUNTRYTONM TYPE T005T-LANDX,     " Country Name
       END OF   TY_FLISCH.

* Declare Airline Name structure
TYPES: BEGIN OF TY_AIRLINE,
          CARRID    TYPE SCARR-CARRID,    " Airline
          CARRNAME  TYPE SCARR-CARRNAME,  " Airline Name
       END OF TY_AIRLINE.

* Declare Country Name structure
TYPES: BEGIN OF TY_COUNTRY,
          COUNTRYCD   TYPE T005T-LAND1,  " Country code
          COUNTRYNAME TYPE T005T-LANDX,  " Country Name
       END OF   TY_COUNTRY.

* Declare Flight Schedule internal table
DATA: GT_FLISCH TYPE STANDARD TABLE OF TY_FLISCH.

* Declare Airline Name internal table
DATA: GT_S_AIRLINE TYPE SORTED TABLE OF TY_AIRLINE
                        WITH NON-UNIQUE KEY CARRID.

* Declare Country Name internal table
DATA: GT_S_COUNTRY TYPE SORTED TABLE OF TY_COUNTRY
                        WITH NON-UNIQUE KEY COUNTRYCD.

**** Declare Selection Screen ****
PARAMETERS: P_CARRID TYPE SPFLI-CARRID OBLIGATORY.

**** Excute Event ****
START-OF-SELECTION.

* Get data Flight Schedule
  SELECT CARRID
         CONNID
         CITYFROM
         CITYTO
         COUNTRYFR
         COUNTRYTO
    FROM SPFLI INTO CORRESPONDING FIELDS OF TABLE GT_FLISCH
    WHERE CARRID = P_CARRID.
  IF SY-SUBRC <> 0.
    MESSAGE 'Data not found' TYPE 'E'.
  ENDIF.

* Get data of Airline Name
  SELECT CARRID
         CARRNAME
    FROM SCARR INTO TABLE GT_S_AIRLINE.
  IF SY-SUBRC <> 0.
    " No need to handle error
  ENDIF.

* Get data of Country Name
  SELECT LAND1 AS COUNTRYCD
         LANDX AS COUNTRYNAME
    FROM T005T INTO TABLE GT_S_COUNTRY
    WHERE SPRAS = SY-LANGU.
  IF SY-SUBRC <> 0.
    " No need to handle error
  ENDIF.

* Modify data of Flight Schedule for outputing
  LOOP AT GT_FLISCH ASSIGNING FIELD-SYMBOL(<GFS_FLISCH>).
*   Get and set Airline Name
    READ TABLE GT_S_AIRLINE
      INTO DATA(GS_AIRLINE)
      WITH TABLE KEY CARRID = <GFS_FLISCH>-CARRID.
    IF SY-SUBRC = 0. " Success
      <GFS_FLISCH>-CARRNAME = GS_AIRLINE-CARRNAME.
    ENDIF.

*   Get and set Country From Name
    READ TABLE GT_S_COUNTRY
      INTO DATA(GS_COUNTRYFR)
      WITH TABLE KEY COUNTRYCD = <GFS_FLISCH>-COUNTRYFR.
    IF SY-SUBRC = 0. " Success
      <GFS_FLISCH>-COUNTRYFRNM = GS_COUNTRYFR-COUNTRYNAME.
    ENDIF.

*   Get and set Country To Name
    READ TABLE GT_S_COUNTRY
      INTO DATA(GS_COUNTRYTO)
      WITH TABLE KEY COUNTRYCD = <GFS_FLISCH>-COUNTRYTO.
    IF SY-SUBRC = 0. " Success
      <GFS_FLISCH>-COUNTRYTONM = GS_COUNTRYTO-COUNTRYNAME.
    ENDIF.
  ENDLOOP.

* Output data
  FORMAT COLOR COL_HEADING.
  WRITE: /(10) 'Airline',
          (20) 'Airline Name',
          (12) 'Flight No.',
          (20) 'City From',
          (20) 'City To',
          (20) 'Country From',
          (20) 'Country to'.
  FORMAT COLOR OFF.

  LOOP AT GT_FLISCH INTO DATA(GS_FLISCH).
    WRITE: /(10) GS_FLISCH-CARRID,
            (20) GS_FLISCH-CARRNAME,
            (12) GS_FLISCH-CONNID,
            (20) GS_FLISCH-CITYFROM,
            (20) GS_FLISCH-CITYTO,
            (4)  GS_FLISCH-COUNTRYFR,
            (15) GS_FLISCH-COUNTRYFRNM,
            (4)  GS_FLISCH-COUNTRYTO,
            (15) GS_FLISCH-COUNTRYTONM.
  ENDLOOP.

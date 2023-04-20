// Programa   : DPCALAXIACT
// Fecha/Hora : 05/08/2011 00:04:53
// Propósito  : Calcular Ajuste Por Inflación de Activos
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dFchAjs,cModAjs,oMeter,oSay)
  LOCAL oFor,aVars:={},cVar,oScript,oActivo
  LOCAL A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,Z
  LOCAL aFor:={},cTipAjs:="I"
  LOCAL oTable

  IF( ValType(oSay)="O", oSay:SetText("Cargando Fórmulas"),NIL)

  PUBLICO("oAxi")

  DEFAULT dFchAjs:=oDp:dFchInicio,;
          cModAjs:="FS"


  /*
  // Actualiza Estructura
  */

  EJECUTAR("DPFORAXITOTABL")

  oAxi:=TPublic():New( .T. )

  oFor:=OpenTable("SELECT * FROM DPFORMULAAXIACT ORDER BY FAA_CODIGO",.T.)

  WHILE !oFor:Eof()

    oScript:=TScript():New(oFor:FAA_FORMUL)
    oScript:Compile()
    oScript:cProgram:=oFor:FAA_CODIGO // Nombre del Programa
    oScript:cError:=""

    AADD(aFor,oScript)

    oFor:DbSkip()

  ENDDO

  oTable:=OpenTable("SELECT * FROM DPAFIACT",.F.)            

  oActivo:=OpenTable("SELECT * FROM DPACTIVOS ",.T.)           

  IF( ValType(oMeter)="O", oMeter:SetTotal(oActivo:RecCount()),NIL)

  WHILE !oActivo:EOF()

    /*
    // Debe Crear los Campos como Variables, para su utilización en las Fórmulas
    */

    IF( ValType(oMeter)="O", oMeter:Set(oActivo:RecNo()),NIL)

    IF( ValType(oSay)  ="O", oSay:SetText("Código: "+oActivo:ATV_CODIGO),NIL)

    aVars  :={}

    AEVAL(oActivo:aFields,{|a,n| PUBLICO(oActivo:aFields[n,1],oActivo:FieldGet(n))})

    oFor:Gotop()

    WHILE !oFor:Eof()

      cVar:=ALLTRIM(oFor:FAA_CODIGO)

      PUBLICO(cVar,NIL)

      oAxi:nAjusteI:=NIL
      oAxi:nAjusteR:=NIL

      oScript:=aFor[oFor:RecNo()]

      nResult:=oScript:Run() // Ejecuta los Par+metros

      IF !oAxi:nAjusteI=NIL
        PUBLICO(cVar,oAxi:nAjusteI)
      ELSE
        PUBLICO(cVar,oAxi:nAjusteF)
      ENDIF

      AADD(aVars,{cVar,&cVar})
    
      oFor:DbSkip()

    ENDDO

    oTable:AppendBlank()

    AEVAL(aVars,{|a,n| oTable:Replace("AFI_"+a[1],a[2]) })

    oTable:Commit()

    oActivo:DbSkip()

  ENDDO

  oTable:End()

  ViewArray(aVars)

RETURN

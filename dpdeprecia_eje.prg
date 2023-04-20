// Programa   : DPDEPRECIA_EJE
// Fecha/Hora : 22/10/2014 17:03:10
// Propósito  : Asignar Numero de Ejercicios a Depreciaciones
// Creado Por : Juan Navas
// Llamado por: SQLDB_POSTUPDAT y Creacion de Integridad Referencial
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL oTable,cNumEje:="",dFchMax,nMeses

   CheckTable("DPDEPRECIAACT")

   IF !ISFIELD("DPDEPRECIAACT","DEP_NUMEJE")
      RETURN .T.
   ENDIF

   oTable:=OpenTable(" SELECT DEP_CODSUC,DEP_CODACT,DEP_FECHA,DEP_TIPTRA,ATV_VIDA_A,ATV_VIDA_M,ATV_MESDEP "+;
                     " FROM DPDEPRECIAACT "+;
                     " INNER JOIN DPACTIVOS ON ATV_CODIGO=DEP_CODACT "+;
                     " WHERE DEP_NUMEJE"+GetWhere("=","")+" OR "+;
                     " DEP_NUMEJE IS NULL ",.T.)

   WHILE !oTable:Eof()

      cNumEje:=EJECUTAR("GETNUMEJE",oTable:DEP_FECHA)

      nMeses :=((oTable:ATV_VIDA_A*12)+oTable:ATV_VIDA_M)-oTable:ATV_MESDEP

      dFchMax:=FCHFINMES(oTable:ATV_FCHDEP) 

       // Calcula la Fecha de Conclusion del Activo
      AEVAL(ARRAY(nMeses),{|a,n| dFchMax:=FCHFINMES(dFchMax)+1 })


      SQLUPDATE("DPDEPRECIAACT",{"DEP_NUMEJE"},;
                                {cNumEje  },;
                                "DEP_CODSUC"+GetWhere("=",oTable:DEP_CODSUC)+" AND "+;
                                "DEP_CODACT"+GetWhere("=",oTable:DEP_CODACT)+" AND "+;
                                "DEP_FECHA "+GetWhere("=",oTable:DEP_FECHA )+" AND "+;
                                "DEP_TIPTRA"+GetWhere("=",oTable:DEP_TIPTRA))

      // Actualiza la Fecha Maxima del Activo
      SQLUPDATE("DPACTIVOS",{"DEP_FCHMAX"},{dFchMax},;
                            "ATV_CODSUC"+GetWhere("=",oTable:DEP_CODSUC)+" AND "+;
                            "ATV_CODIGO"+GetWhere("=",oTable:DEP_CODACT))

      oTable:DbSkip()

   ENDDO

   oTable:End()

RETURN .F.

// EOF


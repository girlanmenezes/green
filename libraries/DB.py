import Conection
import datetime
#from ..resources.variables import TODAY, RETROATIVA

class DB:
    def get_dados_banco(self):
        date_now = datetime.datetime.now()
        date_retroativa = date_now - datetime.timedelta(days=70)

        TODAY = date_now.strftime("%d%m%Y")
        RETROATIVA = date_retroativa.strftime("%d%m%Y")
        print(TODAY)
        print(RETROATIVA)
       
        #query = "SELECT DISTINCT TM.NR_DOCUMENTO AS cdRemessa , TG.CD_REG_FAT AS cdConta, TG.CD_CONVENIO AS cdConvenio , TG.CD_ATENDIMENTO AS cdAtendimento , TM.NR_LOTE AS grd , A.DS_AGRUPAMENTO AS agrupamento , TM.NR_PROTOCOLO_RETORNO AS nrProtocolo , TG.NR_GUIA AS nrGuia , TG.CD_SENHA AS senhaGuia , TG.CD_OPERADORA_EXE AS cdReferenciado , TG.NR_CARTEIRA AS cdSegurado , TO_CHAR(RF.DT_FECHAMENTO, 'DD/MM/YYYY HH24:MI:SS') AS dtRetorno FROM DBAMV.TISS_MENSAGEM TM , DBAMV.TISS_LOTE TL , DBAMV.TISS_GUIA TG , DBAMV.REMESSA_FATURA RF , DBAMV.AGRUPAMENTO A WHERE RF.CD_AGRUPAMENTO = A.CD_AGRUPAMENTO AND TM.NR_PROTOCOLO_RETORNO IS NOT NULL AND TM.TP_TRANSACAO = 'ENVIO_LOTE_GUIAS' AND TM.ID = TL.ID_PAI AND TL.ID = TG.ID_PAI AND TM.NR_DOCUMENTO = TO_CHAR(RF.CD_REMESSA) AND TG.CD_CONVENIO IN ( 59,104,236 ) AND TRUNC(RF.DT_FECHAMENTO) BETWEEN TO_DATE(" + TODAY+ ", 'DD/MM/YYYY') AND TO_DATE(" + RETROATIVA + ", 'DD/MM/YYYY')"
        query = "SELECT DISTINCT TM.NR_DOCUMENTO AS cdRemessa , TG.CD_REG_FAT AS cdConta, TG.CD_CONVENIO AS cdConvenio , TG.CD_ATENDIMENTO AS cdAtendimento , TM.NR_LOTE AS grd , A.DS_AGRUPAMENTO AS agrupamento , TM.NR_PROTOCOLO_RETORNO AS nrProtocolo , TG.NR_GUIA AS nrGuia , TG.CD_SENHA AS senhaGuia , TG.CD_OPERADORA_EXE AS cdReferenciado , TG.NR_CARTEIRA AS cdSegurado , TO_CHAR(RF.DT_FECHAMENTO, 'DD/MM/YYYY HH24:MI:SS') AS dtRetorno FROM DBAMV.TISS_MENSAGEM TM , DBAMV.TISS_LOTE TL , DBAMV.TISS_GUIA TG , DBAMV.REMESSA_FATURA RF , DBAMV.AGRUPAMENTO A WHERE RF.CD_AGRUPAMENTO = A.CD_AGRUPAMENTO AND TM.NR_PROTOCOLO_RETORNO IS NOT NULL AND TM.TP_TRANSACAO = 'ENVIO_LOTE_GUIAS' AND TM.ID = TL.ID_PAI AND TL.ID = TG.ID_PAI AND TM.NR_DOCUMENTO = TO_CHAR(RF.CD_REMESSA) AND TG.CD_CONVENIO IN ( 59,104,236 ) AND TRUNC(RF.DT_FECHAMENTO) BETWEEN TO_DATE('20/09/2008', 'DD/MM/YYYY') AND TO_DATE('20/09/2008', 'DD/MM/YYYY')"

        conecction = Conection.Banco.create_db_connection()
        results = Conection.Banco.read_query(conecction, query)

        if results is None or results == []:
            results = False


        return results

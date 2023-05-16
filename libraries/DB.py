import Conection
from ..resources.variables import TODAY

class DB:
    def get_dados(self):
        query = "SELECT DISTINCT TM.NR_DOCUMENTO AS cdRemessa, \
            TG.CD_CONVENIO AS cdConvenio , \
            TG.CD_ATENDIMENTO AS cdAtendimento , \
            TM.NR_LOTE AS grd , \
            A.DS_AGRUPAMENTO AS agrupamento , \
            TM.NR_PROTOCOLO_RETORNO AS nrProtocolo , \
            TG.NR_GUIA AS nrGuia , TG.CD_SENHA AS senhaGuia , \
            TG.CD_OPERADORA_EXE AS cdReferenciado , \
            TG.NR_CARTEIRA AS cdSegurado , \
            TO_CHAR(RF.DT_FECHAMENTO, 'DD/MM/YYYY HH24:MI:SS') AS dtRetorno \
            FROM DBAMV.TISS_MENSAGEM TM , \
            DBAMV.TISS_LOTE TL , \
            DBAMV.TISS_GUIA TG , \
            DBAMV.REMESSA_FATURA RF , \
            DBAMV.AGRUPAMENTO A WHERE RF.CD_AGRUPAMENTO = A.CD_AGRUPAMENTO \
            AND TM.NR_PROTOCOLO_RETORNO IS NOT NULL \
            AND TM.TP_TRANSACAO = 'ENVIO_LOTE_GUIAS' \
            AND TM.ID = TL.ID_PAI AND TL.ID = TG.ID_PAI \
            AND TM.NR_DOCUMENTO = TO_CHAR(RF.CD_REMESSA) fetch  first 10 ROWS ONLY\
            AND TG.CD_CONVENIO IN ( 59,104,236 ) AND TRUNC(RF.DT_FECHAMENTO) = TRUNC(TO_DATE('"+TODAY+", 'DD/MM/YYYY'))"

        conecction = Conection.Banco.create_db_connection()
        results = Conection.Banco.read_query(conecction, query)

        return results

# -*- coding: utf-8 -*-
"""
Biblioteca para registrar atendimentos com status de erro e enviar relatório por email
ao final da execução de todos os robôs.
"""

import os
import smtplib
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


class EmailErrosAtendimento:
    """Registra atendimentos com erro e envia relatório por email ao final da execução."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    _erros = []

    def registrar_atendimento_erro(
        self,
        cd_atendimento,
        nr_conta,
        tela,
        empresa,
        motivo="",
    ):
        """Registra um atendimento que falhou para inclusão no relatório de email.

        Args:
            cd_atendimento: Código do atendimento
            nr_conta: Número da conta
            tela: Tela (ex: M_LAN_HOS, M_LAN_AMB)
            empresa: Código da empresa (ex: 1, 2)
            motivo: Descrição opcional do motivo do erro
        """
        registro = {
            "cd_atendimento": cd_atendimento,
            "nr_conta": nr_conta,
            "tela": tela,
            "empresa": empresa,
            "motivo": motivo or "Erro na execução",
            "data_hora": datetime.now().strftime("%d/%m/%Y %H:%M:%S"),
        }
        self._erros.append(registro)

    def obter_lista_erros(self):
        """Retorna a lista de atendimentos com erro registrados."""
        return list(self._erros)

    def obter_quantidade_erros(self):
        """Retorna a quantidade de atendimentos com erro registrados."""
        return len(self._erros)

    def enviar_email_atendimentos_erro(
        self,
        destinatarios,
        smtp_server=None,
        smtp_port=None,
        smtp_user=None,
        smtp_senha=None,
        remetente=None,
        use_tls=True,
    ):
        """Envia por email o relatório de atendimentos com status de erro.

        Se não houver erros registrados, não envia email.
        Após enviar com sucesso, a lista de erros é limpa.

        Configuração pode vir dos argumentos ou das variáveis de ambiente:
        - SMTP_SERVER, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, EMAIL_REMETENTE, EMAIL_DESTINATARIOS

        Args:
            destinatarios: Email(s) destinatário(s) - string com emails separados por ; ou lista
            smtp_server: Servidor SMTP (ou env SMTP_SERVER)
            smtp_port: Porta SMTP (ou env SMTP_PORT, default 587)
            smtp_user: Usuário SMTP (ou env SMTP_USER)
            smtp_senha: Senha SMTP (ou env SMTP_PASSWORD)
            remetente: Email remetente (ou env EMAIL_REMETENTE, default = smtp_user)
            use_tls: Usar TLS (default True)

        Returns:
            True se enviou ou não havia erros; False se falhou ao enviar
        """
        if not self._erros:
            return True

        smtp_server = smtp_server or os.environ.get("SMTP_SERVER", "")
        try:
            smtp_port = int(smtp_port or os.environ.get("SMTP_PORT") or "587")
        except (TypeError, ValueError):
            smtp_port = 587
        smtp_user = smtp_user or os.environ.get("SMTP_USER", "")
        smtp_senha = smtp_senha or os.environ.get("SMTP_PASSWORD", "")
        remetente = remetente or os.environ.get("EMAIL_REMETENTE", smtp_user)

        if isinstance(destinatarios, str):
            destinatarios = [e.strip() for e in destinatarios.split(";") if e.strip()]
        if not destinatarios and os.environ.get("EMAIL_DESTINATARIOS"):
            destinatarios = [
                e.strip()
                for e in os.environ.get("EMAIL_DESTINATARIOS", "").split(";")
                if e.strip()
            ]

        if not smtp_server or not smtp_user or not smtp_senha or not destinatarios:
            raise ValueError(
                "Configuração de email incompleta. Informe smtp_server, smtp_user, "
                "smtp_senha e destinatarios ou defina as variáveis de ambiente."
            )

        html = self._montar_corpo_email()
        msg = MIMEMultipart("alternative")
        msg["Subject"] = f"[RPA Green] Relatório de atendimentos com erro - {len(self._erros)} registro(s)"
        msg["From"] = remetente
        msg["To"] = "; ".join(destinatarios)
        msg.attach(MIMEText(html, "html", "utf-8"))

        try:
            with smtplib.SMTP(smtp_server, smtp_port) as server:
                if use_tls:
                    server.starttls()
                server.login(smtp_user, smtp_senha)
                server.sendmail(remetente, destinatarios, msg.as_string())
            self._erros.clear()
            return True
        except Exception as e:
            raise RuntimeError(f"Falha ao enviar email de atendimentos com erro: {e}") from e

    def _montar_corpo_email(self):
        """Gera o HTML do corpo do email com tabela de erros."""
        linhas = []
        for r in self._erros:
            linhas.append(
                f"<tr>"
                f"<td>{r['cd_atendimento']}</td>"
                f"<td>{r['nr_conta']}</td>"
                f"<td>{r['tela']}</td>"
                f"<td>{r['empresa']}</td>"
                f"<td>{r['motivo']}</td>"
                f"<td>{r['data_hora']}</td>"
                f"</tr>"
            )
        tabela = "\n".join(linhas)
        return f"""
        <!DOCTYPE html>
        <html>
        <head><meta charset="utf-8"></head>
        <body>
        <h2>Relatório de atendimentos com status de erro</h2>
        <p>Total de registros com erro: <strong>{len(self._erros)}</strong></p>
        <p>Data do relatório: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}</p>
        <table border="1" cellpadding="6" cellspacing="0" style="border-collapse: collapse;">
        <thead>
        <tr style="background-color: #f0f0f0;">
        <th>Cód. Atendimento</th><th>Nr. Conta</th><th>Tela</th><th>Empresa</th><th>Motivo</th><th>Data/Hora</th>
        </tr>
        </thead>
        <tbody>
        {tabela}
        </tbody>
        </table>
        <p><em>Este email foi gerado automaticamente pelo RPA Green.</em></p>
        </body>
        </html>
        """

    def limpar_erros(self):
        """Remove todos os registros de erro (sem enviar email)."""
        self._erros.clear()

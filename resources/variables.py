import datetime

date_now = datetime.datetime.now()
date_retroativa = date_now - datetime.timedelta(days=30)

TODAY = date_now.strftime("%d/%m/%Y")
RETROATIVA = date_retroativa.strftime("%d/%m/%Y")
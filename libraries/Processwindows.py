import sys, traceback, os

class Processwindows:
    def kill_process(self, process_name):
        try:
            #killed = os.system('tskill ' + process_name)
            killed= os.system('taskkill /IM "' + process_name + '" /F')
        except Exception as e:
            killed = 0
        return killed
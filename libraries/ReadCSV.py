import csv
class ReadCSV():

    def read_csv_file(self, pathCsv, nrConta):
        '''This creates a keyword named "Read CSV File"

        This keyword takes one argument, which is a path to a .csv file. It
        returns a list of rows, with each row being a list of the data in 
        each column.
        '''
        data= False
        caminho = pathCsv +"\\resources\\CSV\\RELATORIO_ENVIOS.csv"
        filename = "RELATORIO_ENVIOS.csv"
        with open(caminho, 'r') as filename:
            reader = csv.reader(filename, delimiter=',', dialect='excel')
            for row in reader:
                if str(row[1]) == str(nrConta):
                    return True
            print("não Existe na tabela")
            return False
import jaydebeapi
import jpype


class Banco:
    def create_db_connection():
        connection = None

        #Colocar essas informações no Settings
        try:   
            driver_path = "C:/ojdbc11.jar"
            conn_string = "jdbc:oracle:thin:@scan-mvh9j.adhosp.com.br:1521/mvh9j"
            username = "TI_GREEN"
            password = "@Acesso@2019"
            jvm_path = "C:/Program Files/Java/jdk-11/bin/server/jvm.dll"
            jpype.startJVM(jvm_path, "-Djava.class.path={}".format(driver_path))

            connection = jaydebeapi.connect("oracle.jdbc.driver.OracleDriver", conn_string, [username, password])

        except Exception as err:
             print(f"Erro ao conectar: '{err}'")
            
        return connection
    
    def read_query(connection, query):
        cursor = connection.cursor()
        try:
            cursor.execute(query)
            result = cursor.fetchall()
            cursor.close()
            return result
        except Exception as err:
            print(f"Erro ao realizar consulta: '{err}'")


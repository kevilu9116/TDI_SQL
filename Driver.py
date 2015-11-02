from ConnectToTDI_SQL import *
import getpass

hostName = raw_input('Enter the hostname: ')
userName = raw_input('Enter your username: ')
password = getpass.getpass(prompt='Enter your password: ')
database = raw_input('Enter the database you wish to use: ')

dbConnection = TDISQL(hostName, userName, password, database)


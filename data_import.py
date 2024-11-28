import mysql.connector as connector
import csv

# create a connection to the database
db_conn = connector.connect(
    host="localhost",
    user="root",
    password="db_password"
)

cursor = db_conn.cursor()


# load csv file 
layoffs_list = ([])
with open('layoffs.csv','r') as data:
    layoffs = csv.reader(data)
    for row in layoffs:
        layoffs_list.append({
            'company':row[0], 'location':row[1], 'industry':row[2], 'total_laid_off':row[3], 'percentage_laid_off':row[4],'date':row[5], 'stage':row[6], 'country':row[7], 'funds_raised_millions':row[8]
        })
# Insert the data to database.
try:
    for row in layoffs_list:
        query = "INSERT INTO world_layoffs.layoffs(company,location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) values(%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        values = (row[0],row[1],row[2],row[3],row[4],row[5],row['stage'],row['country'],row['funds_raised_millions'])
        cursor.execute(query,values)
    rows = len(layoffs_list)
    print(f"Data has been uploaded successfuly: {rows} rows affected")
    db_conn.commit()
except connector.Error as e:
    print(f"Hey, there is thi error: {e}" )


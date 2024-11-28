import mysql.connector as connector
import json 

# create a connection to the database
db_conn = connector.connect(
    host="localhost",
    user="root",
    password="daniel97"
)

# create database and tables (cursor)
cursor = db_conn.cursor()

# cursor.execute("CREATE DATABASE IF NOT EXISTS FaceBook")
# cursor.execute("USE  FaceBook")
# cursor.execute("CREATE TABLE IF NOT EXISTS Comment(PostID int, id int, name varchar(200),email varchar(100), body varchar(500))")

# # read the json file
# with open('comments.json', 'r') as comments:
#     comments = json.load(comments)

# try:
#     for comment in comments:
#         querry = "INSERT INTO Comment values(%s,%s,%s,%s,%s)"
#         values = (comment['postId'],comment['id'],comment['name'],comment['email'],comment['body'])
#         cursor.execute(querry,values)
#     db_conn.commit()
#     print("Data successfuly uploaded")

# except connector.Error as e:
#     print(f"Error {e}")


# csv data into database

import csv
# load csv file 
layoffs_list = ([])
with open('layoffs.csv','r') as data:
    layoffs = csv.reader(data)
    for row in layoffs:
        layoffs_list.append({
            'company':row[0], 'location':row[1], 'industry':row[2], 'total_laid_off':row[3], 'percentage_laid_off':row[4],'date':row[5], 'stage':row[6], 'country':row[7], 'funds_raised_millions':row[8]
        })
# print(f"{layoffs_list[1365]}")
# for i in layoffs_list:
#     print(f"{i['total_laid_off']}, at {layoffs_list[1365]}")
# # company,location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions


try:
    for row in layoffs_list:
        query = "INSERT INTO world_layoffs.layoffs_stage1(company,location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) values(%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        values = (row[0],row[1],row[2],row[3],row[4],row[5],row['stage'],row['country'],row['funds_raised_millions'])
        cursor.execute(query,values)
    rows = len(layoffs_list)
    print(f"Data has been uploaded successfuly: {rows} rows affected")
    db_conn.commit()
except connector.Error as e:
    print(f"Daniel, there is an error: {e}" )


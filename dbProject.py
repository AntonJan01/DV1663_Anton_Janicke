from flask import Flask
from flask_mysqldb import MySQL

mysql = MySQL()

def create_app():
        app = Flask(__name__)
        app.config['MYSQL_HOST'] = '127.0.0.1'
        app.config['MYSQL_USER'] = 'root'
        app.config['MYSQL_PASSWORD'] ='letmein'
        app.config['MYSQL_DB'] = 'Lego_db'

        mysql.init_app(app)

        return app


def main():
    app = create_app()

    with app.app_context():
        cur = mysql.connection.cursor()

        while True:
            print("\nMenu:")
            print("1. View data")
            print("2. Add set to user")
            print("3. Find missing pieces")
            print("4. compare value")
            print("5. View all users inventory value")
            print("6. Exit")
            choice = input("Enter your choice: ")


            if choice == '1':
                while True:
                    print("\nData Menu:")
                    print("1. Users")
                    print("2. Lego Sets")
                    print("3. Lego Pieces")
                    print("4. User Lego Pieces")
                    print("5. User Lego sets")
                    print("6. Set Lego Pieces")
                    print("7. Exit")
                    choice = input("Enter your choice: ")

                    if choice == '1':
                        cur.execute("SELECT * FROM Users")
                        data = cur.fetchall()
                        column_names = [desc[0] for desc in cur.description]
                        print("\nUsers:")
                        print(" | ".join(column_names))
                        for row in data:
                            print(row)
                    
                    elif choice == '2':
                        cur.execute("SELECT * FROM LegoSets")
                        data = cur.fetchall()
                        column_names = [desc[0] for desc in cur.description]
                        print("\nLegoSets:")
                        print(" | ".join(column_names))
                        for row in data:
                            print(row)
                    
                    elif choice == '3':
                        cur.execute("SELECT * FROM LegoPieces")
                        data = cur.fetchall()
                        column_names = [desc[0] for desc in cur.description]
                        print("\nLegoPieces:")
                        print(" | ".join(column_names))
                        for row in data:
                            print(row)
                    
                    elif choice == '4':
                        cur.execute("SELECT * FROM UserLegoPieces")
                        data = cur.fetchall()
                        column_names = [desc[0] for desc in cur.description]
                        print("\nUserLegoPieces:")
                        print(" | ".join(column_names))
                        for row in data:
                            print(row)

                    elif choice == '5':
                        cur.execute("SELECT * FROM UserLegoSets")
                        data = cur.fetchall()
                        column_names = [desc[0] for desc in cur.description]
                        print("\nUsers:")
                        print(" | ".join(column_names))
                        for row in data:
                            print(row)

                    elif choice == '6':
                        cur.execute("SELECT * FROM SetLegoPieces")
                        data = cur.fetchall()
                        column_names = [desc[0] for desc in cur.description]
                        print("\nSetLegoPieces:")
                        print(" | ".join(column_names))
                        for row in data:
                            print(row)
                    
                    elif choice == '7':
                        break
                    else:
                        print("Invalid choice!")
            
            elif choice == '2':

                strUserID = input("Enter user ID: ")
                strSetID = input("Enter Set ID: ")
                userID = int(strUserID)
                setID = int(strSetID)
                cur.callproc("AddSetToUser", [userID, setID])
                mysql.connection.commit()

            elif choice == '3':
                strUserID = input("Enter user ID: ")
                strSetID = input("Enter Set ID: ")
                userID = int(strUserID)
                setID = int(strSetID)
                cur.callproc("GetMissingPieces", [userID, setID])
                data = cur.fetchall()
                if data:
                    column_names = [desc[0] for desc in cur.description]
                    print("\nMissing Pieces:")
                    print(" | ".join(column_names))
                    for row in data:
                        print(row)
                else:
                    print("\nNo Missing Pieces")


            elif choice == '4':
                strSetID = input("Enter Set ID: ")
                setID = int(strSetID)
                cur.execute("SELECT CompareSetToPiecesPrice(%s)", (setID,))
                dbresult = cur.fetchone()
                result = int(dbresult[0])
                if result < 0:
                    result = result*-1
                    print("\nPieces are cheaper then set by:", result, "kr")
                else:
                    print("\nSet are cheaper then Pieces by:", result, "kr")
            elif choice == '5':
                cur.execute("SELECT * FROM ValueOfInventory")
                data = cur.fetchall()

                if data:
                    column_names = [desc[0] for desc in cur.description]
                    print("\nValue of Inventory:")
                    print(" | ".join(column_names))
                    for row in data:
                        print(row)
                else:
                    print("\nNo data found")

            elif choice =='6':
                 break
            
            else:
                print("Invalid choice!")
        cur.close()

if __name__ == "__main__":
    main()



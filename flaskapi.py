import os
from flask import jsonify, request, Flask
from flaskext.mysql import MySQL

app = Flask(__name__)

mysql = MySQL()

app.config["MYSQL_DATABASE_USER"] = "root"
app.config["MYSQL_DATABASE_PASSWORD"] = os.getenv("db_root_password")
app.config["MYSQL_DATABASE_DB"] = os.getenv("db_name")
app.config["MYSQL_DATABASE_HOST"] = os.getenv("MYSQL_SERVICE_HOST")
app.config["MYSQL_DATABASE_PORT"] = int(os.getenv("MYSQL_SERVICE_PORT"))
mysql.init_app(app)

@app.route("/")
def index():
    return "Hello, Pokemon world!"

@app.route("/create", methods=["POST"])
def add_pokemon():
    json = request.json
    name = json["name"]
    name_en = json["name_en"]
    number = json["number"]
    if name and name_en and number and request.method == "POST":
        sql = "INSERT INTO pokemon(pokemon_name, pokemon_name_en, pokemon_number) " \
              "VALUES(%s, %s, %s)"
        data = (name, name_en, number)
        try:
            conn = mysql.connect()
            cursor = conn.cursor()
            cursor.execute(sql, data)
            conn.commit()
            cursor.close()
            conn.close()
            resp = jsonify("Pokemon created successfully!")
            resp.status_code = 200
            return resp
        except Exception as exception:
            return jsonify(str(exception))
    else:
        return jsonify("Please provide name, name_en and number")

@app.route("/pokemons", methods=["GET"])
def users():
    try:
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM pokemon")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        resp = jsonify(rows)
        resp.status_code = 200
        return resp
    except Exception as exception:
        return jsonify(str(exception))

@app.route("/pokemon/<int:pokemon_id>", methods=["GET"])
def pokemon(pokemon_id):
    try:
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM pokemon WHERE pokemon_id=%s", pokemon_id)
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        resp = jsonify(row)
        resp.status_code = 200
        return resp
    except Exception as exception:
        return jsonify(str(exception))

@app.route("/update", methods=["POST"])
def update_pokemon():
    json = request.json
    name = json["name"]
    name_en = json["name_en"]
    number = json["number"]
    user_id = json["pokemon_id"]
    if name and name_en and number and pokemon_id and request.method == "POST":
        sql = "UPDATE pokemon SET pokemon_name=%s, pokemon_name_en=%s, " \
              "pokemon_number=%s WHERE pokemon_id=%s"
        data = (name, name_en, number, pokemon_id)
        try:
            conn = mysql.connect()
            cursor = conn.cursor()
            cursor.execute(sql, data)
            conn.commit()
            resp = jsonify("Pokemon updated successfully!")
            resp.status_code = 200
            cursor.close()
            conn.close()
            return resp
        except Exception as exception:
            return jsonify(str(exception))
    else:
        return jsonify("Please provide id, name, name_en and number")

@app.route("/delete/<int:pokemon_id>")
def delete_pokemon(pokemon_id):
    try:
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM pokemon WHERE pokemon_id=%s", pokemon_id)
        conn.commit()
        cursor.close()
        conn.close()
        resp = jsonify("Pokemon deleted successfully!")
        resp.status_code = 200
        return resp
    except Exception as exception:
        return jsonify(str(exception))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

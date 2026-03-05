from flask import Flask
from app.extensions import db, migrate
from app.customers.infrastructure.blueprint import customers_bp

def create_app():
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://postgres:postgres@localhost/loans"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    migrate.init_app(app, db)

    app.register_blueprint(customers_bp, url_prefix="/api/v1")

    return app
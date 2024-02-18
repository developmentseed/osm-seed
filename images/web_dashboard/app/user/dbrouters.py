from .models import Users


class AccountsDBRouter:
    def db_for_read(self, model, **hints):
        if model == Users:
            return "osm_api"
        return None

    def db_for_write(self, model, **hints):
        if model == Users:
            return "osm_api"
        return None

from django.contrib import admin
from .models import Users
from .forms import UsersForm

# Register your models here.
class UserAdmin(admin.ModelAdmin):
    list_display = ("email", "id", "display_name", "status")
    form = UsersForm


admin.site.register(Users, UserAdmin)
from django.contrib import admin
from .models import Users

# Register your models here.
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'id', 'display_name', 'status')

admin.site.register(Users, UserAdmin)
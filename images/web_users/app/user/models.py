from django.db import models
from datetime import datetime

# Create your models here.
class Users(models.Model):
    email = models.CharField(unique=True, max_length=100)
    id = models.BigAutoField(primary_key=True)
    pass_crypt = models.CharField(max_length=100)
    creation_time = models.DateTimeField(default=datetime.now, blank=True)
    display_name = models.CharField(unique=True, max_length=100)
    data_public = models.BooleanField(default=True)
    # description = models.TextField(default="active")
    email_valid = models.BooleanField(default=True)
    status = models.TextField(default="active")  # This field type is a guess.
    consider_pd = models.BooleanField(default=True)
    terms_seen = models.BooleanField(default=True)
    # description_format = models.TextField(default="active")  # This field type is a guess.
    changesets_count = models.IntegerField(default=0)
    traces_count = models.IntegerField(default=0)
    diary_entries_count = models.IntegerField(default=0)
    image_use_gravatar = models.BooleanField(default=True)
    auth_uid = models.CharField(max_length=100, default="xyc")
    auth_provider = models.CharField(max_length=100, default="xyc")

    class Meta:
        managed = False
        db_table = 'users'
        unique_together = (('auth_provider', 'auth_uid'),)


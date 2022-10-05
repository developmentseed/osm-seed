from django.db import models
from datetime import datetime
# from django.contrib.auth.hashers import Argon2PasswordHasher
import django.contrib.auth.hashers as hasher  
import argon2, binascii

# Create your models here.
class Users(models.Model):
    id = models.BigAutoField(primary_key=True)
    email = models.CharField(unique=True, max_length=100)
    display_name = models.CharField(unique=True, max_length=100)
    pass_crypt = models.CharField(max_length=100)
    data_public = models.BooleanField(default=True)
    email_valid = models.BooleanField(default=True)
    status = models.TextField(default="active")
    consider_pd = models.BooleanField(default=True)
    terms_seen = models.BooleanField(default=True)
    changesets_count = models.IntegerField(default=0)
    traces_count = models.IntegerField(default=0)
    diary_entries_count = models.IntegerField(default=0)
    image_use_gravatar = models.BooleanField(default=True)
    terms_agreed = models.DateTimeField(default=datetime.now, null=True)
    tou_agreed = models.DateTimeField(default=datetime.now, null=True)
    creation_time = models.DateTimeField(default=datetime.now, blank=True)

    class Meta:
        managed = False
        db_table = 'users'
        # unique_together = (('auth_provider', 'auth_uid'),)

    def save(self, *args, **kwargs):
        # self.pass_crypt = Argon2PasswordHasher(self.pass_crypt)
        # self.pass_crypt = hasher.Argon2PasswordHasher.encode(self, self.pass_crypt, None)
        argon2Hasher = argon2.PasswordHasher(time_cost=16, memory_cost=2**16, parallelism=2, hash_len=32, salt_len=16)
        self.pass_crypt = argon2Hasher.hash(self.pass_crypt)
        print(self.pass_crypt)
        super(Users, self).save(*args, **kwargs)



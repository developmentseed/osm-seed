from .models import Users
from django import forms

USER_STATUS = [
    ("active", "Active"),
    ("pending", "Pendig"),
    ("confirmed", "Confirmed"),
    ("suspended", "Suspended"),
    ("deleted", "Deleted"),
]


class UsersForm(forms.ModelForm):
    email = forms.EmailField(help_text="Enter a valid email address.")
    pass_crypt = forms.CharField(
        widget=forms.PasswordInput(
            attrs={"class": "form-control", "placeholder": "please enter password"}
        )
    )
    display_name = forms.CharField(label="User name", required=True)
    status = forms.CharField(label="Status", widget=forms.Select(choices=USER_STATUS))

    class Meta:
        model = Users
        fields = ["email", "display_name", "pass_crypt", "status"]

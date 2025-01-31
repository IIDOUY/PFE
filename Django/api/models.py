from django.contrib.auth.models import AbstractBaseUser, BaseUserManager,PermissionsMixin
from django.db import models


# Création d'un manager personnalisé pour le modèle utilisateur
class UserManager(BaseUserManager):
    def create_user(self, email, username, password=None, **extra_fields):
        if not email:
            raise ValueError('L\'email doit être défini')
        email = self.normalize_email(email)
        user = self.model(email=email, username=username, **extra_fields)
        user.set_password(password)  # Hashage du mot de passe
        user.save(using=self._db)
        return user

    def create_superuser(self, email, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(email, username, password, **extra_fields)

# Modèle utilisateur personnalisé
class User(AbstractBaseUser, PermissionsMixin):
    fullname = models.CharField(max_length=150)
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # Le mot de passe est stocké de manière sécurisée
    phone = models.CharField(max_length=15, blank=True, null=True)
    gender = models.CharField(max_length=10, choices=[('Male', 'Male'), ('Female', 'Female')])
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)  # Champ pour déterminer l'accès à l'admin
    is_superuser = models.BooleanField(default=False)  # Champ pour déterminer si l'utilisateur est un superutilisateur
    is_vip = models.BooleanField(default=False) # Champ pour déterminer si l'utilisateur est un VIP
    avatarUrl = models.CharField(max_length=100)

    # Champs obligatoires pour l'authentification
    USERNAME_FIELD = 'username'  # Tu peux utiliser email ou username comme champ pour l'authentification
   # REQUIRED_FIELDS = ['username']  # Ce champ est requis lors de la création d'un superutilisateur

    objects = UserManager()

    def __str__(self):
        return self.username

#Modele reset password
class PasswordResetOTP(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    otp = models.CharField(max_length=6)  # Code OTP à 6 chiffres
    created_at = models.DateTimeField(auto_now_add=True)

    def is_valid(self):
        from datetime import timedelta
        from django.utils.timezone import now
        return now() - self.created_at < timedelta(minutes=10)  # Valide pendant 10 minutes

    def __str__(self):
        return f"OTP for {self.user.email}"
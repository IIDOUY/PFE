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

# Modèle utilisateur personnalisé (table 1)
class User(AbstractBaseUser, PermissionsMixin):
    fullname = models.CharField(max_length=150)
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # Le mot de passe est stocké de manière sécurisée
    phone = models.CharField(max_length=15, unique=True)
    address = models.CharField(max_length=255, blank=True, null=True)
    gender = models.CharField(max_length=10, choices=[('Male', 'Male'), ('Female', 'Female')])
    person_relative_phone = models.CharField(max_length=15, default='')
    is_vip = models.BooleanField(default=False)
    avatarUrl = models.CharField(max_length=255, blank=True, null=True)    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)  # Champ pour déterminer l'accès à l'admin
    is_superuser = models.BooleanField(default=False)  # Champ pour déterminer si l'utilisateur est un superutilisateur
    date_joined = models.DateTimeField(auto_now_add=True)

    # Champs obligatoires pour l'authentification
    USERNAME_FIELD = 'username'  # Tu peux utiliser email ou username comme champ pour l'authentification
    REQUIRED_FIELDS = ['email']  # Ce champ est requis lors de la création d'un superutilisateur

    objects = UserManager()

    def __str__(self):
        return self.username
#-------------------------------------------------------------------------------------------------------------
#Modele de categorie de services (table 2)
class Category(models.Model):
    category_id = models.AutoField(primary_key=True)
    category_name = models.CharField(max_length=255)
    category_description = models.TextField()

    def __str__(self):
        return self.category_name
    
#Modele de services (table 3)
class Services(models.Model):
    service_id = models.AutoField(primary_key=True)
    service_name = models.CharField(max_length=255)
    service_description = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    service_price = models.FloatField()
    service_image = models.ImageField(upload_to='service_images/', default='service_images/default.png') 


    def __str__(self):
        return self.service_name

#Modele de prestataire du service (table 4)
class Provider(models.Model):
    fullname = models.CharField(max_length=150)
    email = models.EmailField(unique=True)
    gender = models.CharField(max_length=10, choices=[('Male', 'Male'), ('Female', 'Female')])
    phone = models.CharField(max_length=15, blank=True, null=True)
    address = models.CharField(max_length=255, blank=True)
    service = models.ForeignKey(Services, on_delete=models.CASCADE, default='1')
    is_disponible = models.BooleanField(default=True)
    rating_avg = models.FloatField(default=0)
    added_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.fullname


#-------------------------------------------------------------------------------------------------------------
#Modele de demande de service (table 5)
class Request(models.Model):
    request_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    service = models.ForeignKey(Services, on_delete=models.CASCADE)
    selected_dates = models.JSONField()
    request_date = models.DateTimeField(auto_now_add=True)
    request_status = models.CharField(max_length=20, choices=[('Pending', 'Pending'), ('Accepted', 'Accepted'), ('Rejected', 'Rejected')], default='Pending')

    def __str__(self):
        return f"{self.user.username} requested {self.service.service_name}"

def get_available_providers(service_id, selected_dates):
    # Étape 1: Filtrer les prestataires qui offrent le service demandé et qui sont disponibles
    available_providers = Provider.objects.filter(service_id=service_id, is_disponible=True)
    
    # Étape 2: Exclure les prestataires qui sont déjà liés à une demande aux mêmes dates
    occupied_providers = Link.objects.filter(
        request__selected_dates__overlap=selected_dates  # Vérifie si les dates se chevauchent
    ).values_list('provider_id', flat=True)

    # Étape 3: Exclure les prestataires occupés
    free_providers = available_providers.exclude(id__in=occupied_providers)
    
    return free_providers
#-------------------------------------------------------------------------------------------------------------

#Modele de link entre utilisateur et prestataire (table 6)
class Link(models.Model):
    link_id = models.AutoField(primary_key=True)
    # user = models.ForeignKey(User, on_delete=models.CASCADE)
    provider = models.ForeignKey(Provider, on_delete=models.CASCADE)
    request = models.ForeignKey(Request, on_delete=models.CASCADE)
    # service = models.ForeignKey(Services, on_delete=models.CASCADE)
    linked_date = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=[
        ('pending', 'pending'),
        ('in progress', 'in progress'),
        ('finished', 'finished')
    ], default='pending')

    def __str__(self):
        return f"{self.request.user} linked to {self.provider.fullname}"
    
    
#-------------------------------------------------------------------------------------------------------------
#Modele de note et commentaire(table 7)
class Evaluation(models.Model):
    evaluation_id = models.AutoField(primary_key=True)
    link = models.ForeignKey(Link, on_delete=models.CASCADE)
    rating = models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5')], default=1)
    comment = models.TextField()
    evaluation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.link.request.user.username} rated {self.link.request.service.service_name} with {self.rating} stars"

#Modele de reclamation (table 8)
class Report(models.Model):
    report_id = models.AutoField(primary_key=True)
    link = models.ForeignKey(Link, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    provider = models.ForeignKey(Provider, on_delete=models.CASCADE)
    report_text = models.TextField()
    status = models.CharField(max_length=20, choices=[('Pending', 'Pending'),('Treated','Treated')], default='Pending')
    report_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} reported {self.provider.fullname}"
    
#-------------------------------------------------------------------------------------------------------------
#Modele de paiement (table 9)
class Payment(models.Model):
    payment_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    link = models.ForeignKey(Link, on_delete=models.CASCADE)
    price = models.FloatField()
    status = models.CharField(max_length=20, choices=[('Pending', 'Pending'), ('Paid', 'Paid'), ('Failed', 'Failed')], default='Pending')
    payment_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} paid {self.link.link_id}"
    
#-------------------------------------------------------------------------------------------------------------
#Modele reset password (table 10)
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
    
#Modele de notification (table 11)
class Notification(models.Model):
    notification_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    notification_text = models.TextField()
    notification_date = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.username} received a notification"
#fonction de notification  
def create_notification(user, message):
    Notification.objects.create(user=user, notification_text=message)
    print(f"✅ Notification envoyée à {user.username}: {message}")
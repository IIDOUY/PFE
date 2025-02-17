from django.contrib import admin
from .models import User, Provider, Category, Services, Link, Request, ProviderRating, ServiceRating, Report
# Register your models here.
admin.site.register(User)
admin.site.register(Provider)
admin.site.register(Category)
admin.site.register(Services)
admin.site.register(ProviderRating)

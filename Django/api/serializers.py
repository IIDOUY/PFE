from rest_framework import serializers
from .models import User, Provider, Category, Services, Link, Request, Evaluation, Report
from django.contrib.auth.hashers import make_password
import re

#User Serializer
class UserSerializer(serializers.ModelSerializer):  
    class Meta:
        model = User
        fields = ['id', 'fullname','username', 'email', 'password', 'phone', 'address', 'gender', 'is_vip', 'avatarUrl', 'person_relative_phone']
        extra_kwargs = {
            'password': {'write_only': True},               
            'is_vip': {'read_only': True},
            'id': {'read_only': True}
        }
    
    def validate_fullname(self, value):
        """Vérifie que le fullname ne contient que des lettres et des espaces."""
        if not re.match(r'^[A-Za-zÀ-ÖØ-öø-ÿ\s]+$', value):
            raise serializers.ValidationError("Le nom complet ne doit contenir que des lettres et des espaces.")
        return value

    def validate_username(self, value):
        if len(value) < 5:
            raise serializers.ValidationError("Username must be at least 5 characters long.")
        if not re.match(r'^[A-Za-z0-9_.]+$', value):
            raise serializers.ValidationError("Le nom d'utilisateur ne doit contenir que des lettres, des chiffres, des points (.) et des underscores (_).")
        return value

    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters long.")
        return value    

    def validate_phone(self, value):
        """Vérifie que le numéro de téléphone est valide."""
        if not re.match(r'^\+?\d{9,15}$', value):
            raise serializers.ValidationError("Le numéro de téléphone doit contenir uniquement des chiffres et peut commencer par '+'.")
        return value
    
    def validate_person_relative_phone(self, value):
        """Vérifie que le numéro de téléphone est valide."""
        if not re.match(r'^\+?\d{9,15}$', value):
            raise serializers.ValidationError("Le numéro de téléphone doit contenir uniquement des chiffres et peut commencer par '+'.")
        return value

    def create(self, validated_data):
        # Hacher le mot de passe avant de sauvegarder
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)
    
#Provider Serializer
class ProviderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Provider
        fields = ['id', 'fullname', 'email','gender', 'phone', 'address', 'services', 'is_disponible', 'rating_avg']
        extra_kwargs = {
            'id': {'read_only': True}
        }

#Category Serializer
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['category_id', 'category_name', 'category_description']

#Services Serializer
class ServicesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Services
        fields = ['service_id', 'service_name', 'service_description', 'service_price', 'category']

#Request Serializer
class RequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Request
        fields = ['request_id', 'user', 'provider', 'service', 'price', 'start_date', 'end_date', 'request_date', 'status']

    def validate_end_date(self, value):
        if self.initial_data['start_date'] > value:
            raise serializers.ValidationError("La date de fin doit être postérieure à la date de début.")
        return value
    
#Link Serializer
class LinkSerializer(serializers.ModelSerializer):
    class Meta:
        model = Link
        fields = ['link_id', 'user', 'provider', 'service', 'start_date', 'end_date', 'linked_date', 'status']
    
    def validate_end_date(self, value):
        if self.initial_data['start_date'] > value:
            raise serializers.ValidationError("La date de fin doit être postérieure à la date de début.")
        return value
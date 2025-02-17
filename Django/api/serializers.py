from rest_framework import serializers
from .models import User, Provider, Category, Services, Link, Request, ProviderRating,ServiceRating, Report
from django.contrib.auth.hashers import make_password

#User Serializer
class UserSerializer(serializers.ModelSerializer):  
    class Meta:
        model = User
        fields = ['id', 'fullname','username', 'email', 'password', 'phone', 'address', 'gender', 'is_vip', 'avatarUrl']
        extra_kwargs = {
            'password': {'write_only': True},               
            'is_vip': {'read_only': True},
            'id': {'read_only': True}
        }

    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters long.")
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
        fields = ['request_id', 'user', 'provider', 'service', 'price', 'start_date', 'end_date', 'linked_date']
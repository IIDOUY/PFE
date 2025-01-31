from rest_framework import serializers
from .models import User
from django.contrib.auth.hashers import make_password

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'fullname','username', 'email', 'password', 'phone', 'gender', 'is_vip', 'avatarUrl']
        extra_kwargs = {'password': {'write_only': True}}

    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters long.")
        return value    

    def create(self, validated_data):
        # Hacher le mot de passe avant de sauvegarder
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)
    


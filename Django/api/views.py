from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import UserSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification

    def get(self, request):
        user = request.user  # Récupère l'utilisateur connecté
        serializer = UserSerializer(user)  # Sérialise l'utilisateur avec le sérialiseur existant
        user_data = serializer.data  # Sérialisation des données utilisateur
        user_data.pop('id', None)  # Supprime le champ `id` de la représentation
        return Response(user_data, status=200)
        #just added
    def post(self, request):
        user = request.user
        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

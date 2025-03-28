from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import UserSerializer, CategorySerializer, ServicesSerializer, RequestSerializer, ProviderSerializer, NotificationSerializer, LinkSerializer, EvaluationSerializer, ReportSerializer
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework_simplejwt.authentication import JWTAuthentication
from .models import  User, Category, Services, Request, Provider, Link, Notification, Evaluation, Report
from django.db import models
from django.db.models import Q
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.parsers import JSONParser
from rest_framework import status
from .models import Notification, create_notification, get_available_providers
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync  
from django.shortcuts import get_object_or_404
from .views import Notification, send_realtime_notification

#Views pour les utilisateurs (beneficiaires)
class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification

    def get(self, request):
        user = request.user  # Récupère l'utilisateur connecté
        serializer = UserSerializer(user, context = {'request': request})  # Sérialise l'utilisateur avec le sérialiseur existant
        return Response(serializer.data, status=200)
    
    def put(self, request):
        user = request.user
        serializer = UserSerializer(user, data=request.data, partial=True,context = {'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)
#-------------------------------------------------------------------------------------------------
#Views pour les prestataires
class UserProviderView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les prestataires
    def get(self, request):
        search_query = request.query_params.get('query', None)  # Un seul paramètre pour la recherche

        if not search_query:
            providers = Provider.objects.all()

        else:
            try:
                provider_id = int(search_query)
                providers = Provider.objects.filter(id=provider_id)
            except ValueError:
                providers = Provider.objects.filter(
                    models.Q(fullname__icontains=search_query) |  # Recherche par nom
                    models.Q(service__service_name__icontains=search_query) |  # Recherche par service
                    models.Q(email__iexact=search_query) |  # Recherche exacte sur l'email
                    models.Q(phone__iexact=search_query)  # Recherche exacte sur le téléphone
                )

        serializer = ProviderSerializer(providers, context={'request': request}, many=True)
        return Response(serializer.data, status=200)
#--------------------------------------------------------------------------------------------------
#Views pour les categories
class UserCategoryView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les categories
    def get(self, request):
        search_query = request.query_params.get('query', None)  # Un seul paramètre pour la recherche

        if not search_query:
            categories = Category.objects.all()

        else:
            try:
                category_id = int(search_query)
                categories = Category.objects.filter(category_id=category_id)
            except ValueError:
                categories = Category.objects.filter(
                    models.Q(category_name__icontains=search_query) |  # Recherche par nom
                    models.Q(category_description__icontains=search_query)   # Recherche par service
                )

        serializer = CategorySerializer(categories, context={'request': request}, many=True)
        return Response(serializer.data, status=200)

#------------------------------------------------------------------------------------------------- 
#Views pour les services
class UserServicesView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    parser_classes = [MultiPartParser, FormParser]
    
    #lister les services
    def get(self, request):
        search_query = request.query_params.get('query', None)  # Un seul paramètre pour la recherche

        if not search_query:
            services = Services.objects.all()

        else:
            filters = Q(service_name__icontains=search_query) | Q(service_description__icontains=search_query) | Q(category__category_name__icontains=search_query)

            try:
                # Convertir la requête en float si possible (pour la recherche de prix exact)
                price_value = float(search_query)
                filters |= Q(service_price=price_value)
            except ValueError:
                pass  # Ignore si ce n'est pas un nombre valide

            services = Services.objects.filter(filters)

        serializer = ServicesSerializer(services, context={'request': request}, many=True)
        return Response(serializer.data, status=200)
#-------------------------------------------------------------------------------------------------
#Views pour les demandes de service (requests)
class UserRequestView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les demandes
    def get(self, request):
        search_query = request.query_params.get('query', None)  # Un seul paramètre pour la recherche

        if not search_query:
            requests = Request.objects.all()
        else:
            requests = Request.objects.filter(
                models.Q(service__service_name__icontains=search_query)  # Recherche par service
            )

        serializer = RequestSerializer(requests, context={'request': request}, many=True)
        return Response(serializer.data, status=200)
    #ajouter une demande
    def post(self, request):
        serializer = RequestSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save(user=request.user)
        
            # Récupérer l'objet Service à partir de l'ID
            service_id = request.data['service']
            service = get_object_or_404(Services, service_id=service_id)  # Récupère le service ou renvoie une 404 si non trouvé
        
            # ✅ Envoi d'une notification à l'admin
            admin_users = User.objects.filter(is_superuser=True)
            for admin in admin_users:
                create_notification(admin, f"{request.user.username} a demandé le service de {service.service_name}.")

            send_realtime_notification(f"{request.user.username} a demandé le service de {service.service_name}.")
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    #modifier une demande
    def put(self, request):
        request_id = request.query_params.get('id', None)
        user_request = Request.objects.get(request_id=request_id)
        serializer = RequestSerializer(user_request, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)
    #supprimer une demande
    def delete(self, request):
        request_id = request.query_params.get('id', None)
        request = Request.objects.get(request_id=request_id)
        request.delete()
        return Response(status=204)
#-------------------------------------------------------------------------------------------------
#Views pour links
class UserLinkView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les liens
    def get(self, request):
        search_query = request.query_params.get('query', None)  # Un seul paramètre pour la recherche

        if not search_query:
            links = Link.objects.filter(request__user=request.user)
        else:
            links = Link.objects.filter(request__user=request.user)(
                models.Q(provider__fullname__icontains=search_query) |  # Recherche par nom du prestataire
                models.Q(request__service__service_name__icontains=search_query)  # Recherche par service
            )

        serializer = LinkSerializer(links, context={'request': request}, many=True)
        return Response(serializer.data, status=200)
#-----------------------------------------------------------------------------------
#Views pour les evaluations
class EvaluationView(APIView):
    permission_classes = [IsAuthenticated]  # L'utilisateur doit être authentifié
    authentication_classes = [JWTAuthentication]  

    def post(self, request):
        link_id = request.data.get("link_id")
        rating = request.data.get("rating")
        comment = request.data.get("comment")

        # Vérification des champs obligatoires
        if not link_id or rating is None or not comment:
            return Response({"error": "link_id, rating et comment sont requis."}, status=status.HTTP_400_BAD_REQUEST)

        # Vérifier si le link existe
        link = get_object_or_404(Link, link_id=link_id)

        # Vérifier que l'utilisateur connecté est bien le bénéficiaire du service
        if link.request.user != request.user:
            return Response({"error": "Vous ne pouvez évaluer que vos propres services."}, status=status.HTTP_403_FORBIDDEN)

        # Créer l'évaluation
        evaluation = Evaluation.objects.create(
            link=link,
            rating=rating,
            comment=comment
        )

        return Response({"message": "Évaluation enregistrée avec succès."}, status=status.HTTP_201_CREATED)

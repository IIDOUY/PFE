from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import UserSerializer, ProviderSerializer, CategorySerializer, ServicesSerializer, RequestSerializer
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework_simplejwt.authentication import JWTAuthentication
from .models import Provider, User, Category, Services, Request

#Views pour les utilisateurs (beneficiaires)
    #Pour l'utilisateur connecté
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

    #Pour l'administrateur
class UserView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les utilisateurs
    def get(self, request):
        users = User.objects.all() 
        serializer = UserSerializer(users, context = {'request': request}, many = True)  
        return Response(serializer.data, status=200)
    #ajouter un utilisateur
    def post(self, request):
        many = isinstance(request.data, list)  # Vérifie si les données sont une liste
        serializer = UserSerializer(data=request.data, context = {'request': request}, many = many)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    #modifier un utilisateur
    def put(self, request):
        user_id = request.query_params.get('id', None)
        user = User.objects.get(id=user_id)
        serializer = UserSerializer(user, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)
    #supprimer un utilisateur
    def delete(self, request):
        user_id = request.query_params.get('id', None)
        user = User.objects.get(id=user_id)
        user.delete()
        return Response(status=204)
#-------------------------------------------------------------------------------------------------    
#Views pour les prestataires
    #pour l'administrateur
class ProviderProfileView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les prestataires
    def get(self, request):
        provider_id = request.query_params.get('id', None)
        provider_name = request.query_params.get('name', None)

        # Filtrer en fonction des paramètres fournis
        filters = {}
        if provider_id:
            filters['id'] = provider_id
        if provider_name:
            filters['fullname__icontains'] = provider_name  # Recherche insensible à la casse

        providers = Provider.objects.filter(**filters)
        serializer = ProviderSerializer(providers, context={'request': request}, many=True)
        return Response(serializer.data, status=200)
    #ajouter un prestataire
    def post(self, request):
        many = isinstance(request.data, list)
        serializer = ProviderSerializer(data=request.data, context={'request': request}, many=many)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    #modifier un prestataire
    def put(self, request):
        provider_id = request.query_params.get('id', None)
        provider = Provider.objects.get(id=provider_id)
        serializer = ProviderSerializer(provider, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)
    #supprimer un prestataire
    def delete(self, request):
        provider_id = request.query_params.get('id', None)
        provider = Provider.objects.get(id=provider_id)
        provider.delete()
        return Response(status=204)
    
    #pour l'utilisateur connecté
class UserProviderView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les prestataires
    def get(self, request):
        provider_id = request.query_params.get('id', None)
        provider_name = request.query_params.get('name', None)

        # Filtrer en fonction des paramètres fournis
        filters = {}
        if provider_id:
            filters['id'] = provider_id
        if provider_name:
            filters['fullname__icontains'] = provider_name  # Recherche insensible à la casse

        providers = Provider.objects.filter(**filters)
        serializer = ProviderSerializer(providers, context={'request': request}, many=True)
        return Response(serializer.data, status=200)
#------------------------------------------------------------------------------------------------- 
#Views pour les categories
    #Pour l'administrateur
class CategoryView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les categories
    def get(self, request):
        category_id = request.query_params.get('id', None)
        category_name = request.query_params.get('name', None)

        # Filtrer en fonction des paramètres fournis
        filters = {}
        if category_id:
            filters['category_id'] = category_id
        if category_name:
            filters['category_name__icontains'] = category_name  # Recherche insensible à la casse

        categories = Category.objects.filter(**filters)
        serializer = CategorySerializer(categories, context = {'request': request}, many = True)  
        return Response(serializer.data, status=200)
    #ajouter une categorie
    def post(self, request):
        many = isinstance(request.data, list)  # Vérifie si les données sont une liste
        serializer = CategorySerializer(data=request.data, context = {'request': request}, many = many)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    #supprimer une categorie
    def delete(self, request):
        category_id = request.query_params.get('id', None)
        category = Category.objects.get(category_id=category_id)
        category.delete()
        return Response(status=204)

    #Pour l'utilisateur connecté
class UserCategoryView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les categories
    def get(self, request):
        category_id = request.query_params.get('id', None)
        category_name = request.query_params.get('name', None)

        # Filtrer en fonction des paramètres fournis
        filters = {}
        if category_id:
            filters['category_id'] = category_id
        if category_name:
            filters['category_name__icontains'] = category_name  # Recherche insensible à la casse

        categories = Category.objects.filter(**filters)
        serializer = CategorySerializer(categories, context = {'request': request}, many = True)  
        return Response(serializer.data, status=200)

#------------------------------------------------------------------------------------------------- 
#Views pour les services
    #Pour l'administrateur
class ServicesView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les services
    def get(self, request):
        services = Services.objects.all() 
        serializer = ServicesSerializer(services, context = {'request': request}, many = True)  
        return Response(serializer.data, status=200)
    #ajouter un service
    def post(self, request):
        many = isinstance(request.data, list)  # Vérifie si les données sont une liste
        serializer = ServicesSerializer(data=request.data, context = {'request': request}, many = many)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    #supprimer un service
    def delete(self, request):
        service_id = request.query_params.get('id', None)
        service = Services.objects.get(service_id=service_id)
        service.delete()
        return Response(status=204)

    #Pour l'utilisateur connecté
class UserServicesView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les services
    def get(self, request):
        service_id = request.query_params.get('id', None)
        service_name = request.query_params.get('name', None)
        # Filtrer en fonction des paramètres fournis
        filters = {}
        if service_id:
            filters['service_id'] = service_id
        if service_name:
            filters['service_name__icontains'] = service_name  # Recherche insensible à la casse
        services = Services.objects.filter(**filters)
        serializer = ServicesSerializer(services, context = {'request': request}, many = True)  
        return Response(serializer.data, status=200)
#-------------------------------------------------------------------------------------------------
#Views pour les demandes de service (requests)
    #Pour l'administrateur
class RequestView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les demandes
    def get(self, request):
        requests = Request.objects.all() 
        serializer = RequestSerializer(requests, context = {'request': request}, many = True)  
        return Response(serializer.data, status=200)
    #ajouter une demande
    def post(self, request):
        many = isinstance(request.data, list)  # Vérifie si les données sont une liste
        serializer = RequestSerializer(data=request.data, context = {'request': request}, many = many)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    #modifier une demande
    def put(self, request):
        request_id = request.query_params.get('id', None)
        request = Request.objects.get(request_id=request_id)
        serializer = RequestSerializer(request, data=request.data, partial=True, context={'request': request})
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
    
    #Pour l'utilisateur connecté
class UserRequestView(APIView):
    permission_classes = [IsAuthenticated]  # Assure que l'utilisateur est authentifié
    authentication_classes = [JWTAuthentication]  # Utilise le JWT pour l'authentification
    #lister les demandes
    def get(self, request):
        requests = Request.objects.filter(user=request.user) 
        serializer = RequestSerializer(requests, context = {'request': request}, many = True)  
        return Response(serializer.data, status=200)
    #ajouter une demande
    def post(self, request):
        serializer = RequestSerializer(data=request.data, context = {'request': request})
        if serializer.is_valid():
            serializer.save(user = request.user)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    #modifier une demande
    def put(self, request):
        request_id = request.query_params.get('id', None)
        request = Request.objects.get(request_id=request_id)
        serializer = RequestSerializer(request, data=request.data, partial=True, context={'request': request})
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
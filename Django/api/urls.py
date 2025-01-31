from django.urls import path
from .AuthenticationView import SignUpView, LogiInView, UserView, SendResetOTPView, VerifyResetOTPView, ResetPasswordView
from .views import UserProfileView
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)




urlpatterns = [
    # Les endpoints pour l'authentification
    path('signup/', SignUpView.as_view(), name='signup'),
    path('login/', LogiInView.as_view(), name='signin'),
    #Endpoint pour la recuperation des information d'un utilisateur
    path('profile/', UserProfileView.as_view(), name='users'),
    # Les endpoints pour obtenir et rafraichir un token
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),   
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # Les endpoints pour reset password
    path('password-reset/send-otp/', SendResetOTPView.as_view(), name='send_reset_otp'),
    path('password-reset/verify-otp/', VerifyResetOTPView.as_view(), name='verify_reset_otp'),
    path('password-reset/reset/', ResetPasswordView.as_view(), name='reset_password'),
    #just added
    path('profile/update/', UserProfileView.as_view(), name='profile-update'),
    

]
    
from django.urls import path
from .urls import urlpatterns as api_urls

urlpatterns = [
    *api_urls,
]
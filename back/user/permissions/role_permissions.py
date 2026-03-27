from rest_framework.permissions import BasePermission


class IsAdministrativo(BasePermission):
    message = "No tienes permisos para realizar esta acción."

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.es_administrativo()
        )
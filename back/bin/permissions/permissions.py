from rest_framework.permissions import BasePermission


class CanVerBin(BasePermission):
    message = "No tienes permiso para ver canecas."

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.has_perm('bin.ver_bin')
        )


class CanCrearBin(BasePermission):
    message = "No tienes permiso para crear canecas."

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.has_perm('bin.crear_bin')
        )


class CanEditarBin(BasePermission):
    message = "No tienes permiso para editar canecas."

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.has_perm('bin.editar_bin')
        )


class CanEliminarBin(BasePermission):
    message = "No tienes permiso para eliminar canecas."

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.has_perm('bin.eliminar_bin')
        )
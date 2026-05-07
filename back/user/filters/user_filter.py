import django_filters
from django.db.models import Q
from user.models.user_model import User


class UserFilter(django_filters.FilterSet):

    # Búsqueda por nombre o email
    search = django_filters.CharFilter(method='filter_search')

    # Filtro exacto por rol: ?rol=ADMINISTRATIVO o ?rol=USUARIO
    rol = django_filters.ChoiceFilter(choices=User.Rol.choices)

    # Filtro por estado: ?estado=true o ?estado=false
    estado = django_filters.BooleanFilter()

    class Meta:
        model  = User
        fields = ['rol', 'estado']

    def filter_search(self, queryset, name, value):
        if not value:
            return queryset
        return queryset.filter(
            Q(nombre__icontains=value) |
            Q(email__icontains=value)  |
            Q(username__icontains=value)
        )
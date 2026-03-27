from django.urls import path

from bin.views.bin.bin_create_view import BinCreateView
from bin.views.bin.bin_list_view import BinListView
from bin.views.bin.bin_detail_view import BinDetailView
from bin.views.bin.bin_update_view import BinUpdateView
from bin.views.bin.bin_delete_view import BinDeleteView

urlpatterns = [
    path('', BinListView.as_view()),
    path('create/', BinCreateView.as_view()),
    path('<int:pk>/', BinDetailView.as_view()),
    path('<int:pk>/update/', BinUpdateView.as_view()),
    path('<int:pk>/delete/', BinDeleteView.as_view()),
]
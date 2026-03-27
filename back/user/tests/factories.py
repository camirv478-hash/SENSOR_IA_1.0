import factory
from django.contrib.auth.hashers import make_password
from django.utils import timezone
from user.models.user_model import User
from user.models.email_verification_model import EmailVerification


class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User

    username = factory.Sequence(lambda n: f"user_{n}")
    nombre   = factory.Faker('name')
    email    = factory.Sequence(lambda n: f"user_{n}@test.com")
    password = factory.LazyFunction(lambda: make_password('TestPass123!'))
    rol      = User.Rol.USER
    estado   = True

    @factory.post_generation
    def verificado(self, create, extracted, **kwargs):
        """Crea EmailVerification verificado por defecto."""
        if not create:
            return
        EmailVerification.objects.create(
            user        = self,
            code        = '000000',
            expires_at  = EmailVerification.get_expiration_time(),
            is_used     = True,
            is_verified = True,
            verified_at = timezone.now(),
        )


class AdminFactory(UserFactory):
    username = factory.Sequence(lambda n: f"admin_{n}")
    email    = factory.Sequence(lambda n: f"admin_{n}@test.com")
    rol      = User.Rol.ADMIN
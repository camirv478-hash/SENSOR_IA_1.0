from django.core.mail import send_mail
from django.conf import settings


def _send(subject: str, message: str, to: str) -> None:
    """Función interna base — todos los envíos pasan por aquí."""
    send_mail(
        subject              = subject,
        message              = message,
        from_email           = settings.DEFAULT_FROM_EMAIL,
        recipient_list       = [to],
        fail_silently        = False,
    )


def send_verification_email(to: str, code: str) -> None:
    _send(
        subject = "Verifica tu correo",
        message = (
            f"Tu código de verificación es: {code}\n\n"
            f"Este código expira en 10 minutos.\n"
            f"Si no creaste una cuenta, ignora este mensaje."
        ),
        to = to,
    )


def send_email_change_code(to: str, code: str) -> None:
    _send(
        subject = "Confirma tu nuevo correo",
        message = (
            f"Tu código para confirmar el cambio de correo es: {code}\n\n"
            f"Este código expira en 10 minutos.\n"
            f"Si no solicitaste este cambio, ignora este mensaje."
        ),
        to = to,
    )


def send_password_reset_email(to: str, token) -> None:
    reset_url = f"{settings.FRONTEND_URL}/reset-password?token={token}"
    _send(
        subject = "Recupera tu contraseña",
        message = (
            f"Recibimos una solicitud para restablecer tu contraseña.\n\n"
            f"Usa este enlace para continuar:\n{reset_url}\n\n"
            f"Este enlace expira en 30 minutos.\n"
            f"Si no solicitaste esto, ignora este mensaje."
        ),
        to = to,
    )
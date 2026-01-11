import uuid
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, ContentSettings

from .config import settings


def _account_url() -> str:
    return f"https://{settings.AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net"


def blob_service_client() -> BlobServiceClient:
    # Works locally if you're logged in with `az login`,
    # and in Azure using the Container App managed identity.
    cred = DefaultAzureCredential()
    return BlobServiceClient(account_url=_account_url(), credential=cred)


def upload_image_bytes(data: bytes, content_type: str | None = None) -> dict:
    container = settings.AZURE_STORAGE_CONTAINER_NAME
    blob_name = f"{uuid.uuid4().hex}"

    bsc = blob_service_client()
    cc = bsc.get_container_client(container)

    # Ensure container exists (dev-friendly). In prod you may remove this.
    try:
        cc.create_container()
    except Exception:
        pass

    blob = cc.get_blob_client(blob_name)

    blob.upload_blob(
        data,
        overwrite=False,
        content_settings=ContentSettings(content_type=content_type or "application/octet-stream"),
    )

    if settings.PUBLIC_BLOB_BASE_URL:
        url = f"{settings.PUBLIC_BLOB_BASE_URL.rstrip('/')}/{blob_name}"
    else:
        url = blob.url

    return {"container": container, "blob": blob_name, "url": url}
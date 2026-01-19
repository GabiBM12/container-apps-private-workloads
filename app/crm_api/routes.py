from fastapi import APIRouter, UploadFile, File, HTTPException
from datetime import datetime
import uuid

from .models import Contact, ContactCreate
from .storage import upload_image_bytes
from .config import settings

router = APIRouter()

# In-memory store for Phase 1 (we’ll add a real DB later)
CONTACTS: dict[str, Contact] = {}


@router.get("/health")
def health():
    return {"status": "ok"}

@router.get("/health/mailgun")
def health_mailgun():
    # show only presence/length, never the value
    return {
        "mailgun_key_present": bool(settings.MAILGUN_EMAIL_API_KEY),
        "mailgun_key_len": len(settings.MAILGUN_EMAIL_API_KEY),
    }


@router.post("/contacts", response_model=Contact)
def create_contact(payload: ContactCreate):
    cid = uuid.uuid4().hex
    contact = Contact(id=cid, created_at=datetime.utcnow(), **payload.model_dump())
    CONTACTS[cid] = contact
    return contact


@router.get("/contacts", response_model=list[Contact])
def list_contacts():
    return list(CONTACTS.values())


@router.get("/contacts/{contact_id}", response_model=Contact)
def get_contact(contact_id: str):
    c = CONTACTS.get(contact_id)
    if not c:
        raise HTTPException(status_code=404, detail="Not found")
    return c


@router.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty file")

    result = upload_image_bytes(data, content_type=file.content_type)
    return {"uploaded": True, **result}
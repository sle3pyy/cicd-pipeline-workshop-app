from datetime import date, datetime

from pydantic import BaseModel


class MemberCreate(BaseModel):
    name: str
    email: str
    join_date: date | None = None
    is_active: bool = True


class MemberRead(MemberCreate):
    id: int
    created_at: datetime | None = None
    updated_at: datetime | None = None


class GetTogetherCreate(BaseModel):
    title: str
    description: str | None = None
    event_date: datetime
    location: str | None = None
    max_attendees: int | None = None


class GetTogetherRead(GetTogetherCreate):
    id: int
    created_at: datetime | None = None
    updated_at: datetime | None = None

from fastapi import HTTPException
from app.models.pydantic import SummaryPayloadSchema
from app.models.tortoise import TextSummary
from typing import Union


async def post(payload: SummaryPayloadSchema) -> int:
    summary = TextSummary(
        url=payload.url,
        summary="dummy summary",
    )
    await summary.save()
    return summary.id


async def get(id: int) -> Union[dict, None]:
    summary = await TextSummary.filter(id=id).first().values()
    if not summary:
        raise HTTPException(status_code=404, detail="Summary not found")
    return summary


async def get_all() -> list:
    summaries = await TextSummary.all().values()
    return summaries

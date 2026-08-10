"""Aggregates every v1 endpoint router.

Feature routers are mounted here as each stage of ROADMAP.md lands:

    Stage 2  auth        →  /api/v1/auth/*
    Stage 4  profile     →  /api/v1/profile
    Stage 4  medications →  /api/v1/medications
    Stage 6  assessments →  /api/v1/assessments
    Stage 8  history     →  /api/v1/history
    Stage 9  education   →  /api/v1/education
"""

from fastapi import APIRouter

api_router = APIRouter()

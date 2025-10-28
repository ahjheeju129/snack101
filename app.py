from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from pydantic import BaseModel
from datetime import datetime
import os

# 데이터베이스 설정
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "mysql+pymysql://snack101user:snack101user@mysql-service:3306/snack101")
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 데이터베이스 모델
class SnackReview(Base):
    __tablename__ = "snack_reviews"
    
    id = Column(Integer, primary_key=True, index=True)
    snack_name = Column(String, index=True)
    rating = Column(Float)
    review = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)

# Pydantic 모델
class ReviewCreate(BaseModel):
    snack_name: str
    rating: float
    review: str

class ReviewResponse(BaseModel):
    id: int
    snack_name: str
    rating: float
    review: str
    created_at: datetime

# 데이터베이스 테이블 생성
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Snack101 API")

# 정적 파일 서빙
app.mount("/static", StaticFiles(directory="static"), name="static")

# API 엔드포인트
@app.get("/")
async def read_root():
    with open("static/index.html", "r", encoding="utf-8") as f:
        return HTMLResponse(content=f.read())

@app.post("/reviews/", response_model=ReviewResponse)
async def create_review(review: ReviewCreate):
    db = SessionLocal()
    try:
        db_review = SnackReview(
            snack_name=review.snack_name,
            rating=review.rating,
            review=review.review
        )
        db.add(db_review)
        db.commit()
        db.refresh(db_review)
        return db_review
    finally:
        db.close()

@app.get("/reviews/", response_model=list[ReviewResponse])
async def get_reviews():
    db = SessionLocal()
    try:
        reviews = db.query(SnackReview).order_by(SnackReview.created_at.desc()).all()
        return reviews
    finally:
        db.close()

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

document.addEventListener('DOMContentLoaded', function() {
    const reviewForm = document.getElementById('reviewForm');
    const reviewsList = document.getElementById('reviewsList');

    // 폼 제출 처리
    reviewForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const formData = new FormData(reviewForm);
        const reviewData = {
            snack_name: formData.get('snackName'),
            rating: parseFloat(formData.get('rating')),
            review: formData.get('review')
        };

        try {
            const response = await fetch('/reviews/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(reviewData)
            });

            if (response.ok) {
                // 폼 초기화
                reviewForm.reset();
                // 리뷰 목록 새로고침
                loadReviews();
                alert('리뷰가 성공적으로 등록되었습니다!');
            } else {
                throw new Error('리뷰 등록에 실패했습니다.');
            }
        } catch (error) {
            console.error('Error:', error);
            alert('리뷰 등록 중 오류가 발생했습니다.');
        }
    });

    // 리뷰 목록 로드
    async function loadReviews() {
        try {
            reviewsList.innerHTML = '<div class="loading">리뷰를 불러오는 중...</div>';
            
            const response = await fetch('/reviews/');
            if (!response.ok) {
                throw new Error('리뷰를 불러올 수 없습니다.');
            }
            
            const reviews = await response.json();
            
            if (reviews.length === 0) {
                reviewsList.innerHTML = '<div class="loading">아직 등록된 리뷰가 없습니다.</div>';
                return;
            }

            reviewsList.innerHTML = reviews.map(review => `
                <div class="review-item">
                    <div class="review-header">
                        <span class="snack-name">${escapeHtml(review.snack_name)}</span>
                        <span class="rating">${'⭐'.repeat(Math.floor(review.rating))}</span>
                    </div>
                    <div class="review-text">${escapeHtml(review.review)}</div>
                    <div class="review-date">${new Date(review.created_at).toLocaleString('ko-KR')}</div>
                </div>
            `).join('');
        } catch (error) {
            console.error('Error:', error);
            reviewsList.innerHTML = '<div class="error">리뷰를 불러오는 중 오류가 발생했습니다.</div>';
        }
    }

    // HTML 이스케이프 함수
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // 별점 표시 함수
    function getStarRating(rating) {
        const fullStars = Math.floor(rating);
        const hasHalfStar = rating % 1 !== 0;
        let stars = '⭐'.repeat(fullStars);
        if (hasHalfStar) {
            stars += '⭐';
        }
        return stars;
    }

    // 페이지 로드 시 리뷰 목록 로드
    loadReviews();
});

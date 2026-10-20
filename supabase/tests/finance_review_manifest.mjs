import {verifyReviewedSql} from './review_manifest.mjs';
export async function verifyFinanceReview() {
 await verifyReviewedSql(new URL('../../docs/FINANCE_BACKEND_CHANGE_REVIEW.md',import.meta.url),new URL('../proposals/finance_business/',import.meta.url),3);
}

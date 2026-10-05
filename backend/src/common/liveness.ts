export interface LivenessChallengeProof {
  challengeType: 'BLINK' | 'HEAD_LEFT' | 'HEAD_RIGHT' | 'HEAD_UP' | 'SMILE';
  timestampMs: number;
  score: number; // 0.0 to 1.0
}

export function evaluateLivenessChallenges(proofs: LivenessChallengeProof[]): {
  passed: boolean;
  score: number;
  details: string;
} {
  if (!proofs || proofs.length < 2) {
    return {
      passed: false,
      score: 0.0,
      details: 'Insufficient liveness challenge prompts satisfied (Minimum 2 required).',
    };
  }

  const validProofs = proofs.filter((p) => p.score >= 0.7);
  const passed = validProofs.length >= 2;
  const avgScore =
    proofs.reduce((acc, curr) => acc + curr.score, 0) / proofs.length;

  return {
    passed,
    score: Math.round(avgScore * 10000) / 10000,
    details: passed
      ? `Passed ${validProofs.length}/${proofs.length} challenges successfully.`
      : `Failed interactive anti-spoofing verification.`,
  };
}

/**
 * Cosine similarity between two 128 or 512 dimension facial vectors
 */
export function computeCosineSimilarity(vecA: number[], vecB: number[]): number {
  if (vecA.length !== vecB.length) return 0.0;
  let dotProduct = 0.0;
  let normA = 0.0;
  let normB = 0.0;

  for (let i = 0; i < vecA.length; i++) {
    dotProduct += vecA[i] * vecB[i];
    normA += vecA[i] * vecA[i];
    normB += vecB[i] * vecB[i];
  }

  if (normA === 0 || normB === 0) return 0.0;
  return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
}

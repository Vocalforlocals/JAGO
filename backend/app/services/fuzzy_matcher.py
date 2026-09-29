"""
Fuzzy Matcher Engine for JAGO Verification Orchestrator
Implements Levenshtein distance, token-set similarity, and alias normalization.
Enforces the core principle: "Reuse what is verified. Revalidate what changes. Route what needs review."
Prevents automatic rejections of eligible students due to typographical or administrative naming variations.
"""

import re
from typing import Dict, Any, List, Set, Tuple

class FuzzyMatcher:
    # Common academic & institutional abbreviation expansions
    ABBREVIATIONS = {
        "bit": "birsa institute of technology",
        "iit": "indian institute of technology",
        "nit": "national institute of technology",
        "iiit": "indian institute of information technology",
        "aiims": "all india institute of medical sciences",
        "nlu": "national law university",
        "du": "delhi university",
        "jnu": "jawaharlal nehru university",
        "bhu": "banaras hindu university",
        "engg": "engineering",
        "tech": "technology",
        "inst": "institute",
        "univ": "university",
        "govt": "government",
        "col": "college",
        "dept": "department",
        "poly": "polytechnic",
        "mgmt": "management",
        "sci": "science",
    }

    @staticmethod
    def levenshtein_distance(s1: str, s2: str) -> int:
        """Computes the classic Levenshtein edit distance between two strings."""
        if len(s1) < len(s2):
            return FuzzyMatcher.levenshtein_distance(s2, s1)
        if len(s2) == 0:
            return len(s1)

        previous_row = list(range(len(s2) + 1))
        for i, c1 in enumerate(s1):
            current_row = [i + 1]
            for j, c2 in enumerate(s2):
                insertions = previous_row[j + 1] + 1
                deletions = current_row[j] + 1
                substitutions = previous_row[j] + (c1 != c2)
                current_row.append(min(insertions, deletions, substitutions))
            previous_row = current_row

        return previous_row[-1]

    @staticmethod
    def clean_text(text: str) -> str:
        """Lowercases, removes special characters, and normalizes whitespace."""
        text = text.lower().strip()
        text = re.sub(r"[^\w\s]", " ", text)
        return re.sub(r"\s+", " ", text).strip()

    @classmethod
    def expand_abbreviations(cls, text: str) -> str:
        """Expands common institutional abbreviations into canonical words."""
        cleaned = cls.clean_text(text)
        tokens = cleaned.split()
        expanded = []
        for t in tokens:
            if t in cls.ABBREVIATIONS:
                expanded.append(cls.ABBREVIATIONS[t])
            else:
                expanded.append(t)
        return " ".join(expanded)

    @classmethod
    def token_set_similarity(cls, s1: str, s2: str) -> Tuple[float, Set[str], Set[str]]:
        """
        Computes Jaccard-based token similarity after abbreviation expansion.
        Returns: (similarity_score 0.0-1.0, intersection_tokens, symmetric_diff_tokens)
        """
        exp1 = set(cls.expand_abbreviations(s1).split())
        exp2 = set(cls.expand_abbreviations(s2).split())

        if not exp1 and not exp2:
            return 1.0, set(), set()
        if not exp1 or not exp2:
            return 0.0, set(), exp1 | exp2

        intersection = exp1 & exp2
        union = exp1 | exp2
        diff = exp1 ^ exp2

        jaccard = len(intersection) / len(union)
        return jaccard, intersection, diff

    @classmethod
    def composite_similarity(cls, s1: str, s2: str) -> float:
        """
        Calculates a balanced similarity metric combining Levenshtein ratio and Token Set ratio.
        """
        clean1 = cls.expand_abbreviations(s1)
        clean2 = cls.expand_abbreviations(s2)

        if clean1 == clean2:
            return 1.0

        max_len = max(len(clean1), len(clean2))
        if max_len == 0:
            return 1.0

        dist = cls.levenshtein_distance(clean1, clean2)
        lev_ratio = 1.0 - (dist / max_len)

        token_ratio, _, _ = cls.token_set_similarity(s1, s2)

        # 60% Token overlap (handles word order) + 40% edit distance (handles spelling)
        composite = (token_ratio * 0.60) + (max(0.0, lev_ratio) * 0.40)
        return round(composite, 4)

    @classmethod
    def match_institution(cls, student_input: str, registry_record: str) -> Dict[str, Any]:
        """
        Analyzes an institution match and provides structured discrepancy tolerance metadata.
        """
        score = cls.composite_similarity(student_input, registry_record)
        score_pct = int(score * 100)
        token_sim, matched, diff = cls.token_set_similarity(student_input, registry_record)

        if score >= 0.90:
            tier = "Tier 1: High Alignment (Alias Match)"
            status = "verified"
            requires_review = False
            action_desc = "High-confidence institutional alias match. Automatically validated."
        elif score >= 0.50:
            tier = "Tier 2: Acceptable Tolerance Variance"
            status = "mismatch"
            requires_review = True
            action_desc = (
                f"Discrepancy detected ({score_pct}% similarity), but within tolerance ceiling. "
                "Application PROTECTED from auto-rejection and auto-routed to Manual Review Queue."
            )
        else:
            tier = "Tier 3: Low Alignment (Discrepancy)"
            status = "action_required"
            requires_review = True
            action_desc = "Substantial name divergence detected. Officer review required with institutional bonafide cross-check."

        return {
            "field": "institution",
            "student_record": student_input,
            "registry_record": registry_record,
            "similarity_score": score,
            "similarity_percentage": score_pct,
            "status": status,
            "tier": tier,
            "requires_review": requires_review,
            "matched_tokens": sorted(list(matched)),
            "differing_tokens": sorted(list(diff)),
            "action_desc": action_desc,
            "auto_rejected": False,
            "policy_applied": "JAGO Zero-Rejection Mismatch Tolerance Protocol"
        }

    @classmethod
    def match_student_name(cls, input_name: str, registry_name: str) -> Dict[str, Any]:
        """
        Checks student full name across Aadhaar and state certificates (handles middle names & reordering).
        """
        score = cls.composite_similarity(input_name, registry_name)
        score_pct = int(score * 100)

        is_verified = (score >= 0.70)
        return {
            "field": "student_name",
            "input_name": input_name,
            "registry_name": registry_name,
            "similarity_percentage": score_pct,
            "status": "verified" if is_verified else "mismatch",
            "auto_rejected": False,
            "message": "Name validated across central and state identities." if is_verified else "Minor phonetic/naming variation routed to review."
        }

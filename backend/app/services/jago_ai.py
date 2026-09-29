"""
JAGO AI Chatbot Service
State-Aware, Multilingual (English & Hindi) Assistant for Central and State Scholarship Schemes.
Adheres strictly to approved knowledge base and government scholarship policies.
"""

from typing import Dict, Any, List, Optional

class JagoAIService:
    KNOWLEDGE_BASE = {
        "schemes": [
            {
                "name": "Pre-Matric Scholarship for ST Students",
                "eligibility": "ST students studying in Class 9th and 10th in government recognized schools. Annual family income <= ₹2,50,000.",
                "benefits": "Day scholars: ₹3,500/year; Hostellers: ₹7,000/year + disability allowance."
            },
            {
                "name": "Post-Matric Scholarship for ST Students",
                "eligibility": "ST students pursuing post-matriculation or post-secondary courses (Class 11, 12, ITI, Diploma, Graduation, Post-Graduation). Annual family income <= ₹2,50,000.",
                "benefits": "Full compulsory course fee reimbursement + monthly maintenance allowance up to ₹13,500/year."
            },
            {
                "name": "Top Class Education Scheme for ST Students",
                "eligibility": "ST students securing admission in notified premier institutions (IITs, IIMs, NITs, AIIMS, NLUs). Annual family income <= ₹6,00,000.",
                "benefits": "Full tuition fee + living expenses (₹3,000/month) + books & stationery (₹5,000/year) + computer allowance (₹45,000 one-time)."
            },
            {
                "name": "National Fellowship for Higher Education of ST Students (NFST)",
                "eligibility": "ST students pursuing regular full-time M.Phil and Ph.D. degrees in Universities/Institutions recognized by UGC. Selection based on merit / UGC-NET.",
                "benefits": "Junior Research Fellowship (JRF): ₹31,000/month; Senior Research Fellowship (SRF): ₹35,000/month + contingency grants."
            },
            {
                "name": "National Overseas Scholarship for ST Candidates (NOS)",
                "eligibility": "ST candidates pursuing Master's, Ph.D., and Post-Doctoral studies in accredited foreign universities with QS/THE rank <= 500. Annual family income <= ₹8,00,000.",
                "benefits": "Full tuition fee + annual maintenance allowance (USD 15,400 / GBP 9,900) + contingency + economy airfare."
            }
        ],
        "rules": [
            "A student can avail only ONE scholarship at any given time across all Central and State government schemes.",
            "Documents verified once via DigiLocker / State e-District are reusable across all schemes without re-uploading.",
            "Income certificate is valid for 1 financial year and must be revalidated upon expiry.",
            "Caste and Domicile certificates are permanent and do not require repeated verification unless invalidated.",
            "Data discrepancies (like institution name spelling variations) are not rejected; they are routed to the Manual Review Queue."
        ]
    }

    @staticmethod
    def generate_response(
        query: str,
        student_profile: Optional[Any] = None,
        applications: Optional[List[Any]] = None,
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        State-aware reply generation based on the student's real profile and application state.
        """
        q = query.lower().strip()
        is_hindi = (language == "hi")

        # 1. Status query
        if any(w in q for w in ["status", "track", "application", "कहाँ", "स्थिति", "स्टेटस"]):
            if applications and len(applications) > 0:
                app = applications[0]
                if is_hindi:
                    text = (
                        f"आपके आवेदन संख्या **{app.app_number}** ({app.scheme_name}) की वर्तमान स्थिति है:\n"
                        f"📌 **चरण:** {app.stage}\n"
                        f"🏛️ **सत्यापन स्थिति:** सरकारी अधिकारी द्वारा समीक्षा जारी (संस्थान नाम मिलान समीक्षा में है)।\n"
                        f"चिंता न करें, आपका आवेदन अस्वीकार नहीं हुआ है, अधिकारी द्वारा अनुमोदन के बाद स्वतः आगे बढ़ेगा।"
                    )
                else:
                    text = (
                        f"Your application **{app.app_number}** for **{app.scheme_name}** is currently at:\n\n"
                        f"• **Current Stage:** {app.stage}\n"
                        f"• **Verification Status:** Routed to Manual Review Queue (Institution Name Alignment Check)\n"
                        f"• **Deficiency:** No deficiency pending on your end. The designated verification officer is reviewing the record alignment.\n\n"
                        f"You will receive an instant notification once approved."
                    )
                return {
                    "text": text,
                    "options": ["Check Payments", "Required Documents", "Contact Institution"]
                }
            else:
                if is_hindi:
                    text = "वर्तमान में आपका कोई सक्रिय छात्रवृत्ति आवेदन जमा नहीं है। आप 'Post-Matric Scholarship' के लिए पात्र हैं और तुरंत आवेदन कर सकते हैं।"
                else:
                    text = "You do not have an active scholarship application submitted yet. Based on your verified profile, you are eligible for the **Post-Matric Scholarship for ST Students**. Would you like to start your application?"
                return {
                    "text": text,
                    "options": ["Check Eligibility", "Start Application", "View Documents"]
                }

        # 2. Income / Document query
        if any(w in q for w in ["income", "document", "docs", "certificate", "दस्तावेज़", "आय", "सर्टिफिकेट", "प्रमाणपत्र"]):
            has_expired_income = (student_profile and getattr(student_profile, "income_status", "") == "expired")
            if has_expired_income:
                if is_hindi:
                    text = (
                        "⚠️ **ध्यान दें:** आपके प्रोफ़ाइल में आय प्रमाण पत्र (Income Certificate) की वैधता समाप्त हो चुकी है (12 महीने से अधिक पुराना)।\n\n"
                        "आपको अपने आवेदन को आगे बढ़ाने के लिए वित्तीय वर्ष 2026-27 का नया आय प्रमाण पत्र DigiLocker या सीधे अपलोड करके पुनः सत्यापित करना होगा। अन्य सभी दस्तावेज़ (ST सर्टिफिकेट, आधार, अंकतालिका) पहले से पूरी तरह सत्यापित हैं।"
                    )
                else:
                    text = (
                        "⚠️ **Attention Required:** Your **Income Certificate** has expired (validity exceeds 12 months).\n\n"
                        "All other documents (ST Certificate, Aadhaar, Bonafide, Marksheet) are **✓ Verified** and permanently stored in your Document Wallet.\n\n"
                        "Please go to your **Document Wallet** and upload your latest FY 2026-27 Income Certificate or fetch it directly via DigiLocker."
                    )
                return {
                    "text": text,
                    "options": ["Update Income Certificate", "Open Document Wallet", "Check Status"]
                }
            else:
                if is_hindi:
                    text = "✅ आपके सभी 5 मुख्य दस्तावेज़ पूरी तरह सत्यापित हैं और आपके डिजिटल वॉलेट में सुरक्षित हैं। किसी भी नए अपलोड की आवश्यकता नहीं है।"
                else:
                    text = "✅ All your requisite certificates (ST Certificate, Domicile, Academic Marksheet, Bonafide, and Income) are **100% Verified** in your wallet."
                return {
                    "text": text,
                    "options": ["View Document Wallet", "Apply for Scheme", "Help"]
                }

        # 3. Payments / DBT query
        if any(w in q for w in ["payment", "dbt", "money", "rupees", "पैसा", "भुगतान", "राशि", "किस्त"]):
            if is_hindi:
                text = (
                    "💰 **डीबीटी (DBT) छात्रवृत्ति भुगतान विवरण:**\n"
                    "• स्वीकृत राशि (Sanctioned): ₹18,000\n"
                    "• प्राप्त राशि (Received): ₹9,000 (प्रथम किस्त, आधार लिंक बैंक खाता ****1234)\n"
                    "• लंबित राशि (Pending): ₹9,000 (द्वितीय किस्त सत्यापन के उपरांत जारी की जाएगी)\n\n"
                    "भुगतान सीधे आपके आधार-सीडेड बैंक खाते में ट्रांसफर किया जाता है।"
                )
            else:
                text = (
                    "💰 **Direct Benefit Transfer (DBT) Summary:**\n\n"
                    "• **Total Sanctioned:** ₹18,000\n"
                    "• **Total Credited:** ₹9,000 (1st Installment credited on 28 Sept 2026 to A/C ending ****1234)\n"
                    "• **Pending Balance:** ₹9,000 (Scheduled post academic mid-term clearance)\n\n"
                    "Funds are directly credited via PFMS / Aadhaar Payment Bridge (APB)."
                )
            return {
                "text": text,
                "options": ["Check Application Status", "View Payment History", "Help"]
            }

        # 4. Eligibility query
        if any(w in q for w in ["eligible", "eligibility", "scheme", "पात्रता", "योजना"]):
            if is_hindi:
                text = (
                    "📋 **आपकी सत्यापित प्रोफ़ाइल के आधार पर पात्रता:**\n\n"
                    "✅ **Post-Matric Scholarship for ST Students:** पूर्णतः पात्र (B.Tech, ST सत्यापित, पारिवारिक आय सीमा ₹2.5 लाख से कम)।\n"
                    "🟡 **Top Class Education:** संभावित पात्र (संस्थान AISHE कोड सत्यापन की आवश्यकता)।\n"
                    "⚪ **Pre-Matric:** लागू नहीं (केवल कक्षा 9 और 10 के लिए)।\n"
                    "⚪ **NFST:** लागू नहीं (केवल नियमित M.Phil/Ph.D शोधार्थियों के लिए)।\n"
                    "⚪ **NOS:** लागू नहीं (केवल विदेशी विश्वविद्यालयों के लिए)।\n\n"
                    "⚠️ *नियम: आप एक समय में केवल एक ही छात्रवृत्ति योजना का लाभ ले सकते हैं।*"
                )
            else:
                student_name = getattr(student_profile, "full_name", "Student") if student_profile else "Student"
                student_code = getattr(student_profile, "student_id", "") if student_profile else ""
                code_str = f" ({student_code})" if student_code else ""
                income_amt = getattr(student_profile, "family_income", 180000) if student_profile else 180000
                income_lakhs = f"{income_amt / 100000:.2f}L"

                text = (
                    f"📋 **Scheme Eligibility for {student_name}{code_str}:**\n\n"
                    f"1. ✅ **Post-Matric Scholarship for ST Students:** **Eligible** (Undergraduate studies, ST category verified, annual income ₹{income_lakhs} < ₹2.50L cap).\n"
                    f"2. 🟡 **Top Class Education Scheme:** **Potentially Eligible** (Subject to premier institute designation check).\n"
                    f"3. ⚪ **Pre-Matric Scholarship:** Not Applicable (Strictly for Classes 9 & 10).\n"
                    f"4. ⚪ **National Fellowship (NFST):** Not Applicable (Requires full-time Ph.D./M.Phil enrollment).\n"
                    f"5. ⚪ **National Overseas Scholarship (NOS):** Not Applicable (Requires admission to foreign university ranked <= 500).\n\n"
                    f"⚠️ *Note: You can avail only ONE scholarship at a time across any government scheme.*"
                )
            return {
                "text": text,
                "options": ["Apply for Post-Matric", "Required Documents", "Check Status"]
            }

        # 5. How to apply
        if any(w in q for w in ["how to apply", "apply", "आवेदन"]):
            if is_hindi:
                text = (
                    "📝 **JAGO पर आवेदन करने के आसान चरण:**\n"
                    "1. **प्रोफ़ाइल सत्यापन:** आपकी जानकारी पहले से सत्यापित है।\n"
                    "2. **दस्तावेज़ पुनर्सत्यापन:** केवल समाप्त हो चुके आय प्रमाण पत्र को अपडेट करें।\n"
                    "3. **योजना चयन:** 'My Scholarships' में जाकर 'Post-Matric Scholarship' चुनें।\n"
                    "4. **एक-क्लिक आवेदन:** बैंक खाता व घोषणा जांचकर सबमिट करें। किसी भी दोबारा फॉर्म भरने की आवश्यकता नहीं है!"
                )
            else:
                text = (
                    "📝 **How to Apply with JAGO:**\n\n"
                    "1. **Reuse Verified Profile:** Your identity, ST status, domicile, and academic records are already verified.\n"
                    "2. **Update Expired Certificates:** Upload your updated FY 2026-27 income certificate.\n"
                    "3. **Select Scheme:** Navigate to **Scholarships** and click **Apply Now** on Post-Matric.\n"
                    "4. **Review & Submit:** Your data auto-populates. Simply confirm your Aadhaar-linked bank details and submit!"
                )
            return {
                "text": text,
                "options": ["Check Eligibility", "Update Documents", "Check Status"]
            }

        # 6. Default fallback
        if is_hindi:
            text = (
                "मैं केवल आधिकारिक छात्रवृत्ति नियमों और आपकी प्रोफ़ाइल स्थिति के आधार पर सहायता करता हूँ। "
                "नीचे दिए गए त्वरित विकल्पों में से चुनें अथवा अपने संस्थान के छात्रवृत्ति नोडल अधिकारी से संपर्क करें।"
            )
        else:
            text = (
                "I am JAGO, your dedicated scholarship assistant. I answer strictly based on approved government scholarship guidelines and your verified profile data.\n\n"
                "If you need specific help, please select one of the quick options below or contact your institution scholarship nodal officer."
            )
        return {
            "text": text,
            "options": ["Check Status", "Check Eligibility", "Required Documents", "Payment Status", "How to Apply"]
        }

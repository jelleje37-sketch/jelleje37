# D11: CHANGE REQUEST LOG & CR-001
## PulseWell Digital Intake & Client Experience Portal

**Document Version:** 1.0  
**Last Updated:** [Date]  
**Project:** PulseWell Digital Intake & Client Experience Portal  
**Prepared By:** [Author Name]  
**Status:** Under Review / Approved  

---

## DOCUMENT OVERVIEW

This document records the formal Change Request Log for the PulseWell project and documents Change Request CR-001. It captures the rationale, impact assessment, risk analysis, and Change Control Board (CCB) disposition for a proposed scope enhancement affecting third-party health data integration and synchronization capabilities.

**Change Control Board (CCB):** Project Sponsor, Project Manager, Technical Lead, Compliance Lead, Product Manager  
**Change Request Identifier:** CR-001  
**Change Request Type:** Scope / Functional Enhancement / Integration Change  

---

## 1. CHANGE REQUEST LOG

| CR ID | Date Raised | Requestor | Change Type | Priority | Current Status | Summary |
|-------|-------------|-----------|-------------|----------|----------------|---------|
| CR-001 | [Date] | Product Manager | Functional Enhancement | High | Pending CCB Review | Add Apple HealthKit / Google Fit API schema support and bi-directional sync enhancement |
| CR-002 | [Date] | Technical Lead | Technical Change | Medium | Draft | Improve data mapping strategy for CRM synchronization and reconciliation |
| CR-003 | [Date] | Compliance Lead | Compliance Change | Medium | Draft | Update consent and retention workflow language for wellness data sharing |

---

## 2. CHANGE REQUEST CR-001

### 2.1 Change Request Summary

**Change Request ID:** CR-001  
**Title:** Add Apple HealthKit / Google Fit API schema support and bi-directional data synchronization enhancement  
**Proposed By:** Product Manager  
**Date Requested:** [Date]  
**Priority:** High  
**Category:** Functional enhancement / third-party integration  

### 2.2 Reason for Change

The product team is proposing an enhancement to support external wellness data sources via Apple HealthKit and Google Fit APIs. The goal is to improve the client experience by allowing connected health metrics to synchronize into the PulseWell portal and be reflected in client progress tracking and recommendation logic. This enhancement is intended to improve user engagement, reduce manual entry burden, and enable more personalized exercise recommendations based on client activity and wellness trends.

The requested enhancement would allow:
- import of activity and wellness data from Apple HealthKit and Google Fit
- normalization of data objects into the PulseWell schema
- bi-directional synchronization between the portal and connected wellness data sources
- richer personalization for recommendation engines and dashboard insights

---

## 3. CURRENT BASELINE IMPACT ASSESSMENT

### 3.1 Scope Impact

**Current Baseline Scope:** Portal includes intake, readiness assessment, client dashboard, integrations, and support tools as defined in the approved baseline.

**Proposed Scope Change:**
- Add external wearable API data ingestion support
- Add schema mapping and reconciliation rules for wellness data types
- Add synchronization service for bi-directional updates between portal and third-party APIs
- Expand dashboard analytics to display connected wellness metrics
- Update privacy and consent handling related to third-party consumer data sharing

**Scope Impact:** Medium  
**Assessment:** This change is outside the original phase-one requirements baseline but aligns with the long-term user experience strategy and strategic product roadmap.

### 3.2 Schedule Impact Analysis

| Schedule Element | Baseline | Requested Change | Impact |
|-----------------|----------|------------------|--------|
| Requirements and design | Existing approved path | Additional API schema review and data model work | +1 week |
| Development effort | Included in current build plan | Additional integration and data mapping tasks | +2 weeks |
| Testing and UAT | Pre-allocated validation | Additional compatibility and sync validation | +1 week |
| Overall Project Schedule | 14-week baseline | Revised target if approved | +2-3 weeks |

**Schedule Impact:** High  
**Assessment:** The enhancement would extend the project schedule if implemented during the current phase. This may affect the original go-live date unless resources are re-sequenced or scope is deferred.

### 3.3 Cost Impact Analysis

| Cost Component | Baseline Estimate | Estimated Change | Revised Estimate |
|----------------|------------------|-----------------|------------------|
| Internal Labor | $24,600 | +$3,400 | $28,000 |
| External Services | $8,200 | +$1,600 | $9,800 |
| Cloud / Infrastructure | $3,800 | +$700 | $4,500 |
| Hardware / Equipment | $1,110 | $0 | $1,110 |
| Management Reserve | $4,190 | -$1,200 | $2,990 |
| **Total** | **$41,900** | **+$3,500** | **$45,400** |

**Cost Impact:** Medium-High  
**Assessment:** The enhancement adds estimated cost of approximately $3,500 and would require reallocation or additional approval from sponsor and governance bodies.

---

## 4. RISK ASSESSMENT

### 4.1 Risk Register Impact

| Risk Area | Impact | Severity | Assessment |
|-----------|--------|----------|------------|
| Technical integration risk | API schema differences and data contract complexity | High | Additional testing and schema mapping required |
| Data privacy risk | Third-party health data sharing introduces consent and retention considerations | High | Requires legal and compliance review |
| Schedule risk | Additional work extends critical path | High | Could threaten go-live target |
| Cost risk | Additional development and external support increases budget | Medium | Manageable if approved early and controlled |
| User adoption benefit | Positive if implemented well | Medium | Enhanced personalization may improve engagement |

### 4.2 Risk Response

- Validate API schema mapping before development begins
- Require consent management updates and audit logging
- Complete integration test planning before code approval
- Monitor resource impact and re-sequence lower-priority tasks
- Use phased rollout if full bi-directional sync is not feasible within current phase

---

## 5. CHANGE CONTROL BOARD (CCB) DISPOSITION

### 5.1 CCB Review Outcome

**CCB Decision:** Provisionally Approved with Conditions  
**Approval Date:** [Date]  
**Decision Rationale:** The requested enhancement has measurable value for user engagement and personalization, but it introduces material impacts to cost, schedule, and compliance requirements. Approval is granted only if the scope is limited to the minimum viable feature set and if the schedule impact is formally managed.

### 5.2 Conditions of Approval
- Scope shall be limited to core data ingestion and synchronization relevant to Phase 1 outcomes.
- Bi-directional sync must be implemented using controlled data mapping and validation rules.
- Legal and compliance approval is required before production release.
- Budget impact must remain within approved contingency or sponsor-approved change request.
- Any additional scope beyond the minimum viable feature must be deferred to a future phase.

### 5.3 CCB Decision Summary

| Field | Decision |
|-------|----------|
| Approval Status | Approved with conditions |
| Effective Date | [Date] |
| Implementation Window | [Proposed date range] |
| Required Follow-Up | Change impact statement, revised plan, compliance sign-off |

---

## 6. IMPACTED DOCUMENTS AND WORKSTREAMS

| Workstream | Impact |
|-----------|--------|
| Requirements Baseline | Additional functional requirements and acceptance criteria |
| Design | UX adjustments and third-party data connection flows |
| Technical Architecture | New API integration patterns and data transforms |
| Security & Compliance | Consent, access, and data governance controls |
| Budget Baseline | Additional labor, services, and cloud cost |
| Schedule | Revised timeline and milestone alignment |

---

## 7. APPROVAL AND SIGN-OFFS

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Change Requestor | [Name] | ________________ | ______ |
| Project Manager | [Project Manager Name] | ________________ | ______ |
| Project Sponsor | [Sponsor Name] | ________________ | ______ |
| Technical Lead | [Name] | ________________ | ______ |
| Compliance Lead | [Name] | ________________ | ______ |
| CCB Chair | [Name] | ________________ | ______ |

---

## 8. CR-001 FINAL STATUS

**Status:** Approved with Conditions  
**Implementation Window:** [Date Range]  
**Next Review Date:** [Date]  
**Reference to Portfolio Change Log:** Included in project change log and weekly governance reporting  

---

**Document Classification:** Internal - Confidential  
**Last Updated:** [Date]  
**Next Review Date:** [Date]

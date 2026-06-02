# Interview Questions — John Michael

**Role on resume:** Senior .NET & Azure Engineer | Full-Stack (React/Angular) | Cloud-Native APIs & Microservices | Legacy Modernization | Event-Driven Architecture
**Location:** Houston, TX
**Prepared:** 2026-06-02

---

## 0. Resume clarifications (ask early, keep it conversational)

These aren't gotchas — just give him room to explain.

- Your **Coverys** and **Med-IQ** roles both show **Jan 2022 – Dec 2024**. Were these concurrent, was one through the other (contract/parent company), or is one a date typo? Walk me through that period.
- **Sam's Club (Jan 2019 – Jan 2022)** overlaps with your **Microsoft Student Ambassador** and **Google Developer Student Club** dates. How did you balance full-time engineering with the student/community roles?
- Your most recent role, **PoMful**, ran ~11 months and ended Oct 2025. What's the story there — contract end, looking for the next thing, etc.?
- Your degree is listed 2018–2021 while you were also working full-time from 2019. Were you working and studying simultaneously?

---

## 1. Warm-up / motivation

- Walk me through your career so far in two or three minutes — what's the throughline?
- What kind of problems do you most enjoy working on? Backend depth, full-stack breadth, or architecture?
- What are you looking for in your next role, and what would make this one a strong fit?
- You describe yourself as a "fast learner who adapts to new stacks." Tell me about the last time you had to learn something unfamiliar under deadline pressure.

---

## 2. .NET & legacy modernization

You list multiple ".NET Framework → .NET Core / .NET 6" migrations.

- Pick the migration you're proudest of. What was the starting state, and how did you sequence the work?
- How did you keep the app shippable during the migration — strangler pattern, parallel run, big-bang cutover?
- At Sam's Club you led an **AWS-to-Azure migration with "zero downtime."** How did you actually guarantee zero downtime, and how did you measure/verify it?
- What's the hardest .NET Framework dependency you had to break or replace (e.g., System.Web, WCF, app domains)?
- When does it make sense to NOT modernize a legacy system?

---

## 3. Azure & cloud-native architecture

- Walk me through an event-driven workflow you built with **Azure Functions + Service Bus**. What triggered it, and what was the message flow?
- How do you handle **idempotency and poison messages** with Service Bus queues?
- Functions: how do you deal with cold starts, scaling limits, and long-running work? When would you choose Durable Functions vs. plain Functions vs. a hosted service?
- How do you decide between **Service Bus queues vs. topics/subscriptions vs. Event Grid/Event Hubs**?
- How do you do observability across serverless components — App Insights, distributed tracing, correlation IDs?
- What does your cost-control thinking look like on a serverless Azure footprint?

---

## 4. APIs, performance & data

- You claim **Redis caching improved API performance by 65%.** What was slow, what did you cache, and how did you handle invalidation/staleness?
- The **risk-scoring system processed 50,000+ records/day.** Was that batch or streaming? Where were the bottlenecks and how did you scale it?
- Talk me through a SQL performance problem you diagnosed and fixed (indexing, query plan, N+1, locking).
- You integrated **Snowflake with SQL Server.** Why both? How did you split OLTP vs. analytical workloads and keep them in sync?
- How do you approach **API versioning** — you said you "established versioning standards." What were they and why?
- Tell me about a caching bug or stale-data incident that bit you.

---

## 5. Authentication & security

- You implemented **Azure AD B2C SSO across Shopify and mobile.** Walk me through the token flow end-to-end (auth code + PKCE? token refresh? session handling on mobile?).
- What's tricky about B2C custom policies / user flows? Anything you'd avoid in hindsight?
- At Coverys you worked on **HIPAA-compliant workflows.** What did HIPAA compliance concretely require of you as an engineer (PHI handling, audit logging, encryption, access controls)?
- You integrated **Contrast Security** for vulnerability monitoring. What classes of issues did it actually catch, and how did you triage findings?
- How do you store and rotate secrets in an Azure environment?

---

## 6. Full-stack & mobile

- You list both **React and Angular** plus **React Native**. Which is your strongest, and how do you decide between them for a new project?
- Tell me about the **real-time check-in / pause / resume** mobile feature. What was the state management and connectivity model (offline support, reconnection)?
- The **cross-platform hardware sensor communication** — what protocol/transport, and what was the hardest reliability problem?
- How do you keep a React or Angular front end performant as it grows (bundle size, re-renders, data fetching)?

---

## 7. System design (pick one, go deep)

- Design an event-driven claims-processing pipeline that ingests 50k records/day, scores risk, and surfaces results in a dashboard for 500+ users. Where are the failure points?
- Design SSO for a company with a Shopify storefront, a mobile app, and internal tools. How do identities and sessions flow?
- How would you design for **at-least-once vs. exactly-once** processing in a Service Bus workflow?

---

## 8. Engineering practices & CI/CD

- Describe your CI/CD pipeline at PoMful or Coverys — stages, gates, what's automated vs. manual.
- How do you approach testing for serverless + message-driven systems where so much is integration-level?
- What's your bar for a PR to get merged? You mention leading code reviews — what do you look for?
- Tell me about a production incident you owned end-to-end: detection → diagnosis → fix → prevention.

---

## 9. Leadership, collaboration & communication

- You **mentored interns and junior developers.** Tell me about someone you helped grow — what did you change in how you mentor over time?
- You ran **hackathons and a Google Developer Student Club.** What did leading a technical community teach you that you use at work?
- Describe a time you disagreed with an architectural decision. How did you handle it?
- You emphasize "strong documentation habits." Show me / describe a piece of documentation you're proud of. Who was the audience?
- Tell me about a time you had to explain a complex technical tradeoff to a non-technical stakeholder (e.g., the C-suite Power BI dashboards).

---

## 10. Behavioral / judgment

- Tell me about a project that didn't go well. What would you do differently?
- A deadline is slipping and you can ship something correct-but-slow or fast-but-risky. How do you decide?
- What's a strong technical opinion you hold that others often disagree with?
- When you join a new codebase, what are the first things you do?

---

## 11. Closing

- What questions do you have for us?
- Is there anything on your resume we didn't cover that you think is your best work?
- What's your timeline and what other processes are you in?

---

### Quick interviewer notes / red flags to watch for
- Can he speak to the **65%** and **50k/day** numbers with specifics, or are they vague?
- Does the **dual Jan 2022–Dec 2024** (Coverys + Med-IQ) hold up to a clean explanation?
- Depth check: B2C token flow and Service Bus idempotency are good "does he really know it" probes.
- Breadth claim (React + Angular + React Native + .NET + Snowflake) — push for *depth* on at least one, don't let breadth substitute for it.

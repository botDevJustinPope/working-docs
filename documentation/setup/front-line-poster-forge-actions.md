# Front Line Poster Forge Actions Setup

How to let the ChatGPT custom GPT "Front Line Poster Forge" call external tooling.

This does not let tools call the hosted GPT by URL. The supported direction for GPT Actions is:

```text
Front Line Poster Forge in ChatGPT -> your HTTPS API -> repo tooling / job queue / scripts
```

For tooling that needs to invoke Forge-like behavior directly, use the API-equivalent workflow in
`documentation/skills/external-services/front-line-poster-forge.md`.

---

## Setup Checklist

1. Decide what the GPT is allowed to do.
   - Good: create a poster job, return a normalized prompt, check job status, return artifact
     metadata.
   - Avoid: arbitrary shell commands, arbitrary file writes, direct access to secrets, broad
     filesystem paths.
2. Build or choose a small HTTPS API.
   - The GPT Builder must be able to reach it over the public internet.
   - For local testing, use a temporary tunnel only if you accept the exposure risk.
   - For normal use, deploy a small service with API key or OAuth authentication.
3. Create an Action in GPT Builder.
   - Open the GPT editor.
   - Go to `Configure` -> `Actions`.
   - Select `Create new action`.
   - Configure authentication.
   - Paste or import the OpenAPI schema.
   - Test in Preview before publishing.
4. For a public GPT with Actions, provide a valid privacy policy URL.
5. Record the Action details in
   `documentation/skills/external-services/front-line-poster-forge-exported-instructions.md`.

Official setup reference:

<https://help.openai.com/en/articles/9442513-configuring-actions-in-gpts>

---

## Minimal Action Shape

The safest first Action is a job-creation endpoint. It accepts structured poster intent and
returns a job ID plus the next human/tooling step. The endpoint can store the job in a queue,
write a controlled JSON file, or call a narrow backend process.

Avoid letting the GPT pass raw command lines to your machine.

---

## Starter OpenAPI Schema

Replace `https://example.your-domain.com` with your real HTTPS API. Keep the operation names
stable; GPT Builder uses them to identify available actions.

```yaml
openapi: 3.1.0
info:
  title: Front Line Poster Forge Tool Bridge
  version: 0.1.0
  description: Creates controlled poster-generation jobs for Working-Docs tooling.
servers:
  - url: https://example.your-domain.com
paths:
  /poster-jobs:
    post:
      operationId: createPosterJob
      summary: Create a Front Line Poster Forge poster job
      security:
        - ApiKeyAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - title
                - outputNeeded
              properties:
                workItemId:
                  type: string
                  description: Optional PBI, ticket, or work item ID.
                title:
                  type: string
                  description: Poster or work item title.
                productArea:
                  type: string
                problem:
                  type: string
                desiredOutcome:
                  type: string
                stakeholders:
                  type: array
                  items:
                    type: string
                visualDirection:
                  type: string
                requiredText:
                  type: array
                  items:
                    type: string
                textToAvoid:
                  type: array
                  items:
                    type: string
                outputNeeded:
                  type: string
                  enum:
                    - prompt
                    - image
                    - critique
                    - alternate-concepts
                targetFolder:
                  type: string
                  description: Repo-relative preferred output folder.
      responses:
        "200":
          description: Poster job accepted.
          content:
            application/json:
              schema:
                type: object
                required:
                  - jobId
                  - status
                  - nextStep
                properties:
                  jobId:
                    type: string
                  status:
                    type: string
                    enum:
                      - queued
                      - accepted
                      - rejected
                  nextStep:
                    type: string
                  artifactPath:
                    type: string
                    description: Repo-relative artifact path when available.
components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: X-FLPF-Action-Key
```

---

## Server Guardrails

Whatever API receives this Action should enforce these rules server-side:

- Authenticate every write request.
- Validate JSON against a schema before accepting it.
- Store raw requests and generated prompts for traceability.
- Restrict output paths to approved repo folders such as `AI-Content/`.
- Never execute arbitrary command text from the GPT.
- Require a separate confirmation step before expensive batch image generation.
- Keep secrets in environment variables or a secrets manager, not in the OpenAPI schema.

---

## Repo Recording

After the Action works, update:

- `documentation/skills/external-services/front-line-poster-forge-exported-instructions.md`
  with the Action name, operation ID, auth type, and schema location.
- `documentation/skills/external-services/front-line-poster-forge.md` if the approved workflow
  changes.


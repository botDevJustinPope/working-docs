# Front Line Poster Forge - Interaction Guide

How assistants and repo tooling should interact with Justin's ChatGPT custom GPT:

<https://chatgpt.com/g/g-698dcea6a11481919eddb4e04f68fbff-front-line-poster-forge>

This guide is about operational use from Working-Docs. The custom GPT's private builder
configuration is not exposed by the public link. Keep any exported builder instructions in
[`front-line-poster-forge-exported-instructions.md`](front-line-poster-forge-exported-instructions.md).

---

## Current Boundary

Do not treat the `chatgpt.com/g/...` URL as an API endpoint.

OpenAI's current product boundary is:

- Custom GPTs run inside ChatGPT. Users interact with them by opening the GPT, using a direct
  link, or mentioning the GPT with `@` inside ChatGPT.
- GPTs are not the supported path for embedding or automating an assistant in an external
  product. OpenAI's guidance is to use the API for product/tool integrations.
- GPT Actions go the other direction: the GPT can call external APIs that you define with an
  OpenAPI schema.

Official references:

- <https://help.openai.com/en/articles/8554407>
- <https://help.openai.com/en/articles/9442513-configuring-actions-in-gpts>

---

## Supported Interaction Modes

| Mode | Use When | How |
|---|---|---|
| ChatGPT UI | A human wants the exact custom GPT behavior | Open the GPT link and paste the Forge request packet below. |
| API-equivalent | Repo tooling or an LLM assistant needs repeatable local workflow | Use the exported instructions plus `scripts/openai/` helpers. This recreates the behavior; it does not call the hosted GPT. |
| GPT Actions | The custom GPT needs to reach external tooling | Add an Action in GPT Builder that calls a small HTTPS API you control. See `documentation/setup/front-line-poster-forge-actions.md`. |

If an assistant cannot see the exported instructions, it must say so and avoid claiming exact
Front Line Poster Forge parity.

---

## Forge Request Packet

Use this packet whenever a human or assistant asks Front Line Poster Forge to make or refine a
poster. Fill only what is known; leave unknown fields blank rather than inventing facts.

```markdown
# Front Line Poster Forge Request

## Work Item
- ID:
- Title:
- System / Product Area:
- Feature Type:

## Narrative
- Problem:
- Desired Outcome:
- Primary Tension:
- Stakeholders / Personas:

## Visual Direction
- Poster Format:
- Mood:
- Visual Motifs:
- Required Text:
- Text To Avoid:
- Color Notes:
- Style References:

## Repo Filing
- Target Folder:
- Desired Filename:
- Prompt Sidecar Required: yes

## Output Needed
- Prompt only:
- Image generation:
- Critique / refinement:
- Alternate concepts:
```

---

## API-Equivalent Workflow

Use this when tooling needs to drive poster work from the repo.

1. Load this file.
2. Load `documentation/skills/external-services/openai-scripts.md`.
3. Load `documentation/skills/external-services/front-line-poster-forge-exported-instructions.md`.
4. Build a Forge request packet from the user's work item.
5. If image generation is requested, use `scripts/openai/New-WarRoomPoster.ps1` or
   `scripts/openai/New-OpenAIImage.ps1` with `-WritePromptSidecar`.
6. Save generated artifacts under `AI-Content/` unless the user gives a more specific path.
7. Preserve the final prompt next to the image as a `.prompt.txt` sidecar.

Do not include API keys, cookies, ChatGPT session tokens, or browser credentials in any packet,
prompt, action schema, or committed file.

---

## Human-in-the-Loop ChatGPT Workflow

Use this when the user wants the exact custom GPT:

1. Open the Front Line Poster Forge link in ChatGPT.
2. Paste a completed Forge request packet.
3. Ask for one of these explicit outputs:
   - `Generate the final image prompt only.`
   - `Generate the poster image.`
   - `Critique this existing prompt and return a stronger version.`
   - `Create three distinct poster concepts before generating.`
4. Save any generated image under `AI-Content/`.
5. Save the exact final image prompt next to the image as `<filename>.prompt.txt`.

---

## GPT Actions Workflow

Use this when the custom GPT should call tooling.

Actions require:

- A reachable HTTPS API.
- Authentication, preferably API key or OAuth.
- An OpenAPI schema pasted into or imported by the GPT Builder.
- A privacy policy URL for public GPTs with Actions.

Do not expose unrestricted shell execution through an Action. The Action should accept structured
poster job data and perform only allowlisted operations such as creating a job record, returning
repo filing guidance, or queuing a known poster-generation workflow.

Setup details and a starter schema live in:

`documentation/setup/front-line-poster-forge-actions.md`


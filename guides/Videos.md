# Videos

- [Introduction](#introduction)
- [Create video](#create-video)

___

## Introduction

The wrapper provides full access to OpenAI’s new ***Sora video generation API***, a state-of-the-art model capable of creating dynamic, high-fidelity video clips with audio ***from natural language prompts or images***.
Sora leverages multimodal diffusion, advanced 3D spatial understanding, motion consistency, and scene continuity to deliver realistic text-to-video generation.

### Available Endpoints

- **Create video:** Launch a new render from a prompt, with optional image/video references or remix IDs.
- **Get status:** Track render progress and retrieve job details.
- **Download video:** Fetch the final MP4 file once the generation is complete.
- **List videos:** Browse previously generated videos with pagination support.
- **Delete video:** Remove a video from OpenAI’s storage.

### Supported Models

| Model | Purpose |
|:---:|:---:|
|**sora-2**| Fast and flexible for ideation, style exploration, rapid iteration, social content, and prototypes. |
|**sora-2-pro**| Higher fidelity for cinematic production, marketing assets, and scenarios requiring visual precision. |

Sora lets you generate, extend, or remix videos programmatically — from first draft concepts to production-ready footage.


## Create video


---
name: voice-input
description: Dictate a message using voice (speech-to-text only). Use when user wants to speak their request but receive a text response. Triggered by /voice or /dictate.
---

# Voice Input (Speech-to-Text Only)

Capture voice input from the user and transcribe it to text. Claude responds with text only - no speech output.

## Prerequisites

**OPENAI_API_KEY must be set.** Check first:

```bash
[[ -n "${OPENAI_API_KEY:-}" ]] && echo "API key set" || echo "Missing OPENAI_API_KEY"
```

If missing, tell the user:
> Voice input requires OPENAI_API_KEY. Add it to `~/.local_env.sh`:
> ```bash
> export OPENAI_API_KEY="sk-..."
> ```
> Then run `source ~/.zshrc` or `refresh`.

Do NOT proceed without the API key.

## Workflow

1. Verify OPENAI_API_KEY is set (stop if missing)
2. Listen for user's voice input via OpenAI whisper-1 API
3. Transcribe to text
4. Respond with text (no TTS)
5. Done - do not loop back to listen again

## Implementation

Use the VoiceMode MCP tool with `skip_tts=true`:

```python
voicemode:converse(message=".", skip_tts=true, wait_for_response=true)
```

The "." message is a minimal placeholder since we're only listening.

## Notes

- Uses OpenAI whisper-1 cloud API (no local services)
- Kokoro (TTS) is NOT needed for this skill
- If VoiceMode not installed: `/voicemode:install`

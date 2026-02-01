---
name: voice-input
description: Dictate a message using voice (speech-to-text only). Use when user wants to speak their request but receive a text response. Triggered by /voice or /dictate.
---

# Voice Input (Speech-to-Text Only)

Capture voice input from the user and transcribe it to text. Claude responds with text only - no speech output.

## Workflow

1. Listen for user's voice input via OpenAI whisper-1 API
2. Transcribe to text
3. Respond with text (no TTS)
4. Done - do not loop back to listen again

## Implementation

Use the VoiceMode MCP tool with `skip_tts=true`:

```python
voicemode:converse(message=".", skip_tts=true, wait_for_response=true, vad_aggressiveness=0)
```

The "." message is a minimal placeholder since we're only listening.

## Notes

- Uses OpenAI whisper-1 cloud API (requires OPENAI_API_KEY)
- Kokoro (TTS) is NOT needed for this skill
- If VoiceMode not installed: `/voicemode:install`

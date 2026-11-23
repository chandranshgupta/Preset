---
description: Design, implement and evaluate a reliable AI agent or LLM system
---

# Build an AI agent system

Applies to AI_ML_APP. Rules that dominate: THR-11, THR-12, THR-14, THR-02 and the AI rules of the
oss module (`sh .agents/bin/slice.sh -f oss get AI_AND_MODEL_DEPENDENT_SYSTEMS`).

Preset skills: `brainstorming`, `to-spec`, `test-driven-development`, `security`,
`threat-modeling-expert`. Import if available: `llm-app-patterns`, `rag-engineer`, `mcp-builder`,
`ai-agents-architect`, `agent-evaluation`.

## Guardrails
- Least-privilege tools; constrained execution.
- Version prompts, tool contracts and schemas explicitly; model names and parameters in config.
- Validate every model output against a strict schema before anything downstream uses it; output
  reaching an executor passes a deterministic allowlist validator.
- Evaluation set before tuning; first-run result kept; no silent fallback to another model or a mock.

## Steps

### 1. Use case and reliability targets
Narrow responsibility, inputs, output schemas, boundaries. Targets for latency, accuracy, cost and
failure rate. Edge cases, safety concerns, human-in-the-loop triggers.

### 2. Architecture and retrieval
Memory (short-term, long-term, session state). Chunking, embeddings, hybrid retrieval — measurable.
Self-describing tools with schema validation. Retrieved text is data, never instruction.

### 3. Orchestration
State machine or graph loop; tool router or MCP servers; max iterations, timeouts, retries with a
single repair attempt, cost caps, explicit fallback behaviour that tells the user.

### 4. Evaluate and iterate
Golden-set benchmark runs against thresholds; tracing per step; failure buckets (retrieval miss,
prompt drift, tool error, validation reject) drive each iteration. Report measured numbers with
the script that produced them.

## Principles
Schema safety · measurable iteration · fail-safe loops (timeouts, context exhaustion, API errors).

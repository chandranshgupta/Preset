# Glossary

> **Rules for `GLOSSARY.md`:**
> - Pure domain vocabulary only: concise, unambiguous definitions of this project's entities, states, and processes.
> - Do **NOT** include implementation details, SQL/TypeScript schemas, specs, or scratch notes.
> - Updated inline by `/grill-with-docs` the moment a term is agreed upon.

## Core Domain Terms
- **[Replace with your Project Name]**: [One-sentence description of what the system does and who it serves.]
- **[Core Entity 1]**: [Crisp definition in ubiquitous language.]
- **[Core Process / Lifecycle Event]**: [Crisp definition replacing verbose multi-sentence explanations.]

## Example Terms (From Matt Pocock's `course-video-manager`)
- **Course**: Top-level curriculum container composed of ordered sections.
- **Section**: Organizational grouping of lessons inside a course.
- **Course Version**: Tracked immutable snapshot/release of a course as it evolves over time.
- **Lesson**: Single learning unit within a section.
- **Draft Version**: Work-in-progress state indicating a lesson or course has unpublished changes.
- **Beat**: Discrete narrative and pacing unit within a lesson script.
- **Script**: Spoken teleprompter text and environment setup commands for recording a lesson.
- **Animatic**: Pre-recording visual/code dry-run simulation generated before filming.
- **Materialization Cascade**: The lifecycle process by which a logical lesson inside a course section is instantiated on the filesystem and linked to its assets.

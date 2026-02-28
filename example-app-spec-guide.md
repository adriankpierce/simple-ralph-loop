Guide to Writing an AI-Buildable App Spec
What This Is For
These specs are designed to be handed to an AI coding agent (like Claude with computer use) that will build the entire application autonomously. The spec replaces a human dev team's understanding — it needs to be comprehensive enough that the AI can make correct decisions without asking questions, but structured enough to not be ambiguous.
Core Sections

1. Project Name & Overview (2-3 sentences)
   A high-level description of what you're building. Name the closest real-world analog if one exists ("a clone of X", "similar to Y but for Z"). State the core value prop in one line.
2. Technology Stack
   Be explicit and opinionated. Don't say "a database" — say "SQLite with better-sqlite3." This section eliminates hundreds of decisions the AI would otherwise have to make.
   Specify:
   Frontend framework, styling approach, state management, routing
   Backend runtime, database, ORM/driver
   Communication patterns (REST, WebSocket, SSE)
   The port to run on
   Where API keys live (e.g., /tmp/api-key)
3. Prerequisites / Environment Setup
   Short bullet list of what's already in place vs. what needs to be installed. Mention package managers, pre-existing config files, directory structure expectations.
4. Core Features (the bulk of the spec)
   Organized into logical feature groups, each with a flat bullet list of capabilities. This is where you go wide — list everything the app should do, grouped by domain.
   Key characteristics:
   Flat bullet lists, not paragraphs. Each bullet is one discrete capability.
   Be specific about UI behaviors ("Enter to send, Shift+Enter for newline") not just abstract features ("keyboard shortcuts").
   Include mock/stub features where appropriate — mark them as such ("Share with team (mock feature)").
   Cover the full CRUD lifecycle for every entity (create, read, update, delete, plus extras like archive, pin, duplicate, export).
   Name the rendering libraries when relevant ("Mermaid diagram rendering", "LaTeX/math equation rendering").
   Typical feature groups: core interaction, content management, organization, settings, collaboration, search, usage tracking, onboarding, accessibility, responsive design.
5. Database Schema
   List every table with its columns and types. Include:
   Primary keys, foreign keys
   JSON columns for flexible data (preferences, settings, tags)
   Timestamps (created_at, updated_at)
   Soft-delete / archive flags
   Relationship columns (parent_id for trees, conversation_id for messages)
   Don't write SQL — just list the columns with brief type/purpose annotations using dashes.
6. API Endpoints
   Group by resource/domain. Use standard REST conventions. List every endpoint as METHOD /path. You don't need request/response schemas — the AI infers those from the database schema and feature descriptions.
   This section is essentially a routing table. It tells the AI the full surface area of the backend.
7. UI Layout
   Describe the spatial structure of the app:
   Main layout pattern (e.g., three-column: sidebar, main, panel)
   What goes in each region
   Responsive behavior at breakpoints
   List modals and overlays separately
   Use nested bullets to describe what's inside each region. Think of it as a wireframe in text form.
8. Design System
   Specify:
   Color palette with hex values and context ("Primary:
   #CC785C", "Background light:
   #F5F5F5")
   Typography (font stacks, sizes, weights)
   Component styles (buttons, inputs, cards, message bubbles) with Tailwind-level detail
   Animation timing and patterns
   This is surprisingly important — without it, the AI makes generic-looking UIs. Named references to real products help ("claude-style", "Monaco editor theme").
9. Key Interactions (Flows)
   Step-by-step numbered sequences for the 3-5 most important user workflows. These bridge the gap between static features and dynamic behavior. Example: message flow, artifact flow, conversation management flow.
10. Implementation Steps
    Ordered phases with grouped tasks. This gives the AI a build sequence — what to scaffold first, what depends on what. Usually 6-10 steps progressing from foundation → core features → advanced features → polish.
11. Success Criteria
    Grouped by dimension (functionality, UX, technical quality, design polish). These act as a checklist and also signal priorities — what matters most about this app.
    What Makes a Good Spec
    Be opinionated, not open-ended. "SQLite with better-sqlite3" not "a suitable database." Every ambiguity is a coin flip the AI makes without you.
    Go deep on UI details. The AI is weaker at design taste than logic. Specify hex colors, border radii, animation durations, hover states. Reference real products for visual direction.
    List behaviors, not just features. "Auto-generate title from first exchange" is better than "conversation titles." "Textarea auto-resize" is better than "input field."
    Include the boring stuff. Error states, loading states, empty states, confirmation dialogs, keyboard shortcuts — these make or break the feel of an app.
    Use consistent patterns. If every entity has CRUD + archive + pin + export, list all of them for each entity. Consistency helps the AI build uniform code.
    What the Spec Does NOT Include
    Actual code or pseudocode. It's declarative, not imperative.
    Implementation details like "use useReducer for state" or "create a custom hook for X." The AI decides how to implement.
    Request/response JSON schemas. Inferred from the database schema and feature list.
    File/folder structure. The AI determines project organization.
    Third-party service setup instructions (beyond noting what's used).
    Test specifications. Mentioned as a success criterion but not detailed.
    Deployment or CI/CD configuration.
    Detailed error handling rules — just "proper error handling throughout."
    User stories or personas. It's a technical spec, not a product brief.
    Wireframes or images. Pure text, using spatial descriptions instead.
    Rough Length Guide
    For a medium-complexity app (chat interface, CRUD, real-time features): ~300-500 lines of structured XML/markdown. The example spec is on the comprehensive end. A simpler app (todo app, dashboard, single-purpose tool) might be 100-200 lines.
    The format doesn't matter much (XML, markdown, YAML) — what matters is clear hierarchy and scannable structure. The example uses XML which gives nice nesting, but markdown with headers works equally well.

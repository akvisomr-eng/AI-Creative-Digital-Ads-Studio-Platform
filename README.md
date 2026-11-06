# AI Creative & Digital Ads Studio Platform

**Specification pack:** Draft v0.1  
**Baseline:** Master System Blueprint v1.0  
**Status:** For owner review; not approved for production implementation.

## Documents
- `docs/01-srs.md` — SRS and detailed features for 20 modules
- `docs/02-erd-data-dictionary.md` — logical/physical ERD and initial data dictionary
- `docs/03-rbac.md` — action-level authorization and data scopes
- `docs/04-ui-ux.md` — information architecture and UX specification for all portals/workspaces
- `docs/05-backlog.md` — phased backlog, dependencies, and acceptance gates

## Environment safety
- GitHub repository: `akvisomr-eng/AI-Creative-Digital-Ads-Studio-Platform`
- Neon project: `holy-credit-58409385`
- Production branch: `br-muddy-meadow-ao4bob10`
- Specification branch: `br-noisy-meadow-aotl7lts`
- Production database inspected read-only; no application tables were found.
- No production schema, migration, credentials, or application deployment has been changed.

## Architecture decisions
1. Modular monolith initially; domain boundaries and service interfaces remain explicit.
2. PostgreSQL 18; migration-as-code; development branch first, production last.
3. `tenant_id` on tenant-owned records; tenant isolation enforced server-side and with PostgreSQL RLS where appropriate.
4. RBAC combines role permissions with organization, branch, department, assignment, ownership, and tenant scopes.
5. Posted accounting records are immutable; corrections use reversal/adjustment documents.
6. AI usage is represented by an append-only credit ledger; subscription fee is recognized once as a period expense.
7. Provider API integrations remain `manual/unverified` until official API access and end-to-end tests exist.
8. File assets live in private object storage; signed URLs are short-lived and authorization checked.
9. No financial, payroll, legal, or high-impact action is fully autonomous without configured approval.
10. All documents are drafts until the product owner approves the decision log and acceptance criteria.

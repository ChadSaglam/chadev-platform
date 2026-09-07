# Contract: Auth (draft — Phase 1.2)

Status: **DRAFT**. Fill in during roadmap item 1.2. Current state of both apps is recorded here so the gap is visible.

## Today

| | billing | buchhaltung |
|---|---|---|
| Token | JWT HS256, access (30 min) + refresh (30 d, revocable `jti`) | JWT HS256, single token |
| Claims | `sub`, `tid`, `type`, `exp`, `jti` | see `backend/app/core/security.py` |
| Roles | `admin` · `editor` · `viewer` | `owner` |
| Password field | `users.hashed_password` | `users.password_hash` |

## Target (to agree in 1.2)

- Claims: `{ "sub": "<user_id>", "tid": <tenant_id>, "role": "<role>", "type": "access|refresh", "exp": <unix>, "jti": "<hex>" }`
- Roles: `owner > admin > editor > viewer`
- Issuer: decided in 1.5

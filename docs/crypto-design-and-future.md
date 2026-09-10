
# Veilmi Cryptographic Design and Future Direction

This document explains the reasoning behind Veilmi's main cryptographic
choices and the areas that may be considered for future improvement.

For an explanation of how Veilmi encryption and decryption work, see:

```text
docs/crypto-notes.md
````

---

## 1. Current Cryptographic Choices

Veilmi1 uses established cryptographic algorithms rather than designing its
own encryption system.

| Purpose                         | Current Choice     | Reference                          |
| ------------------------------- | ------------------ | ---------------------------------- |
| Passphrase-based key derivation | PBKDF2-HMAC-SHA256 | NIST SP 800-132, OWASP             |
| Message encryption              | AES-256-GCM        | NIST SP 800-38D                    |
| Stronger PBKDF2 profile         | 600,000 iterations | OWASP Password Storage Cheat Sheet |

### PBKDF2-HMAC-SHA256

NIST SP 800-132 specifies PBKDF2 for deriving cryptographic keys from passwords
or passphrases.

OWASP also provides current guidance for PBKDF2-HMAC-SHA256 and recommends a
600,000-iteration work factor when PBKDF2 is used.

Veilmi therefore uses 600,000 iterations for its Stronger profile.

The lower Compatibility and Balanced profiles are Veilmi usability choices for
devices where the stronger setting is too slow. They should not be interpreted
as equivalent security recommendations.

### AES-256-GCM

Veilmi uses AES-256-GCM for message encryption.

GCM is standardized by NIST in SP 800-38D and provides authenticated
encryption: it protects the confidentiality of the message while also allowing
modification to be detected.

---

## 2. Security and Usability

Password-based encryption always involves a trade-off.

Increasing the work required for key derivation makes repeated passphrase
guessing more expensive, but it also increases the work required on legitimate
devices.

Veilmi therefore allows different protection levels and includes a Device
Check.

The current five-second recommendation threshold used by Device Check is a
usability decision, not a cryptographic standard.

A strong KDF also cannot compensate for a weak or easily guessed passphrase.

---

## 3. Limits of the Current Design

Veilmi1 uses a shared-passphrase model.

This keeps the system simple, but it has limitations. For example, anyone who
knows the shared passphrase can create a valid message, and an attacker who
obtains an encrypted message can attempt passphrase guesses offline.

Veilmi also protects message content rather than the entire communication
environment. It cannot protect a message after an endpoint is compromised, and
it does not hide communication metadata.

These are known properties of the current design, not promises of future
features.

---

## 4. Possible Veilmi2 Direction

If Veilmi1 receives enough real-world use to justify developing a second
protocol generation, Argon2id is the intended direction for replacing PBKDF2.

Argon2id is designed to require memory as well as computation, making
large-scale password guessing more expensive on specialized hardware.

OWASP currently prefers Argon2id for new password-hardening designs, and
RFC 9106 provides an implementation-oriented specification and parameter
guidance for Argon2id.

Before adopting it, Veilmi2 would need to confirm that suitable Argon2id
parameters perform reliably across supported Android and iOS devices.

A future incompatible protocol could then use:

```text
VEILMI2:
```

Existing `VEILMI1` messages would keep their original meaning.

---

## 5. Other Areas for Future Research

If there is clear user demand, future research may also consider:

* stronger passphrase guidance;
* stronger sender authentication;
* improved authentication of protocol metadata;
* additional protection against resource-exhaustion attacks.

These are possible areas of improvement, not a committed feature roadmap.

---

## References

* NIST SP 800-132 — Recommendation for Password-Based Key Derivation
* NIST SP 800-38D — Recommendation for Galois/Counter Mode (GCM)
* OWASP Password Storage Cheat Sheet
* RFC 9106 — Argon2 Memory-Hard Function


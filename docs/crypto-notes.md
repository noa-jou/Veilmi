# Veilmi Cryptography Notes

This document explains how Veilmi currently encrypts and decrypts messages.

It is written as a beginner-friendly development reference.

---

## 1. The Big Picture

Veilmi starts with two things:

```text
message
+
shared passphrase
```

The passphrase is not used directly as an encryption key.

Instead:

```text
shared passphrase
       |
       v
  key derivation
       |
       v
 encryption key
       |
       v
 AES-256-GCM
       |
       v
encrypted message
```

The receiver performs the same process in reverse.

---

## 2. Message Envelope

A Veilmi encrypted message contains several pieces of information:

| Field | Meaning | Purpose |
|---|---|---|
| `v` | Version | Identifies the Veilmi message format |
| `k` | Key Derivation Function | Tells Veilmi how the key was created |
| `i` | Iterations | Controls how much work PBKDF2 performs |
| `s` | Salt | Used with the passphrase to derive the key |
| `n` | Nonce | Used by AES-GCM for this encryption |
| `c` | Ciphertext | The encrypted message |
| `m` | Authentication Tag | Detects modification or a wrong key |

Conceptually, the envelope looks like:

```json
{
  "v": 1,
  "k": "PBKDF2-SHA256",
  "i": 600000,
  "s": "...",
  "n": "...",
  "c": "...",
  "m": "..."
}
```

The JSON is encoded using Base64URL and prefixed with:

```text
VEILMI1:
```

A complete encrypted message therefore looks approximately like:

```text
VEILMI1:eyJ2IjoxLCJrIjoi...
```

The prefix is not secret.

It tells Veilmi which message format it is reading.

---

## 3. Passphrase and Key Derivation

Veilmi currently uses:

```text
PBKDF2-HMAC-SHA256
```

to turn the shared passphrase into a 256-bit encryption key.

Conceptually:

```text
shared passphrase
       +
  random salt (s)
       |
       v
PBKDF2-HMAC-SHA256
       |
       | repeated i times
       v
  256-bit key
```

### Salt (`s`)

The salt is a fresh random value used during key derivation.

For example:

```text
same passphrase + salt A
        |
        v
      key A


same passphrase + salt B
        |
        v
      key B
```

The salt does not need to be secret.

The receiver needs the same salt to derive the same key, so it is included in
the encrypted message.

---

## 4. Iterations (`i`)

A simple way to understand the iteration count is to imagine a locked door.

```text
message     = locked door
passphrase  = key
iterations  = how many turns the lock must perform
```

More turns mean more work.

```text
fewer turns
    |
    v
faster for the phone
but cheaper to guess repeatedly
```

```text
more turns
    |
    v
slower for the phone
but more expensive to guess repeatedly
```

Veilmi currently has three protection levels:

| Level | Iterations |
|---|---:|
| Compatibility | 50,000 |
| Balanced | 100,000 |
| Stronger | 600,000 |

The sender chooses the protection level.

The receiver does not need to choose the same setting manually because the
iteration count is stored inside the message envelope.

---

## 5. AES-GCM Encryption

After the key is derived, Veilmi uses:

```text
AES-256-GCM
```

to encrypt the plaintext.

Conceptually:

```text
256-bit key
     |
     |        nonce (n)
     |           |
     v           v
      AES-256-GCM
           ^
           |
       plaintext
           |
           v
   +----------------+
   | ciphertext (c) |
   | auth tag (m)   |
   +----------------+
```

AES-GCM does two important jobs:

```text
hide the message
+
detect modification
```

---

## 6. Nonce (`n`)

The nonce is used by AES-GCM during encryption.

It is not secret.

Veilmi generates a fresh nonce for each encryption.

The salt and nonce have different jobs:

```text
salt
 |
 v
PBKDF2
 |
 v
derive key
```

```text
nonce
 |
 v
AES-GCM
 |
 v
encrypt message
```

So:

```text
salt  -> key derivation
nonce -> message encryption
```

---

## 7. Ciphertext (`c`)

Ciphertext is the encrypted form of the original message.

For example:

```text
"Meet me at 8 PM."
        |
        v
    AES-256-GCM
        |
        v
 encrypted bytes
        |
        v
  ciphertext (c)
```

The ciphertext is what carries the hidden message.

It is not expected to be readable by a person.

---

## 8. Authentication Tag (`m`)

AES-GCM also creates an authentication tag.

The tag helps Veilmi detect whether the encrypted data can be trusted.

For example:

```text
ciphertext
   +
auth tag
   +
derived key
     |
     v
authentication check
     |
 +---+---+
 |       |
valid  invalid
 |       |
 v       v
decrypt REJECT
```

Authentication should fail when:

```text
the passphrase is wrong
or
the encrypted data was modified
```

Veilmi should reject the message instead of returning corrupted plaintext.

The authentication tag does not prove which person sent the message.

Anyone who knows the shared passphrase can create a valid Veilmi message.

---

## 9. Complete Encryption Flow

```text
User plaintext
      |
      |                     Shared passphrase
      |                            |
      |                      Random salt (s)
      |                            |
      |                            v
      |                 PBKDF2-HMAC-SHA256
      |                    i iterations
      |                            |
      |                            v
      |                       256-bit key
      |                            |
      v                            v
               AES-256-GCM
                    ^
                    |
             Random nonce (n)
                    |
                    v
        +-----------------------+
        | ciphertext (c)        |
        | authentication tag(m) |
        +-----------------------+
                    |
                    v
             MessageEnvelope
                    |
                    v
       JSON -> UTF-8 -> Base64URL
                    |
                    v
       VEILMI1:eyJ2IjoxLCJr...
```

The encrypted text can then be copied into another communication channel.

---

## 10. Complete Decryption Flow

The receiver performs the process in reverse:

```text
VEILMI1:eyJ2IjoxLCJr...
             |
             v
      Check VEILMI1 prefix
             |
             v
         Base64URL
             |
             v
           JSON
             |
             v
   Read envelope fields

 v / k / i / s / n / c / m

             |
             +-------------------+
             |                   |
             |             Shared passphrase
             |                   |
             |                 salt (s)
             |                   |
             |                   v
             |        PBKDF2-HMAC-SHA256
             |                   |
             |                   v
             |              256-bit key
             |                   |
             v                   v
               AES-256-GCM
                     |
             verify auth tag
                     |
              +------+------+
              |             |
            valid         invalid
              |             |
              v             v
           decrypt        REJECT
              |
              v
           plaintext
```

A wrong passphrase derives the wrong key.

That causes AES-GCM authentication to fail.

Modified encrypted data should also be rejected.

---

## 11. What Is Secret?

Most values inside a Veilmi message are not secrets.

An observer may know:

```text
VEILMI1 format
algorithm
KDF
iteration count
salt
nonce
ciphertext
authentication tag
source code
```

The important secret is:

```text
shared passphrase
```

and therefore the encryption key derived from it.

Veilmi should remain secure even when someone understands exactly how the
program works.

---

## 12. Same Message, Different Result

Encrypting the same plaintext twice with the same passphrase should normally
produce different encrypted messages.

For example:

```text
"I love you"
+
same passphrase
        |
        v
 encryption #1
        |
        v
VEILMI1:AAA...
```

and:

```text
"I love you"
+
same passphrase
        |
        v
 encryption #2
        |
        v
VEILMI1:XYZ...
```

This happens because Veilmi generates fresh random values such as:

```text
salt
nonce
```

for each encryption.

This is expected behavior.

---

## 13. Wrong Passphrase

If the receiver enters the wrong passphrase:

```text
wrong passphrase
       |
       v
different derived key
       |
       v
AES-GCM authentication
       |
       v
     FAIL
       |
       v
    REJECT
```

Veilmi does not return partially decrypted text.

---

## 14. Summary

The current Veilmi encryption process is:

```text
Passphrase
    +
Salt
    |
    v
PBKDF2
    |
    v
256-bit key

Plaintext
    +
Key
    +
Nonce
    |
    v
AES-256-GCM
    |
    v
Ciphertext + Authentication Tag

All required public values
    |
    v
Message Envelope
    |
    v
VEILMI1:...
```

The receiver uses the same passphrase and the values stored in the envelope to
reverse the process.
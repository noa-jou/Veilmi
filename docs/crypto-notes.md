# Veilmi Cryptography Notes

This document records the cryptographic concepts used in Veilmi and explains
how a message moves through the encryption and decryption process.

It is primarily a development and learning reference.

## 1. Message Envelope Fields

A Veilmi message contains several fields:

| Field | Meaning | Purpose |
|---|---|---|
| `v` | Version | Identifies the Veilmi message format version |
| `k` | Key Derivation Function | Identifies how the encryption key is derived from the passphrase |
| `i` | Iterations | Controls how many PBKDF2 iterations are performed |
| `s` | Salt | Used with the passphrase when deriving the encryption key |
| `n` | Nonce | A value used by AES-GCM for a particular encryption operation |
| `c` | Ciphertext | The encrypted form of the user's plaintext message |
| `m` | Authentication Tag | Allows AES-GCM to detect modification or corruption |

These values are encoded into the Veilmi message envelope.

Example structure:

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

The JSON data is encoded using Base64URL and prefixed with:
```
VEILMI1:
```
A final encrypted message therefore looks approximately like:
```
VEILMI1:eyJ2IjoxLCJrIjoi...
```
The prefix is not secret. It identifies the message as a Veilmi protocol
message and indicates its protocol version.

## 2. Passphrase and Key Derivation

Veilmi does not directly use the user's passphrase as an AES encryption key.

Instead, it uses PBKDF2-HMAC-SHA256 to derive a 256-bit key.

Conceptually:

```
passphrase
    +
random salt (s)
    |
    v
PBKDF2-HMAC-SHA256
    |
    | repeated i times
    v
256-bit encryption key
```

### Salt (s)

The salt is a random value used during key derivation.

Even when the same passphrase is reused, different salts cause PBKDF2 to
derive different keys.

```
same passphrase + salt A -> key A
same passphrase + salt B -> key B
```
The salt does not need to be secret. It is stored in the message envelope so
the receiver can derive the same key.

### Iterations (i)

The iteration count determines how much computational work PBKDF2 performs
when deriving a key.

Veilmi currently uses a development value of:

```
600000 iterations
```
A higher iteration count makes each passphrase guess more computationally
expensive.

This is useful because an attacker who obtains an encrypted message can try
to guess the passphrase offline.

For every guess, the attacker must perform the PBKDF2 computation before
testing whether the resulting key is correct.

However, a very large iteration count also increases the workload for
legitimate users.

For this reason, Veilmi must not blindly trust an iteration count supplied by
an incoming message.

The current implementation only accepts the iteration count configured by
Veilmi.

The final iteration count should be benchmarked on target mobile devices
before the VEILMI1 protocol is considered stable.

## 3. AES-GCM Encryption

After PBKDF2 derives the 256-bit key, Veilmi uses AES-256-GCM to encrypt the
plaintext.

Conceptually:

```
256-bit key
     |
     |       nonce (n)
     |          |
     v          v
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

### Nonce (n)

The nonce is used by AES-GCM during encryption.

It does not need to be secret, but a nonce must not be reused with the same
AES-GCM key.

Veilmi stores the nonce in the message envelope because the receiver needs it
to decrypt the ciphertext.

The nonce and salt have different purposes:

```
salt  -> used by PBKDF2 to derive a key
nonce -> used by AES-GCM to encrypt/decrypt a message
```

### Ciphertext (c)

Ciphertext is the encrypted form of the user's plaintext.

For example:

```
plaintext
"Meet me at 8 PM."
        |
        v
     AES-GCM
        |
        v
ciphertext
```
Without the ciphertext, the receiver has no encrypted message to decrypt.

### Authentication Tag (m)

AES-GCM also produces an authentication tag.

The receiver verifies this tag before accepting the decrypted message.

If an attacker modifies the ciphertext, nonce, or authentication tag, the
authentication check should fail and Veilmi must reject the message rather
than return potentially modified plaintext.

The authentication tag does not identify a specific sender in Veilmi's
shared-passphrase model.

Anyone who possesses the shared secret can derive the encryption key and
create a valid authenticated message.

## 4. Complete Encryption Flow

The complete encryption process is:

```
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
The encrypted text can then be copied into an existing communication channel.

## 5. Complete Decryption Flow

The receiver performs the process in reverse:
```
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
A wrong passphrase derives the wrong key, causing AES-GCM authentication to
fail.

Modified authenticated encryption data should likewise be rejected.

## 6. What Is Secret?

Most values in a Veilmi message are not secrets.

An observer may know:
```
VEILMI1 protocol format
algorithm
KDF
iteration count
salt
nonce
ciphertext
authentication tag
source code
```
Veilmi does not depend on hiding these values.

The important secret is the shared passphrase and, consequently, the key
derived from it.

This follows an important cryptographic design principle: the security of a
system should not depend on keeping its algorithm or implementation secret.

## 7. Important Limitation: Passphrase Guessing

Possession of the encrypted message allows an attacker to attempt offline
passphrase guesses.

For example:
```
guess passphrase
      |
      v
PBKDF2(passphrase, salt)
      |
      v
candidate key
      |
      v
attempt AES-GCM authentication
      |
   +--+--+
   |     |
 fail  success
         |
         v
likely correct passphrase
```
PBKDF2 increases the cost of each guess, but it cannot make a weak passphrase
strong.

Therefore, Veilmi should encourage users to choose strong shared
passphrases.

## 8. PBKDF2 Benchmark

Before finalizing the PBKDF2 iteration count for VEILMI1, the key
derivation performance should be measured on target devices.

An initial benchmark was performed in the Chromebook Debian development
environment using Dart.

Each configuration was measured three times.

| Iterations | Run 1 | Run 2 | Run 3 | Average |
|---:|---:|---:|---:|---:|
| 100,000 | 496 ms | 431 ms | 430 ms | 452.3 ms |
| 300,000 | 1288 ms | 1293 ms | 1278 ms | 1286.3 ms |
| 600,000 | 2579 ms | 2550 ms | 2571 ms | 2566.7 ms |

These results are preliminary.

They measure PBKDF2 performance in the development environment and should
not be treated as representative of Android or iOS performance.

The final VEILMI1 iteration count should not be selected until benchmarks
have been performed on actual target mobile devices.



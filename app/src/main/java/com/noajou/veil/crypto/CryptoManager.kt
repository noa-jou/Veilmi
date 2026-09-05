package com.noajou.veil.crypto

import java.security.SecureRandom

object CryptoManager {

    private val secureRandom = SecureRandom()

    fun generateRandomBytes(length: Int): ByteArray {
        val bytes = ByteArray(length)
        secureRandom.nextBytes(bytes)
        return bytes
    }
}
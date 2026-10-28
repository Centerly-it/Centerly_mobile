package com.example.centrally

import java.io.File
import java.security.MessageDigest

object UpdateDigests {
    private fun hex(bytes: ByteArray) = bytes.joinToString("") { "%02x".format(it) }
    fun bytes(bytes: ByteArray): String = hex(MessageDigest.getInstance("SHA-256").digest(bytes))
    fun file(file: File): String {
        val sha = MessageDigest.getInstance("SHA-256")
        file.inputStream().use { input ->
            val buffer = ByteArray(65536)
            while (true) { val n = input.read(buffer); if (n < 0) break; sha.update(buffer, 0, n) }
        }
        return hex(sha.digest())
    }
}

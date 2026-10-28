package com.example.centrally

import org.junit.Test
import org.junit.Assert.assertThrows
import org.junit.Assert.assertEquals

class UpdatePolicyTest {
    @Test fun checksSha256ForBytesAndFiles() {
        val expected = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        assertEquals(expected, UpdateDigests.bytes("hello".toByteArray()))
        val file = java.io.File.createTempFile("centerly-update-test-", ".tmp")
        try { file.writeText("hello"); assertEquals(expected, UpdateDigests.file(file)) }
        finally { file.delete() }
    }
    private fun verify(pkg: String = "com.centerly.teacher", archive: Long = 2,
                       expected: Long = 2, signers: Set<String> = setOf("trusted"), sdk: Int = 31) =
        UpdatePolicy.validate("com.centerly.teacher", 1, expected, pkg, archive,
            setOf("trusted"), signers, 24, sdk)
    @Test fun acceptsSamePackageKeyAndHigherVersion() { verify() }
    @Test fun rejectsDifferentPackage() {
        assertThrows(IllegalArgumentException::class.java) { verify(pkg = "other.app") }
    }
    @Test fun rejectsWrongSigningKey() {
        assertThrows(IllegalArgumentException::class.java) { verify(signers = setOf("attacker")) }
    }
    @Test fun rejectsUnsignedArchive() {
        assertThrows(IllegalArgumentException::class.java) { verify(signers = emptySet()) }
    }
    @Test fun rejectsDowngradeOrSameBuild() {
        assertThrows(IllegalArgumentException::class.java) { verify(archive = 1, expected = 1) }
        assertThrows(IllegalArgumentException::class.java) { verify(archive = 0, expected = 0) }
    }
    @Test fun rejectsUnexpectedVersion() {
        assertThrows(IllegalArgumentException::class.java) { verify(archive = 3, expected = 2) }
    }
    @Test fun rejectsUnsupportedAndroid() {
        assertThrows(IllegalArgumentException::class.java) { verify(sdk = 23) }
    }
}

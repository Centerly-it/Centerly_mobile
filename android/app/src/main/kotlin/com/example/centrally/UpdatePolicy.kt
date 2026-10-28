package com.example.centrally

/** Pure policy shared by the native archive verifier and JVM regression tests. */
object UpdatePolicy {
    fun validate(currentPackage: String, installed: Long, expected: Long,
                 archivePackage: String, archiveBuild: Long,
                 currentSigners: Set<String>, archiveSigners: Set<String>,
                 minSdk: Int, deviceSdk: Int) {
        require(archivePackage == currentPackage && archiveBuild == expected && archiveBuild > installed) {
            "UPDATE_INVALID"
        }
        require(currentSigners.isNotEmpty() && archiveSigners == currentSigners) { "UPDATE_SIGNATURE" }
        require(minSdk <= deviceSdk) { "UPDATE_INCOMPATIBLE" }
    }
}

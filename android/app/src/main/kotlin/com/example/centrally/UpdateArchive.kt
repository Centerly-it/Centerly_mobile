package com.example.centrally

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import java.io.File

@Suppress("DEPRECATION")
object UpdateArchive {
    fun build(info: PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()

    private val flags: Int get() = if (Build.VERSION.SDK_INT >= 28)
        PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES

    fun installed(context: Context): PackageInfo =
        context.packageManager.getPackageInfo(context.packageName, flags)

    private fun signers(info: PackageInfo): Set<String> {
        val signatures = if (Build.VERSION.SDK_INT >= 28)
            info.signingInfo?.apkContentsSigners else info.signatures
        return signatures?.map { UpdateDigests.bytes(it.toByteArray()) }?.toSet() ?: emptySet()
    }

    fun verify(context: Context, path: String, expectedBuild: Long, size: Long, hash: String): File {
        val folder = File(context.cacheDir, "centerly_updates").canonicalFile
        val file = File(path).canonicalFile
        require(file.parentFile == folder && file.isFile && file.name.matches(
            Regex("update-[0-9]+-[a-f0-9]{64}\\.apk"))) { "UPDATE_INVALID" }
        require(hash.matches(Regex("[a-f0-9]{64}")) && file.length() == size) { "UPDATE_CHECKSUM" }
        require(UpdateDigests.file(file) == hash) { "UPDATE_CHECKSUM" }
        val current = installed(context)
        val archive = context.packageManager.getPackageArchiveInfo(file.path, flags)
            ?: error("UPDATE_INVALID")
        UpdatePolicy.validate(context.packageName, build(current), expectedBuild,
            archive.packageName, build(archive), signers(current), signers(archive),
            archive.applicationInfo?.minSdkVersion ?: Int.MAX_VALUE, Build.VERSION.SDK_INT)
        return file
    }
}

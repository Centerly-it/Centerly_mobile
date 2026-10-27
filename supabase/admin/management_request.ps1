param([Parameter(Mandatory=$true)][string]$ApiPath,[ValidateSet('GET','POST','PATCH')][string]$Method='GET',[string]$BodyFile='')
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=New-Object System.Text.UTF8Encoding($false)
$OutputEncoding=[Console]::OutputEncoding
if ($ApiPath -notmatch '^/v1/(organizations|projects)(/|$)') {throw 'Unsupported Management API path'}
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class CenterlyCredential {
 [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)] public struct Entry {
  public uint Flags; public uint Type; public string TargetName; public string Comment;
  public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
  public uint CredentialBlobSize; public IntPtr CredentialBlob; public uint Persist;
  public uint AttributeCount; public IntPtr Attributes; public string TargetAlias; public string UserName;
 }
 [DllImport("advapi32.dll",EntryPoint="CredReadW",CharSet=CharSet.Unicode,SetLastError=true)]
 public static extern bool Read(string target,uint type,uint flags,out IntPtr result);
 [DllImport("advapi32.dll")] public static extern void CredFree(IntPtr result);
 public static string Load() {
  IntPtr ptr;
  if(!Read("Supabase CLI:supabase",1,0,out ptr)) throw new Exception("Supabase CLI login unavailable");
  try {var row=Marshal.PtrToStructure<Entry>(ptr);var bytes=new byte[row.CredentialBlobSize];Marshal.Copy(row.CredentialBlob,bytes,0,bytes.Length);return System.Text.Encoding.UTF8.GetString(bytes);}
  finally {CredFree(ptr);}
 }
}
'@
try {
 $credential=[CenterlyCredential]::Load()
 if($credential.StartsWith('go-keyring-base64:')) {$credential=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($credential.Substring('go-keyring-base64:'.Length)))}
 $credential=$credential.Replace([string][char]0,'')
 if($credential -notmatch '^sbp_(oauth_|v0_)?[a-f0-9]{40}$') {throw 'Invalid stored CLI credential format'}
 $params=@{Uri=('https://api.supabase.com'+$ApiPath);Method=$Method;Headers=@{Authorization=('Bearer '+$credential)};TimeoutSec=60}
 if($BodyFile) {$params.ContentType='application/json';$params.Body=[IO.File]::ReadAllText($BodyFile)}
 $response=Invoke-WebRequest @params -UseBasicParsing
 $reader=New-Object IO.StreamReader($response.RawContentStream,[Text.Encoding]::UTF8)
 try {$json=$reader.ReadToEnd()} finally {$reader.Dispose()}
 [Console]::Write($json)
} catch { [Console]::Error.WriteLine('Supabase Management API request failed; no credentials logged. '+$_.Exception.GetType().Name);exit 1 }

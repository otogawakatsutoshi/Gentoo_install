
$cache = ".cache/"

if(!(Test-Path $cache)) {
  New-Item -ItemType Directory $cache
}

# 16文字
# 20220227T170528Z
$url = "https://www.gentoo.org/downloads/"
$links = Invoke-WebRequest $url |
  Select-Object -ExpandProperty Links

$minimal_iso = $links |
  Where-Object {$_.href -match "install-amd64-minimal-.*.iso"} |
  Select-Object -ExpandProperty href |
  Sort-Object -Unique

$stage3_systemd = $links |
  Where-Object {$_.href -match "stage3-amd64-systemd-.*.tar.xz"} |
  Select-Object -ExpandProperty href |
  Sort-Object -Unique

$stage3_systemd_desktop = $links |
  Where-Object {$_.href -match "stage3-amd64-desktop-systemd-.*.tar.xz"} |
  Select-Object -ExpandProperty href |
  Sort-Object -Unique

# 
($minimal_iso, $stage3_systemd, $stage3_systemd_desktop) |
  ForEach-Object {
    Invoke-WebRequest -Uri $_ -OutFile (Join-Path $cache (Split-Path -Leaf $_ ))
  }

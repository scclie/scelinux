# SCELNX - AMISCE for Linux

a collection of scripts for working with **hidden BIOS settings** (UEFI NVRAM) on AMI Aptio V motherboards (MSI, ASUS, ASRock, Gigabyte, AMD/Intel), from Linux, without Windows.

it wraps AMI's native Linux binary **AMISCE** (`SCELNX_64`) - the Linux equivalent of `SCEWIN_64.exe`.

> *warning**: modifying BIOS settings carries risks (instability, failure to boot, "brick"). Proceed at your own risk. ALWAYS make a backup and know how to reset CMOS (remove battery / CLRTC jumper).

## guide

recommended reference on hidden AMD settings:

- **[AMD Hidden BIOS Setting Guide (Scewin)](https://docs.google.com/document/d/1luRuq9GH0ipel8GsMmv7bs6lsLxTJeZ3LkfPQMehAMI)** - by *ancel_*

> the guide explicitly warns: **Do NOT mass-apply all settings at once!** apply in groups. some settings can prevent your system from booting. Setting names and available options differ between boards/BIOS versions.

## requirements

- linux x86_64, booted in **UEFI** mode (not legacy BIOS). Check: `[ -d /sys/firmware/efi ] && echo UEFI`
- **AMI Aptio V** BIOS. Check: `sudo dmidecode -s bios-vendor` (or `cat /sys/class/dmi/id/bios_vendor`) → should be `American Megatrends Inc.` / `AMI`
- root privileges (`sudo`)

## install

clone and make the scripts executable:

```bash
# Clone from github/codeberg/git.sccl.cc
git clone https://git.sccl.cc/scclie/scelinux
chmod +x *.sh
cd scelinux
```

the `sceelnx64` binary is bundled. (If missing - see "Where to get the binary".)

## usage

```bash
# 1. backup current state (mandatory!)
sudo ./backup.sh before

# 2. export all settings to nvram.txt
sudo ./export.sh

# 3. find / inspect the setting you want
./search.sh "Global C-state Control"     # show one block
./search.sh -list                        # list all setting names

# 4. edit nvram.txt: move '*' to the desired value
#    (ull find lines like:  *[XX]Disabled)
$EDITOR nvram.txt

# 5. apply the changes
sudo ./import.sh

# 6. fully power-cycle the machine (shutdown, not reboot) - some controls
#    only take effect after a full power-off.
```

## nvram.txt format

each block describes one setting:

```
Setup Question	= Global C-state Control
Help String	= ...
Token	=12	// Do NOT change this line
Offset	=24
Width	=01
Options	=[00]Disabled	// Move "*" to the desired Option
         [01]Enabled
         *[03]Auto
```

the active value is marked with `*`. To change it, move `*` to the desired line (keep exactly one `*` per block).

**do not change** `Token`, `Offset`, `Width` or `Help String` - only move `*` (or edit values for string/numeric fields).

## scripts

| Script | Purpose |
|--------|---------|
| `export.sh` | Export current settings to a text file |
| `import.sh` | Apply an edited file to NVRAM |
| `backup.sh` | Backup to `./backups/` with a timestamp |
| `restore.sh` | Restore from a saved backup |
| `search.sh` | Find / view a setting by name |

all scripts require `sudo`, except `search.sh`.

## possible issues

### "AMISCE requires root privileges"
run with `sudo`.

### "This tool is not supported on this system" / error 49
most often caused by an **OEM/locked build** of the binary (e.g. SECO-branded "For Seco S.p.a."). Such builds refuse to work on other boards. You need a **vanilla AMI binary** (`AMISCE Utility. Ver ...`, without a vendor banner). See "Where to get the binary".

### "WARNING: HII data does not have setup questions information"
on ASUS (Z590+, B560+, H510+, X670+, B650+, A620+): go to `Setup > Tool` and enable **Publish HII Resources**. On some platforms (Z790+/B760+/H770+/X670+/B650+/A620+ and ASRock) additionally disable **Password protection of Runtime Variables** in `Setup > Advanced > UEFI Variables Protection`.

### "Retrieving HII Database" / "BIOS not compatible"
the BIOS is not AMI. Check: `cat /sys/class/dmi/id/bios_vendor`. If it's not `American Megatrends Inc.`/`AMI`, the tool won't work.

### "Platform identification failed"
the tool didn't recognize the platform (outdated Aptio core). The `/d` flag (already used by the scripts) skips this check.

### "Warning: Error in writing variable <X> to NVRAM"
the variable is write-protected. Enable PCI devices / disable variable protection (see above). Some variables are hardware-protected and cannot be changed.

### "Missing Current Setting '*'"
a block has no active `*` (or it's not unique / on the wrong value). Restore a single `*` in the block.

### "WARNING: Length of string ... doesn't reach the minimum range"
leave it as-is; the warning is harmless.

### "WARNING: Duplicate questions found"
many boards contain duplicate questions - normal; the tool takes the first one.

### Changes don't take effect after reboot
a **power cycle** is required - fully power off and on (or unplug for ~10s / switch off the PSU), not just `reboot`.

### System won't boot / "brick" after changes
1. reset the BIOS: remove the CMOS battery for 10+ seconds or short the `CLRTC`/`CLR_CMOS` jumper (see your board manual).
2. or restore a backup: `sudo ./restore.sh backups/nvram-<...>.txt` (if the system boots at all).
3. as a last resort, use an SPI programmer (e.g. CH341A) to flash the BIOS chip.

## where to get the binary

`sceelnx64` is AMI `SCELNX_64`. Sources:

- from **MSI Center** (extraction is inconvenient).
- from OEM archives based on AMI AMISCE (usually vanilla, not locked):
  - Intel (AMISCE Utility for M10JNP2SB) - requires accepting a license at download.
  - HPE Cloudline, SECO - but the SECO build is locked to SECO platforms.
- from forum/telegram collections (e.g. `t.me/filebox_x99`, oldrigrevive.com). Look for a **vanilla** `SCELNX_64`, without a vendor banner.
- extract via MSI Center utilities on a Windows machine.

## disclaimer

this project is NOT owned, supported or endorsed by American Megatrends (AMI). improper use could cause system instability. Use at your own risk.

## license
MIT

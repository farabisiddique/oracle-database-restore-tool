# Oracle Database Restore Tool

A small Windows desktop app that automates an Oracle schema restore: it drops &
recreates the target user, imports a Data Pump dump (`impdp`), and runs the
post-import setup — with a progress bar, percentage, and a per-step log.

*Developed by Earshadul Bari Siddique (Farabi).*

## Requirements

Two things must already be installed on the PC (both on the system `PATH`):

| Requirement | Check |
|-------------|-------|
| **Java 17 or newer** (JRE or JDK) | `java -version` |
| **Oracle client** with `sqlplus` **and** `impdp` | `where sqlplus` and `where impdp` |

## Install

1. Download **`DbRestoreTool.jar`**, **`install.bat`** and **`uninstall.bat`**
   from this repository into one folder.
2. Double-click **`install.bat`** (no administrator rights needed).

It installs to `%LOCALAPPDATA%\DatabaseRestoreTool`, and creates **Desktop** and
**Start Menu** shortcuts plus an entry in Windows **Apps & features**.

## Run

Launch from the **Desktop** or **Start Menu** shortcut. After a brief welcome
screen, fill in the three fields — dump file, source schema, target schema — and
click **Start Restore** (tick **Dry run** first to only generate the scripts).

## Updates

On launch the app checks this repository for a newer version. When one is
available it shows a dialog with the changes and an **Install now** button that
downloads and applies the update for you.

## Uninstall

Use **Settings → Apps → Database Restore Tool → Uninstall**, or run
**`uninstall.bat`**.

## Logs

Each run writes a log you can open in any text editor: 

```
%LOCALAPPDATA%\DatabaseRestoreTool\logs\restore_YYYYMMDD_HHMMSS.log
```

# Minecraft Bedrock Server Configuration Menu

A lightweight Windows batch-based management menu for running and managing a **Minecraft Bedrock Dedicated Server (BDS)** with **playit.gg** as the network tunnel.

This project was created to simplify the process of starting, monitoring, and shutting down a personal Minecraft Bedrock server without having to manually launch and manage each component separately.

> **Made by Aburiru**

---

## Features

* **Interactive server selection**

  * Automatically detects valid Bedrock server folders.
  * Supports multiple BDS installations under a single base directory.
  * Select which server instance to launch from the menu.

* **Automatic playit.gg management**

  * Checks whether `playit.exe` is installed.
  * Starts playit.gg automatically if it isn't already running.
  * Opens the playit.gg dashboard when necessary.
  * Waits until the tunnel process is running before starting the server.

* **Minecraft Bedrock Dedicated Server management**

  * Launches BDS in a separate window.
  * Automatically uses the selected server directory as the working directory.
  * Captures server output into a temporary log file.

* **Server status menu**

  * Displays tunnel and server status.
  * Attempts to track the current number of connected players.
  * Provides an interactive management interface while the server is running.

* **Automatic idle shutdown**

  * Detects when no players are online.
  * Starts an idle timer when the server becomes empty.
  * Automatically shuts down the server after the configured grace period.
  * Can be enabled or disabled at runtime.

* **Optional PC shutdown**

  * Can automatically shut down the entire PC after the server has been idle.
  * Useful when hosting a server temporarily on a personal computer.

* **Minecraft launcher**

  * Launch Minecraft Bedrock directly from the management menu.

* **Restart / cleanup**

  * Terminates the BDS and playit.gg processes.
  * Allows the entire activation process to be restarted from the menu.

---

## How It Works

The project acts as a simple orchestration layer between the Minecraft Bedrock Dedicated Server and playit.gg.

```text
                    ┌──────────────────────────┐
                    │  Server Configuration    │
                    │         Menu             │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
          ┌─────────────────┐       ┌─────────────────┐
          │ Minecraft BDS   │       │    playit.gg    │
          │                 │       │     Tunnel      │
          └────────┬────────┘       └────────┬────────┘
                   │                         │
                   └────────────┬────────────┘
                                │
                                ▼
                         Minecraft Players
```

The batch script handles the startup sequence:

1. Check for administrator privileges.
2. Locate available BDS server installations.
3. Ask the user to select a server.
4. Start the playit.gg client.
5. Wait until the tunnel process is available.
6. Start the selected Bedrock Dedicated Server.
7. Monitor the server state.
8. Provide management options through the status menu.
9. Shut down the server automatically when idle, if enabled.

---

## Requirements

This project currently targets **Windows**.

You will need:

* Windows 10 / 11
* Minecraft Bedrock Dedicated Server
* playit.gg Windows client
* A configured playit.gg tunnel
* Administrator privileges

The Minecraft Bedrock Dedicated Server itself is **not included in this repository**.

You can obtain the official Bedrock Dedicated Server from Mojang/Minecraft's official distribution channels.

playit.gg is used as the network tunnel so that players can connect to the server without requiring traditional port forwarding.

---

## Installation

### 1. Download the project

Clone the repository:

```bash
git clone https://github.com/your-username/your-repository.git
```

Or download the repository as a ZIP file.

### 2. Install Minecraft Bedrock Dedicated Server

Download and extract the official Bedrock Dedicated Server.

The default configuration expects servers to be stored under:

```text
C:\Users\abril\Documents\MinecraftServers
```

The directory can contain multiple server folders:

```text
MinecraftServers/
├── Survival/
│   └── bedrock_server.exe
│
├── Creative/
│   └── bedrock_server.exe
│
└── Testing/
    └── bedrock_server.exe
```

The script automatically detects folders containing:

```text
bedrock_server.exe
```

### 3. Install playit.gg

Install the Windows playit.gg client.

The current configuration expects:

```text
C:\Program Files\playit_gg\bin\playit.exe
```

If your installation uses a different location, change the following configuration value in the script:

```bat
set "PLAYIT_EXE=C:\Program Files\playit_gg\bin\playit.exe"
```

### 4. Configure your tunnel

Create and configure your Minecraft tunnel through your playit.gg account.

The script will automatically start the playit.gg client when the server is launched.

---

## Configuration

Most configuration values are located at the beginning of the batch file:

```bat
set "TITLE=Minecraft Bedrock Dedicated Server - Menu"
set "PLAYIT_EXE=[Your playit.exe path]"
set "PLAYIT_PROCESS=playit.exe"
set "PLAYIT_URL=https://playit.gg/account/tunnels"

set "SERVER_BASE_DIR=[Your server base folder path]"
set "SERVER_EXE=bedrock_server.exe"

set "AUTO_SHUTDOWN_ENABLED=1"
set "PC_SHUTDOWN_ENABLED=0"
set "SHUTDOWN_GRACE_PERIOD=300"
```

### Important settings

| Setting                 | Description                                      |
| ----------------------- | ------------------------------------------------ |
| `PLAYIT_EXE`            | Location of the playit.gg executable             |
| `PLAYIT_PROCESS`        | Process name used to detect playit.gg            |
| `SERVER_BASE_DIR`       | Root directory containing your BDS installations |
| `SERVER_EXE`            | BDS executable name                              |
| `AUTO_SHUTDOWN_ENABLED` | Enables idle server shutdown                     |
| `PC_SHUTDOWN_ENABLED`   | Enables PC shutdown after idle timeout           |
| `SHUTDOWN_GRACE_PERIOD` | Idle time before shutdown, in seconds            |

For example:

```bat
set "SHUTDOWN_GRACE_PERIOD=300"
```

means the server will shut down after approximately **5 minutes without detected players**.

---

## Server Management Menu

Once the server is running, the status menu provides several options:

```text
------------------------------------------
Options:
[R] Refresh player count
[P] Launch Minecraft Bedrock
[A] Toggle auto-shutdown
[S] Toggle PC shutdown on idle
[X] Terminate all and close
[T] Restart the activation process
```

### `R` — Refresh

Refreshes the displayed player count and server status.

### `P` — Launch Minecraft

Launches Minecraft Bedrock using the Windows `minecraft:` protocol.

### `A` — Auto-Shutdown

Toggles automatic shutdown when no players are detected.

### `S` — PC Shutdown

Toggles whether Windows should shut down after the server becomes idle.

### `X` — Exit

Terminates the BDS and playit.gg processes and closes the management script.

### `T` — Restart

Stops the current server/tunnel processes and restarts the activation process.

---

## Automatic Shutdown

The server includes an optional idle shutdown mechanism.

When enabled:

```text
Players: 0
Auto-shutdown in: 299 seconds
```

The timer continues while no players are detected.

If a player joins:

```text
Players: 1
Auto-shutdown: PAUSED (players online)
```

The timer is reset.

The default grace period is:

```text
300 seconds
```

or approximately five minutes.

This feature is particularly useful when running a server on a personal PC because the server does not need to remain active indefinitely when nobody is using it.

---

## Logging

The launcher creates a temporary log file:

```text
%TEMP%\bds-live.log
```

The BDS output is redirected into this file while the server is running.

The log is used by the script to perform basic player-count detection.

---

## Project Structure

A typical setup looks like this:

```text
MinecraftServers/
│
├── Survival/
│   ├── bedrock_server.exe
│   ├── server.properties
│   ├── permissions.json
│   ├── allowlist.json
│   └── worlds/
│
├── Creative/
│   ├── bedrock_server.exe
│   └── ...
│
└── Testing/
    ├── bedrock_server.exe
    └── ...
```

The repository itself only contains the management script and project documentation.

Minecraft server files should be installed separately.

---

## Security & Privacy

This project does not contain the Minecraft Bedrock Dedicated Server itself.

Do not commit sensitive configuration files, authentication credentials, private tunnel information, or other secrets to the repository.

If you modify the script to include credentials or API keys in the future, use environment variables or another secure configuration mechanism instead of hardcoding them.

---

## Limitations

This project is currently designed specifically for **Windows** and relies on Windows batch scripting.

The player-count system also relies on parsing server log messages, so changes to the Bedrock Dedicated Server's log format may affect player detection.

The script should therefore be considered a lightweight personal server-management utility rather than a complete server administration framework.

---

## Roadmap

Possible future improvements:

* [ ] More reliable player-count tracking
* [ ] Configurable server properties from the menu
* [ ] Server start/stop controls without terminating the entire process tree
* [ ] Better error handling
* [ ] Server health monitoring
* [ ] Automatic BDS update detection
* [ ] Automatic backup system
* [ ] Server performance monitoring
* [ ] Multiple tunnel configurations
* [ ] Persistent configuration file
* [ ] Migration from `.bat` to PowerShell or another scripting language
* [ ] Graphical interface

---

## Disclaimer

This project is an independent utility and is not affiliated with, endorsed by, or officially supported by Mojang Studios, Microsoft, or playit.gg.

Minecraft and related trademarks belong to their respective owners.

---

## License

This project is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for the full license text.

---

## Author

**Aburiru**

Built as a personal project for experimenting with Windows automation, Minecraft server administration, networking, and scripting.

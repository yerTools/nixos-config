# Felix NixOS Config

Meine modulare Flake-basierte NixOS- und Home-Manager-Konfiguration.

## Struktur
- **`common-*.nix`**: Globale Settings und Tools für **alle** Systeme (Terminal-Basics, Aliase, Netzwerkeinstellungen).
- **`modules/hosts/<hostname>/`**: Lokale Konfigurationen (Hardware, Desktop-Environment, `stateVersion`).
- **`modules/hosts/default.nix`**: Zentrale Host-Metadaten und Exporte für `nixosConfigurations` und `homeConfigurations`.

## Import-Strategie (Hybrid)
- **`import-tree`** wird nur für **`modules/features/`** genutzt.
- **Hosts** bleiben bewusst **explizit** über `modules/hosts/default.nix` eingebunden.

Warum:
- In `modules/hosts/` liegen gemischte Dateitypen (flake-parts-Module, normale NixOS-Module, Hardware-Dateien).
- Ein breites Auto-Import über den kompletten `modules/`-Baum kann dadurch unerwartete Evaluation-Probleme verursachen.
- Der Hybrid-Ansatz hält Feature-Module bequem auto-discovered und Host-Module stabil/transparent.

## Wo ändere ich was?
- **Neuen Host anlegen**: `modules/hosts/<hostname>/` + Eintrag in `modules/hosts/default.nix`.
- **Host-spezifische Systemoptionen**: `modules/hosts/<hostname>/configuration.nix`.
- **Host-spezifische Home-Optionen**: `modules/hosts/<hostname>/home.nix`.
- **Globale Defaults (alle Hosts)**: `modules/hosts/common-configuration.nix` und `modules/hosts/common-home.nix`.
- **Neue Feature-Module (auto-discovered)**: `modules/features/*.nix`.

---

## Neuen Host aufsetzen

Egal ob Neuinstallation oder Backup-Restore – der Ablauf für ein neues Gerät:

1. **Repo ins Home-Verzeichnis klonen**
   ```bash
   git clone https://github.com/yerTools/nixos-config.git ~/nixos-config && cd ~/nixos-config
   ```

2. **Host-Ordner anlegen & Hardware-Scan kopieren**
   NixOS generiert bei der Installation eine `/etc/nixos/hardware-configuration.nix`. Diese enthält z.B. Festplatten-UUIDs und MUSS in den neuen Ordner. Da sie root gehört, müssen die Rechte angepasst werden:
   ```bash
   mkdir -p modules/hosts/neuer-pc
   sudo cp /etc/nixos/hardware-configuration.nix modules/hosts/neuer-pc/
   sudo chown $USER:users modules/hosts/neuer-pc/hardware-configuration.nix
   ```

3. **Host-Configs anlegen (`modules/hosts/neuer-pc/`)**
   
   **`configuration.nix`** (System)
   ```nix
   { config, pkgs, hostConfig, ... }: {
     imports = [ ./hardware-configuration.nix ../common-configuration.nix ];
     # ... Optionale Host-spezifische Dinge wie KDE etc. ...
     system.stateVersion = "25.11"; # WICHTIG: Aus /etc/nixos/configuration.nix kopieren, nie ändern!
   }
   ```
   **`home.nix`** (User)
   ```nix
   { config, pkgs, hostname, hostConfig, ... }: {
     imports = [ ../common-home.nix ];
     home.stateVersion = "25.11"; # WICHTIG: Entspricht dem aktuellen NixOS-Release zum Zeitpunkt der Ersteinrichtung. Nie ändern!
   }
   ```

4. **Flake-Eintrag hinzufügen**
   In `modules/hosts/default.nix` im `hosts`-Attrset den neuen Host ergänzen:
   ```nix
   hosts = {
     "neuer-pc" = { system = "x86_64-linux"; user = "felix"; description = "Mein neuer PC"; };
   };
   ```

5. **System anwenden**
   ```bash
   sudo nixos-rebuild switch --flake .#neuer-pc
   ```
   *(Danach kannst du deine selbst definierten Aliase wie `rebuild` nutzen.)*

   Mit dem Shell-Helper geht es ohne expliziten Hostnamen:
   ```bash
   rebuild now
   ```
   Dabei wird automatisch der aktuelle Hostname als Flake-Target verwendet.

   Optional Home-Manager standalone:
   ```bash
   home-manager switch --flake .#felix@neuer-pc
   ```

---

## Wichtiges zu Versionen

- **`stateVersion`:** Dies ist **nicht** die NixOS-Version! Es ist ein Kompatibilitäts-Stempel der Erstinstallation. **Einmalig festlegen und danach für die Lebenszeit des Geräts niemals mehr anfassen!** Für `home.nix` nimmst du einfach die Versionsnummer des aktuellen NixOS-Releases zum Zeitpunkt der Installation (z.B. "25.11" oder "24.05").
- **Updates (Flake Inputs):** Die echten Paket-Updates werden global über die `flake.nix` gesteuert (z.B. über `nixos-unstable`). Updates ziehst du einfach für alle Hosts via `nix flake update` (oder dem Alias `upgrade`).
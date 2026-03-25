# Version 2 oder so LOL

## Wichtige Nix Befehle

Flake-Struktur prüfen:
```
nix flake show --show-trace
```

Allgemeine Flake-Checks ausführen:
```
nix flake check --show-trace
```

## Anlegen eines neuen Hosts

Wir nehmen jetzt mal an, dass der neue host `neuer-host-lol` heißen soll.
Der Nutzer soll den Namen `neu` haben und als Beschreibung `Neu LOL`.

1. Kopieren von `/modules/hosts/example` (und allen Dateien) nach `/modules/hosts/neuer-host-lol`
2. Search and replace und in den neune Dateien (`/modules/hosts/neuer-host-lol/*`) einfach `example-host` durch `neuer-host-lol` ersetzen.
3. Search and replance `example-user` durch `neu` ersetzen.
4. Search and replance `Example User` durch `Neu LOL` ersetzen.

## Zeug von Vimjoyer

1. Fische Installation von NixOS mit einem GUI

In `/etc/nixos` liegt nun eine `configuration.nix` und eine `hardware-configuration.nix`.

Flake-Parts erlaubt es, Dateien über den Modul-Namen zu laden und nicht über den Dateipfad. Das erlaubt es, den Inhalt von der Dateistruktur zu entkoppeln.

Das Beispiel hier würde mit `sudo nixos-rebuild switch --flake .#myMachine` gebaut werden, da ich meine Host-Names aber gerne im Kebab-Case hätte, muss das berücksichtigt werden.

Über `nix run .#myNiri` können auch einzelne Pakete ausgeführt werden, um zu Testen, ob das so funktioniert, wie man es sich vorstellt.

Mit dem Befehl `nix run github:vimjoyer/nixconf#niri` kann das Setup von Vimjoyer einfach ausgeführt werden. Ebenso gibt es das für NeoVim `nix run github:vimjoyer/nixconf#neovim`, die gesamte Shell-Umgebung `nix run github:vimjoyer/nixconf#environment` oder sogar den gesamten Desktop `nix run github:vimjoyer/nixconf#desktop`. Alles kann einfach ausgeführt werden, ohne das Home-Directory zu verändern.

Alle Nix Wrapper Modules sind hier aufgelistet: https://birdeehub.github.io/nix-wrapper-modules/md/intro.html

## TODOs:

Überprüfen, ob http(s) gesetzt ist und falls ja, automatisch durch ssh ersetzen, aber nur für dieses Repo
```
git remote set-url origin git@github.com:yerTools/nixos-config.git
```

---

# Felix NixOS Config

Meine modulare Flake-basierte NixOS- und Home-Manager-Konfiguration.

## Struktur
- **`common-*.nix`**: Globale Settings und Tools für **alle** Systeme (Terminal-Basics, Aliase, Netzwerkeinstellungen).
- **`hosts/<hostname>/`**: Lokale Konfigurationen (Hardware, Desktop-Environment, `stateVersion`).

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
   mkdir -p hosts/neuer-pc
   sudo cp /etc/nixos/hardware-configuration.nix hosts/neuer-pc/
   sudo chown $USER:users hosts/neuer-pc/hardware-configuration.nix
   ```

3. **Host-Configs anlegen (`hosts/neuer-pc/`)**
   
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
   In der `flake.nix` im Root-Verzeichnis den neuen Host ergänzen:
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

---

## Wichtiges zu Versionen

- **`stateVersion`:** Dies ist **nicht** die NixOS-Version! Es ist ein Kompatibilitäts-Stempel der Erstinstallation. **Einmalig festlegen und danach für die Lebenszeit des Geräts niemals mehr anfassen!** Für `home.nix` nimmst du einfach die Versionsnummer des aktuellen NixOS-Releases zum Zeitpunkt der Installation (z.B. "25.11" oder "24.05").
- **Updates (Flake Inputs):** Die echten Paket-Updates werden global über die `flake.nix` gesteuert (z.B. über `nixos-unstable`). Updates ziehst du einfach für alle Hosts via `nix flake update` (oder dem Alias `upgrade`).
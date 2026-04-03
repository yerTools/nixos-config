{ self, ... }: 
{
  
  flake.nixosModules.host-konnex-tv-configuration = { pkgs, lib, hostConfig, ... }:
  let
    ramHomeEnabled = hostConfig.ramHome or false;
    persistentRepoPath = hostConfig.persistentRepoPath or "/var/lib/${hostConfig.user.name}-config";
    idleCleanupHours = hostConfig.idleCleanupHours or 0;
    idleCleanupSeconds = idleCleanupHours * 3600;
    cleanupUnitName = "${hostConfig.user.name}-idle-home-cleanup";
    nightlyResetUnitName = "${hostConfig.user.name}-nightly-soft-reset";
    nightlySoftResetTime = hostConfig.nightlySoftResetTime or "";
    nightlySoftResetEnabled = ramHomeEnabled && nightlySoftResetTime != "";
    cleanupProtectedPaths =
      map (path: "/home/${hostConfig.user.name}/${path}")
        (hostConfig.cleanupProtectedPaths or [ ]);
    cleanupProtectedPathsShell = lib.concatMapStringsSep "\n" (path: "      \"${path}\"") cleanupProtectedPaths;
    cleanupScript = ''
      set -eu

      user="${hostConfig.user.name}"
      home_dir="/home/${hostConfig.user.name}"
      keep_path="$home_dir/nixos-config"
      threshold_seconds=${toString idleCleanupSeconds}
      threshold_minutes=$((threshold_seconds / 60))
      force_cleanup="''${CLEANUP_FORCE:-0}"
      protected_paths=(
        "$keep_path"
${cleanupProtectedPathsShell}
      )

      is_protected_path() {
        check_path="$1"
        for protected in "''${protected_paths[@]}"; do
          if [ "$check_path" = "$protected" ] || [[ "$check_path" == "$protected"/* ]]; then
            return 0
          fi
        done
        return 1
      }

      if [ "$force_cleanup" != "1" ]; then
        session_id="$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk -v u="$user" '$3 == u {print $1; exit}')"
        if [ -z "$session_id" ]; then
          exit 0
        fi

        idle_hint="$(${pkgs.systemd}/bin/loginctl show-session "$session_id" -p IdleHint --value)"
        [ "$idle_hint" = "yes" ] || exit 0

        idle_since="$(${pkgs.systemd}/bin/loginctl show-session "$session_id" -p IdleSinceHintMonotonic --value)"
        [ "$idle_since" != "0" ] || exit 0

        now_mono="$(${pkgs.gawk}/bin/awk '{ printf "%.0f", $1 * 1000000 }' /proc/uptime)"
        idle_us=$((now_mono - idle_since))
        required_us=$((threshold_seconds * 1000000))

        [ "$idle_us" -ge "$required_us" ] || exit 0
      fi

      if [ "$force_cleanup" = "1" ]; then
        age_filter=()
      else
        age_filter=( -mmin "+$threshold_minutes" )
      fi

      while IFS= read -r -d $'\0' entry; do
        if is_protected_path "$entry"; then
          continue
        fi

        # Keep all symlinks so Home Manager managed links remain stable.
        if [ -L "$entry" ] || [ -d "$entry" ]; then
          continue
        fi

        rm -rf -- "$entry"
      done < <(${pkgs.findutils}/bin/find "$home_dir" -mindepth 1 "''${age_filter[@]}" -print0)

      while IFS= read -r -d $'\0' entry; do
        if is_protected_path "$entry"; then
          continue
        fi

        rmdir -- "$entry" 2>/dev/null || true
      done < <(${pkgs.findutils}/bin/find "$home_dir" -mindepth 1 -depth -type d "''${age_filter[@]}" -print0)

      if [ ! -e "$home_dir/nixos-config" ]; then
        ln -s "${persistentRepoPath}" "$home_dir/nixos-config"
      fi

      chown -h "$user:users" "$home_dir/nixos-config" || true
    '';
  in {
    # This can be filled with the content from `/etc/nixos/configuration.nix`
    
    imports = [
      # ./hardware-configuration.nix - We don't import by path but rather by module name (file names don't matter).
      self.nixosModules.host-konnex-tv-hardware
    ];

    networking.wireless.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
    
    i18n.defaultLocale = "de_DE.UTF-8";

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = hostConfig.user.name;
    services.desktopManager.plasma6.enable = true;

    # Keep this public device in an always-on state.
    systemd.sleep.settings.Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };

    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;
    services.libinput.touchpad.naturalScrolling = true;

    users.users.${hostConfig.user.name} = {
      packages = with pkgs; [
        kdePackages.kate
      ];
    } // lib.optionalAttrs (hostConfig ? initialPassword) {
      initialPassword = lib.mkDefault hostConfig.initialPassword;
    };

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Avoid persisting user activity traces to SSD where possible.
    services.journald.storage = "volatile";
    boot.tmp.useTmpfs = true;
    boot.tmp.cleanOnBoot = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 ];

    fileSystems."/home/${hostConfig.user.name}" = lib.mkIf ramHomeEnabled {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "mode=0700"
        "nosuid"
        "nodev"
        "size=8G"
      ];
    };

    systemd.tmpfiles.rules = lib.mkIf ramHomeEnabled [
      "d ${persistentRepoPath} 0750 ${hostConfig.user.name} users -"
      "d /home/${hostConfig.user.name} 0700 ${hostConfig.user.name} users -"
      "L+ /home/${hostConfig.user.name}/nixos-config - - - - ${persistentRepoPath}"
    ];

    systemd.services.${cleanupUnitName} = lib.mkIf (ramHomeEnabled && idleCleanupHours > 0) {
      description = "Cleanup stale files in RAM home after prolonged inactivity";
      after = [ "multi-user.target" ];
      path = with pkgs; [ coreutils findutils gawk systemd ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = cleanupScript;
    };

    systemd.timers.${cleanupUnitName} = lib.mkIf (ramHomeEnabled && idleCleanupHours > 0) {
      description = "Run RAM home cleanup check for public workstation";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "10m";
        Unit = "${cleanupUnitName}.service";
      };
    };

    systemd.services.${nightlyResetUnitName} = lib.mkIf nightlySoftResetEnabled {
      description = "Nightly soft reset of public workstation user session";
      after = [ "multi-user.target" ];
      path = with pkgs; [ coreutils findutils gawk systemd ];
      environment = {
        CLEANUP_FORCE = "1";
      };
      serviceConfig = {
        Type = "oneshot";
      };
      script = cleanupScript;
    };

    systemd.timers.${nightlyResetUnitName} = lib.mkIf nightlySoftResetEnabled {
      description = "Run nightly soft reset for public workstation";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = nightlySoftResetTime;
        Persistent = true;
        Unit = "${nightlyResetUnitName}.service";
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };

}
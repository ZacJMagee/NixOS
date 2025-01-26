{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.username = "zacmagee";
  home.homeDirectory = "/home/zacmagee";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.keyboard = null;

  home.sessionVariables = {
    EDITOR = "nvim";
    GI_TYPELIB_PATH = "${pkgs.libgtop}/lib/girepository-1.0:${pkgs.gtk3}/lib/girepository-1.0:${pkgs.gdk-pixbuf}/lib/girepository-1.0:${pkgs.pango.out}/lib/girepository-1.0";
  };
  home.file = {
    ".config/hypr/hyprlock.conf".text = ''
      # GENERAL
      general {
          no_fade_in = true
          no_fade_out = true
          hide_cursor = false
          grace = 0
          disable_loading_bar = true
      }

      # BACKGROUND
      background {
          monitor =
          path = /home/zacmagee/Pictures/Wallpapers/island-night.jpg
          blur_passes = 2
          contrast = 1
          brightness = 0.5
          vibrancy = 0.2
          vibrancy_darkness = 0.2
      }

      # INPUT FIELD
      input-field {
          monitor =
          size = 250, 60
          outline_thickness = 2
          dots_size = 0.2
          dots_spacing = 0.35
          dots_center = true
          outer_color = rgba(0, 0, 0, 0)
          inner_color = rgba(0, 0, 0, 0.2)
          font_color = rgb(242, 243, 244)
          fade_on_empty = false
          rounding = -1
          check_color = rgb(204, 136, 34)
          placeholder_text = Unlock Me
          hide_input = false
          position = 0, -200
          halign = center
          valign = center
      }

      # DATE
      label {
          monitor =
          text = cmd[update:1000] echo "$(date +"%A, %B %d")"
          color = rgba(242, 243, 244, 0.75)
          font_size = 22
          font_family = JetBrains Mono
          position = 0, 300
          halign = center
          valign = center
      }

      # TIME
      label {
          monitor =
          text = cmd[update:1000] echo "$(date +"%-I:%M")"
          color = rgba(242, 243, 244, 0.75)
          font_size = 95
          font_family = JetBrains Mono
          position = 0, 200
          halign = center
          valign = center
      }

      # USERNAME
      label {
          monitor =
          text = cmd[update:0] echo "$(whoami)@$(hostname)"
          color = rgb(242, 243, 244)
          font_size = 14
          font_family = JetBrains Mono
          position = 0, -10
          halign = center
          valign = top
      }
    '';
  };

  home.packages = with pkgs; [
    tmux
    zoxide
    alacritty
    yank
    hyprlock
    jetbrains-mono

    (nerdfonts.override {fonts = ["FiraCode"];})
    (writeScriptBin "toggle-kbd-backlight" ''
      #!${pkgs.bash}/bin/bash
      BRIGHTNESS_FILE="/sys/class/leds/tpacpi::kbd_backlight/brightness"
      CURRENT_BRIGHTNESS=$(cat $BRIGHTNESS_FILE)

      if [ "$CURRENT_BRIGHTNESS" -eq 0 ]; then
          echo 2 > $BRIGHTNESS_FILE
      else
          echo 0 > $BRIGHTNESS_FILE
      fi
    '')
  ];
  # Add this at the top level of your home.nix
  imports = [
    inputs.ags.homeManagerModules.default
  ];
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "widget.use-xdg-desktop-portal" = false;
        "widget.wayland.enabled" = false;
      };
    };
  };

  programs.ags = {
    enable = true;
    configDir = null; # Using ~/.config/ags

    extraPackages = with pkgs; [
      inputs.ags.packages.${system}.battery
      networkmanager
      brightnessctl
      swww
      pamixer
      playerctl
      bluez
      gojq
      socat
      libsoup_3
      librsvg
      webp-pixbuf-loader

      webkitgtk_4_1
    ];
  };

  # This can stay as is since it's not duplicated
  systemd.user.services.ags = {
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.ags}/bin/ags";
      Environment = [
        "PATH=/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin"
      ];
    };
  };
  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 3000;
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      package.disabled = false;
      line_break.disabled = false;
      username = {
        style_user = "white bold";
        style_root = "black bold";
        format = "[$user]($style) ";
        disabled = false;
        show_always = true;
      };
      hostname = {
        ssh_only = false;
        format = "on [$hostname](bold red) ";
        trim_at = ".";
        disabled = false;
      };
      directory = {
        truncation_length = 5;
        format = "in [$path]($style)[$read_only]($read_only_style) ";
      };
      git_branch = {
        format = "on [$symbol$branch]($style) ";
        symbol = "🌱 ";
        truncation_length = 6;
        truncation_symbol = "…";
      };
      git_commit = {
        commit_hash_length = 4;
        tag_symbol = "🔖 ";
      };
      git_state = {
        format = ''([\($state( $progress_current of $progress_total)\)]($style)) '';
      };
      git_status = {
        conflicted = "🏳";
        ahead = "🏎💨";
        behind = "😰";
        diverged = "😵";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "[++\\($count\\)](green)";
        renamed = "👅";
        deleted = "🗑";
      };
      time = {
        disabled = false;
        format = "at [$time]($style) ";
        time_format = "%T";
      };
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow) ";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    shortcut = "Space";
    baseIndex = 1;
    escapeTime = 10;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    terminal = "screen-256color";
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
      {
        plugin = tmuxPlugins.mkTmuxPlugin {
          pluginName = "tpm";
          version = "master";
          src = fetchFromGitHub {
            owner = "tmux-plugins";
            repo = "tpm";
            rev = "master";
            sha256 = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
          };
        };
        extraConfig = ''
          set -g @plugin 'tmux-plugins/tpm'
          set -g @plugin 'omerxx/tmux-sessionx'
          set -g @plugin 'omerxx/tmux-floax'
          set -g @plugin 'tmux-plugins/tmux-yank'
          set -g @plugin 'christoomey/vim-tmux-navigator'

          set -g @plugin 'niksingh710/minimal-tmux-status'

          set -g @sessionx-zoxide-mode 'on'

          set -g @plugin 'tmux-plugins/tmux-resurrect'
          set -g @plugin 'tmux-plugins/tmux-continuum'
          # set -g @continuum-boot 'on'
          set -g @continuum-save-interval '5'
          set -g @continuum-boot-options 'alacritty'
          set -g @continuum-restore 'on'


          set -g mouse on
          set-option -ga terminal-overrides ",xterm-256color:Tc"
          is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
          bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
          bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
          bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
          bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
          tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
          if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
              "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\' 'select-pane -l'"
                  if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
                      "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\' 'select-pane -l'"


                          bind-key -T copy-mode-vi 'C-h' select-pane -L
                          bind-key -T copy-mode-vi 'C-j' select-pane -D
                          bind-key -T copy-mode-vi 'C-k' select-pane -U
                          bind-key -T copy-mode-vi 'C-l' select-pane -R


          run '~/.tmux/plugins/tpm/tpm'
        '';
      }
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font";
          style = "Italic";
        };
        size = 9;
      };
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
        startup_mode = "Windowed";
        dynamic_title = true;
      };
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      colors = {
        primary = {
          background = "0x282c34";
          foreground = "0xabb2bf";
        };
        normal = {
          black = "0x1e2127";
          red = "0xe06c75";
          green = "0x98c379";
          yellow = "0xd19a66";
          blue = "0x61afef";
          magenta = "0xc678dd";
          cyan = "0x56b6c2";
          white = "0xabb2bf";
        };
      };
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 750;
      };
      terminal = {
        shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = [
            "-l"
            "-c"
            "tmux attach || tmux"
          ];
        };
      };
      keyboard = {
        bindings = [
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
          {
            key = "Insert";
            mods = "Shift";
            action = "PasteSelection";
          }
          {
            key = "Key0";
            mods = "Control";
            action = "ResetFontSize";
          }
          {
            key = "Equals";
            mods = "Control";
            action = "IncreaseFontSize";
          }
          {
            key = "Minus";
            mods = "Control";
            action = "DecreaseFontSize";
          }
        ];
      };
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "eza -l --icons --color=always --no-filesize --no-user";
      ll = "eza -l --icons --color=always --no-filesize --no-user";
      fman = "compgen -c | fzf | xargs man";
      tree = "tree -a -I '.git|__pycache__|*.pyc|.local|pip|lib|site-packages|target|Cargo.lock|node_modules|.next|yarn.lock|package-lock.json|*.log|.env*' --charset X";
      v = "nvim .";
      oo = "cd ~/ObsidianSync/NvimZettelkasten/inbox && nvim .";
      df = "cd /etc/nixos/dotfiles && nvim .";
      on = "~/ObsidianSync/on.sh";
      og = "~/ObsidianSync/og.sh";
      nvc = "cd ~/dotfiles/nvim/.config/nvim/ && nvim .";
      noc = "cd /etc/nixos/ && nvim .";
    };
    initExtraFirst = ''
      source ~/.config/zsh/secrets.sh
      export PATH=${pkgs.neovim}/bin:$PATH
      export PATH=~/.npm-global/bin:$PATH
      export FZF_BASE=${pkgs.fzf}/share/fzf
      eval "$(fzf --zsh)"
      export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
      export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"
      # Setup fzf previews
      export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
      export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"
      # fzf preview for tmux
      export FZF_TMUX_OPTS=" -p90%,70% "
      # Use the system-wide Android SDK path
      export ANDROID_HOME="$ANDROID_HOME"
      export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
      export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
      eval "$(direnv hook zsh)"

    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["zoxide" "vi-mode" "fzf"];
    };
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-abbr";
        src = pkgs.zsh-abbr.src;
      }
      {
        name = "zsh-fzf-tab";
        src = pkgs.zsh-fzf-tab.src;
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions.src;
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use.src;
      }
      {
        name = "zsh-fzf-history-search";
        src = pkgs.zsh-fzf-history-search.src;
      }
      {
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting.src;
      }
    ];
    initExtra = ''
      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
      source ${pkgs.zsh-fzf-history-search}/share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
    '';
  };

  home.activation = {
    tmuxPluginManager = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
      fi
    '';
  };
}

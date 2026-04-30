FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
    git curl ca-certificates tmux gh locales \
    build-essential pkg-config libssl-dev \
    cargo rustc \
 && sed -i 's/^# *ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen ko_KR.UTF-8 \
 && update-locale LANG=ko_KR.UTF-8 LC_ALL=ko_KR.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=ko_KR.UTF-8 \
    LC_ALL=ko_KR.UTF-8 \
    LC_CTYPE=ko_KR.UTF-8

RUN npm install -g @openai/codex oh-my-codex

RUN mkdir -p /workspace \
 && { \
    echo '# Korean/UTF-8 locale propagation'; \
    echo 'set -g default-terminal "tmux-256color"'; \
    echo 'set -g update-environment "DISPLAY KRB5CCNAME SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY LANG LC_ALL LC_CTYPE LANGUAGE"'; \
    echo ''; \
    echo '# Mouse drag selection/copy'; \
    echo 'set -g mouse on'; \
    echo 'set -g set-clipboard on'; \
    echo 'set -as terminal-features '\'',*:clipboard'\'''; \
    echo 'bind-key -T root MouseDrag1Pane if-shell -F "#{pane_in_mode}" "send-keys -M" "copy-mode -M"'; \
    echo 'bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "tmux load-buffer -w -"'; \
    echo 'bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "tmux load-buffer -w -"'; \
    } > /root/.tmux.conf \
 && { \
    echo ''; \
    echo '# Korean/UTF-8 tmux support'; \
    echo 'export LANG=ko_KR.UTF-8'; \
    echo 'export LC_ALL=ko_KR.UTF-8'; \
    echo 'export LC_CTYPE=ko_KR.UTF-8'; \
    echo 'alias tmux="tmux -u"'; \
    } >> /root/.bashrc

WORKDIR /workspace

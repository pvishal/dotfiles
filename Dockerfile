FROM osrf/ros:melodic-desktop-full
ENV DEBIAN_FRONTEND=noninteractive

# Use bash
SHELL ["/bin/bash", "-c"]

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt-get update && \
    apt-get install -y apt-utils git lsb-release build-essential neovim tmux && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y ros-melodic-rviz ros-melodic-gmapping \
    ros-melodic-map-server ros-melodic-amcl ros-melodic-move-base ros-melodic-dwa-local-planner && \
    rm -rf /var/lib/apt/lists/*


# Setup and configure tmux
COPY .config/tmux /root/.config/tmux
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    ln -s /root/.config/tmux/tmux.conf /root/.tmux.conf

COPY .config/nvim /root/.config/nvim
RUN nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1


#RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
#    ~/.fzf/install --all

#COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["bash"]

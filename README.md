Dotfiles
========


## Running via Docker

```shell
docker volume create ros-container-root
docker build -t pvishal/shell .
./run.bash
```

## Running on host

```shell
git clone https://github.com/pvishal/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

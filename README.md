# Minecraft Server Container Script

This is a collection of configurable scripts and configuration files for a survival paper minecraft server on docker with a simple web server for downloading backups.

This includes some basic plugins and configs for a very good vanilla experience, including sleep, backup and auto restart plugins.

# Setup

1. Install git and clone this repository in your home directory.
2. Modify the docker-compose and plugin configuration files as you wish.
3. Run the install script.

The install script is targeted for Debian and Debian-based operating systems and requires a user with sudo permissions, it does a few things:
1. Creates a 2GB swapfile to avoid OOM crashes.
2. Installs docker engine and docker-compose.
3. Adds the user to the docker group for running in non-root mode.
4. Runs docker-compose
5. Copies all config files to the server
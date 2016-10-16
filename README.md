[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/mrmachine/plex-cloud-encfs/)

# Plex Cloud EncFS

Easily run your own version of Plex in the Cloud, on any infrastructure you choose, with your media library safely encrypted with EncFS on Amazon Cloud Drive.

The following additional apps are included (and already configured to work together) to automate downloads and manage your media library:

  * Couch Potato
  * NZBGet
  * Sick Rage
  * Transmission

# Run on Docker Cloud

 1. Click the [Deploy to Docker Cloud](https://cloud.docker.com/stack/deploy/?repo=https://github.com/mrmachine/plex-cloud-encfs/) button above to create a new stack on Docker Cloud.

 2. Provide or update values for all the required environment variables.

 3. Save and start the stack.

 4. On first run, the `plex-cloud-encfs` container's entrypoint script will pause so you can run an interactive terminal to configure `acd-cli` and `encfs`:

     1. Navigate to the `plex-cloud-encfs` container and start a terminal.

     2. Run the entrypoint script, which will detect the interactive terminal and prompt you for authorisation and configuration:

            # entrypoint.sh

    After `acd-cli` and `encfs` are configured, the `plex-cloud-encfs` container's entrypoint script will continue automatically, and you can close your interactive terminal.

 5. Navigate to the `Endpoints` section of the stack and take note of the address for the service endpoint. Something like: `http://letsencrypt.{stack-name}.{sha}.svc.dockerapp.io:80/`

 6. Configure wildcard or individual subdomain CNAME records on your domain that point to the service endpoint noted above. Something like: `letsencrypt.{stack-name}.{sha}.svc.dockerapp.io`

Note that on Docker Cloud, persistent data (personal configuration, library data) is stored on the node. If services are redeployed to a different node, this data will be lost.

# Run with Docker Compose

 1. Get the code and change directory:

        $ git clone https://github.com/mrmachine/plex-cloud-encfs.git
        $ cd plex-cloud-encfs

 2. Save `docker-compose.override.sample.yml` as `docker-compose.override.yml` and provide or update values for all the required environment variables.

 3. On first run, `acd-cli` and `encfs` will both prompt you for authorisation and configuration, so run interactively:

        $ docker-compose run --rm --service-ports plex-cloud-encfs

    After `acd-cli` and `encfs` are configured, you can run as a background service:

        $ docker-compose up -d

 4. Configure wildcard or individual subdomain DNS records on your domain that point to your IP address, or access (from the same machine) via `*.lvh.me` (a wildcard DNS record that points to `127.0.0.1`):

      * http://couchpotato.lvh.me
      * http://nzbget.lvh.me
      * http://plex.lvh.me
      * http://sickrage.lvh.me
      * http://transmission.lvh.me

# Required environment variables

The following environment variables *must* be provided:

  * `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` -- All services except Plex Media Server (which implements its own authentication) will be protected by basic auth using these credentials.

  * `ENCFS_PASSWORD` -- Your media library will be encrypted on Amazon Cloud Drive using this password. You will never need to type it interactively, so make it strong. For example, 50+ random characters including uppercase, lowercase, numbers and symbols.

  * `PLEX_USERNAME` and `PLEX_PASSWORD` -- These are used to obtain an authentication token (which you can provide as `PLEX_TOKEN` instead, if already known) which links this Plex Media Server to your Plex account.

  * `DOMAINS` -- DNS must be configured to ensure the server is reachable at these domains.

  * `EMAIL` -- SSL certificate expiration notices will be sent to this email address.

# Secure access over HTTPS

All services can only be accessed remotely over HTTPS.

SSL certificates will be created and renewed automatically for the domains listed in the `DOMAINS` environment variable, as long as the `letsencrypt` service is reachable at those domains.

# EncFS storage on Amazon Cloud Drive

The "storage" directory is where Plex Media Server expects to find its media libraries:

  * Home Videos
  * Movies
  * Music
  * Photos
  * TV Shows

Your Amazon Cloud Drive is mounted at `/mnt/acd`.

The `ACD_STORAGE_DIR` environment variable configures where your encrypted (via EncFS) storage directory will be located on your Amazon Cloud Drive. The default is `PCE`.

The unencrypted storage directory is mounted at `/mnt/acd-storage`.

Remote storage like Amazon Cloud Drive is good enough to store and stream media, but is not ideal for downloading and extracting files. For that, we have `/mnt/local-storage`.

A UnionFS volume is mounted at `/mnt/storage`, which provides seamless read/write access to `/mnt/local-storage` and read-only access to `/mnt/acd-storage`. This makes newly downloaded files immediately available to Plex Media Server.

The `local-to-acd.py` script is executed on a schedule, and will move all media library files from `/mnt/local-storage` to `/mnt/acd-storage`.

# Configuration

All the apps are configured to work together, and some of their default settings have been tweaked according to my own personal preferences. Notably:

  * Couch Potato
      * Enable dark theme
      * Enable debug logging
      * Rename and move downloaded files to `/mnt/storage/Movies`
          * File name format: `<thename> (<year>) <quality><cd>.<ext>`
          * Folder name format: `<thename> (<year>)`
      * Enable NZBGet, Plex Media Server, and Transmission integration
      * Enable NZBs.org indexer
      * Disable public torrent trackers
      * Enable library management
      * Enable Pushover notifications
      * Prefer NZBs over torrents
      * Require 720P quality
      * Enable automation
          * Download all Action, Drama, Horror, or Sci-Fi rated over 8.0 since 1979
          * Ignore Comedy, Romance
  * NZBGet
      * Enable `nzbToMedia` integration
      * Disable authentication (rely on nginx basic authentication)
      * Enable loggable output
      * Server 1 config: 10 connections, encrypted, port 443
  * Plex Media Server
      * Friendly name: `Plex Cloud EncFS`
  * Sick Rage
      * Enable BTN and NZBs.org providers
      * Enable failed download handling (via `nzbToMedia`)
      * Enable auto-update
      * Enable debug logging
      * Flatten folders by default
      * Rename and move downloaded files to `/mnt/storage/TV Shows`
      	  * File naming pattern: `%Sx%0E %EN %QN`
      * Require 720P or DVD-Rip quality
  * Transmission
      * Remove movie torrents and data after a seed ratio of 2.0
      * Remove TV show torrents and data after 240 hours (10 days) seed time

Check the `etc/*.tmpl.*` files to see exactly what has been changed from their original defaults.

You will need to further configure them with your own personal preferences. For example:

  * Media libraries
  * Torrent tracker credentials
  * Usenet indexer/provider credentials
  * Wanted movies and TV shows

All the additional apps run by default. If you only want some of them, you can specify just the ones you want in the Docker Cloud stack or `docker-compose.override.yml` file:

    plex-cloud-encfs:
      environment:
        SUPERVISORD_INCLUDE_FILES: couchpotatoserver.conf nzbget.conf sickrage.conf transmission.conf

## Plex Media Server

On first run, there are no automatically configured media libraries. When you add a library, be sure to choose from the existing library directories:

  * `/mnt/storage/Home Videos`
  * `/mnt/storage/Movies`
  * `/mnt/storage/Music`
  * `/mnt/storage/Photos`
  * `/mnt/storage/TV Shows`

## Transmission

Completed torrents and data will be removed from Transmission when ratio or seeding time requirements have been satisfied. Configure the rules with the `REQUIREMENTS` environment variable:

    # {category:ratio:hours};...
    REQUIREMENTS="Movies:2.0:;TV Shows::240"

By default, movies will be removed after a seed ratio of 2.0 and TV shows will be removed after a seed time of 240 hours (10 days).

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

 5. Navigate to the `Endpoints` section of the stack and take note of the address for the service endpoint. Something like: `plex-cloud-encfs.{stack-name}.{sha}.svc.dockerapp.io`

 6. Configure wildcard or individual subdomain CNAME records that point to the service endpoint noted above, for `couchpotato`, `nzbget`, `plex`, `sickrage`, and `transmission` on your domain.

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

 4. Configure wildcard or individual subdomain DNS records that point to your IP address, for `couchpotato`, `nzbget`, `plex`, `sickrage`, and `transmission` on your domain.

# Required environment variables

The following environment variables *must* be provided:

  * `ACD_OAUTH_DATA` -- Login with your Amazon credentials at https://tensile-runway-92512.appspot.com/ to download an `oauth_data` file for `acd-cli`. Add the contents of the file to your `docker-cloud.yml` or `docker-compose.yml` file.

  * `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` -- All services except Plex Media Server (which implements its own authentication) will be protected by basic auth using these credentials.

  * `DOMAIN` and `EMAIL` -- The domain on which the individual app subdomains are configured, and an email address where certificate expiration notices should be sent.

  * `ENCFS_PASSWORD` -- Your media library will be encrypted on Amazon Cloud Drive using this password. You will never need to type it interactively, so make it strong. For example, 50+ random characters including uppercase, lowercase, numbers and symbols.

  * `PLEX_USERNAME` and `PLEX_PASSWORD` -- These are used to obtain an authentication token (which you can provide as `PLEX_TOKEN` instead, if already known) which links this Plex Media Server to your Plex account.

# Secure access over HTTPS

All services can only be accessed remotely over HTTPS. SSL certificates will be created and renewed automatically for app subdomains under the domain given in the `DOMAIN` environment variable.

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

# Configuration

All the apps are configured to work together, and some of their default settings have been tweaked according to my own personal preferences. Notably:

  * Couch Potato
      * Enable dark theme
      * Enable debug logging
      * Rename and move downloaded files to `/mnt/acd-storage/Movies`
          * File name format: `<thename> (<year>) <quality><cd>.<ext>`
          * Folder name format: `<thename> (<year>)`
      * Enable NZBGet, Plex Media Server, and Transmission integration
      * Enable DogNZB, GeekNZB, NZBs.org and Pass The Popcorn searchers
      * Disable public torrent trackers
      * Enable library management
      * Enable Pushover notifications
      * Prefer NZBs over torrents
      * Require 1080P WEB-DL, DVDrip, or SDTV quality
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
      * Enable BTN, DogNZB, GeekNZB, and NZBs.org providers
      * Enable failed download handling (via `nzbToMedia`)
      * Enable auto-update
      * Enable debug logging
      * Flatten folders by default
      * Rename and move downloaded files to `/mnt/acd-storage/TV Shows`
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

## Plex Media Server

On first run, there are no automatically configured media libraries. When you add a library, be sure to choose from the existing library directories:

  * `/mnt/acd-storage/Home Videos`
  * `/mnt/acd-storage/Movies`
  * `/mnt/acd-storage/Music`
  * `/mnt/acd-storage/Photos`
  * `/mnt/acd-storage/TV Shows`

## Transmission

Completed torrents and data will be removed from Transmission when ratio or seeding time requirements have been satisfied. Configure the rules with the `REQUIREMENTS` environment variable:

    # {category:ratio:hours};...
    REQUIREMENTS="Movies:2.0:;TV Shows::240"

By default, movies will be removed after a seed ratio of 2.0 and TV shows will be removed after a seed time of 240 hours (10 days).

# TODO

  * [ ] Schedule `local-to-acd.py` execution.
  * [ ] Simplify authorisation and configuration of `acd-cli` and `encfs` on first run.

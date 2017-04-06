[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/mrmachine/plex-cloud-encfs/)

# Plex Cloud EncFS

Easily run your own version of Plex in the Cloud, on any infrastructure you choose, with your media library safely encrypted with EncFS on Google Cloud Storage.

The following additional apps are included (and already configured to work together) to automate downloads and manage your media library:

  * Couch Potato
  * NZBGet
  * Sick Rage
  * Transmission

# Run on Docker Cloud

 1. Click the [Deploy to Docker Cloud](https://cloud.docker.com/stack/deploy/?repo=https://github.com/mrmachine/plex-cloud-encfs/) button above to create a new stack on Docker Cloud.

 2. Provide or update values for all the required environment variables.

 3. Save and start the stack.

 4. Navigate to the `Endpoints` section of the stack and take note of the address for the service endpoint. Something like: `plex-cloud-encfs.{stack-name}.{sha}.svc.dockerapp.io`

 5. Configure wildcard or individual subdomain CNAME records that point to the service endpoint noted above, for `couchpotato`, `nzbget`, `plex`, `sickrage`, and `transmission` on your domain.

Note that on Docker Cloud, persistent data (personal configuration, media library metadata) is stored on the node. If services are redeployed to a different node, this data will be lost.

# Run with Docker Compose

 1. Get the code and change directory:

        $ git clone https://github.com/mrmachine/plex-cloud-encfs.git
        $ cd plex-cloud-encfs

 2. Save `docker-compose.override.sample.yml` as `docker-compose.override.yml` and provide or update values for all the required environment variables.

 3. Configure wildcard or individual subdomain DNS records that point to your IP address, for `couchpotato`, `nzbget`, `plex`, `sickrage`, and `transmission` on your domain.

# Required environment variables

The following environment variables *must* be provided:

  * `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` -- All services except Plex Media Server (which implements its own authentication) will be protected by basic auth using these credentials.

  * `DOMAIN` and `EMAIL` -- The domain on which the individual app subdomains are configured, and an email address where certificate expiration notices should be sent.

  * `ENCFS_PASSWORD` -- Your media library will be encrypted using this password. You will never need to type it interactively, so make it strong. For example, 50+ random characters including uppercase, lowercase, numbers and symbols.

  * `GOOGLE_APPLICATION_CREDENTIALS` -- Follow the instructions at https://developers.google.com/identity/protocols/application-default-credentials to download a key file for Google Cloud Storage. Add the contents of the file to your `docker-cloud.yml` or `docker-compose.yml` file.

  * `GOOGLE_CLOUD_STORAGE_BUCKET` -- The name of the Google Cloud Storage bucket where you want to store your media library.

  * `PLEX_USERNAME` and `PLEX_PASSWORD` -- These are used to obtain an authentication token (which you can provide as `PLEX_TOKEN` instead, if already known) which links this Plex Media Server to your Plex account.

# Secure access over HTTPS

All services can only be accessed remotely over HTTPS. SSL certificates will be created and renewed automatically for app subdomains under the domain given in the `DOMAIN` environment variable.

# EncFS storage on Google Cloud Storage

The "storage" directory is where Plex Media Server expects to find your media library:

  * Home Videos
  * Movies
  * Music
  * Photos
  * TV Shows

Your Google Cloud Storage bucket is mounted at `/mnt/gcp`.

The `PCE_STORAGE_DIR` environment variable configures where your encrypted (via EncFS) storage directory will be located in your Google Cloud Storage bucket. The default is `PCE`.

The unencrypted storage directory is mounted at `/mnt/storage`.

Remote storage like Google Cloud Storage is good enough to store and stream media, but is not ideal for downloading and extracting files. For that, we have `/mnt/local-storage`.

# Configuration

All the apps are configured to work together, and some of their default settings have been tweaked according to my own personal preferences. Notably:

  * Couch Potato
      * Enable dark theme
      * Enable debug logging
      * Rename and move downloaded files to `/mnt/storage/Movies`
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
      * Rename and move downloaded files to `/mnt/storage/TV Shows`
      	  * File naming pattern: `%Sx%0E %EN %QN`
      * Require 720P or DVD-Rip quality
  * Transmission
      * Remove movie torrents and data after a seed ratio of 2.0
      * Remove TV show torrents and data after 240 hours (10 days) seed time

Check the `etc/*.tmpl.*` files to see exactly what has been changed from their original defaults.

You will need to further configure them with your own personal preferences. For example:

  * Plex Media Server libraries
  * Torrent tracker credentials
  * Usenet indexer/provider credentials
  * Wanted movies and TV shows

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

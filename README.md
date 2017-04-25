[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/mrmachine/plex-cloud-suite/)

# Plex Cloud Suite

Provides a suite of apps, already configured to work together, to automate downloads and manage your Plex Cloud media library:

  * Couch Potato
  * NZBGet
  * Sick Rage
  * Transmission

# Run on Docker Cloud

 1. Click the [Deploy to Docker Cloud](https://cloud.docker.com/stack/deploy/?repo=https://github.com/mrmachine/plex-cloud-suite/) button above to create a new stack on Docker Cloud.

 2. Provide or update values for all the required environment variables.

 3. Save and start the stack.

 4. Navigate to the `Endpoints` section of the stack and take note of the address for the service endpoint. Something like: `plex-cloud-suite.{stack-name}.{sha}.svc.dockerapp.io`

 5. Configure wildcard or individual subdomain CNAME records that point to the service endpoint noted above, for `couchpotato`, `nzbget`, `plex`, `sickrage`, and `transmission` on your domain.

Note that on Docker Cloud, persistent data (personal configuration, media library metadata) is stored on the node. If services are redeployed to a different node, this data will be lost.

# Run with Docker Compose

 1. Get the code and change directory:

        $ git clone https://github.com/mrmachine/plex-cloud-suite.git
        $ cd plex-cloud-suite

 2. Save `docker-compose.override.sample.yml` as `docker-compose.override.yml` and provide or update values for all the required environment variables.

 3. Configure wildcard or individual subdomain DNS records that point to your IP address, for `couchpotato`, `nzbget`, `plex`, `sickrage`, and `transmission` on your domain.

# Required Environment Variables

The following environment variables *must* be provided:

  * `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` -- All services except Plex Media Server (which implements its own authentication) will be protected by basic auth using these credentials.

  * `DOMAIN` and `EMAIL` -- The domain on which the individual app subdomains are configured, and an email address where certificate expiration notices should be sent.

  * `RCLONE_CONF` -- Run `rclone config` to generate an `rclone.conf` file for your preferred cloud storage provider. Add the contents of the file to your `docker-cloud.yml` or `docker-compose.yml` file.

# Secure Access Over HTTPS

All services can only be accessed remotely over HTTPS. SSL certificates will be created and renewed automatically for app subdomains under the domain given in the `DOMAIN` environment variable.

# Cloud Storage via Rclone and UnionFS

The `/mnt/remote/storage` directory is where your Dropbox, Google Drive or OneDrive cloud storage will be mounted via Rclone.

The `/mnt/storage` directory is a UnionFS mount spanning `/mnt/local/storage` and `/mnt/remote/storage`.

Couch Potato and Sick Rage will move downloaded files to the `Movies` and `TV Shows` directories in local storage, via the UnionFS mount, during post processing.

An `rclone move` command runs in a loop, moving files older than 1 minute from local to remote storage.

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
      * Require 2160P, 1080P, or DVD-Rip quality
      * Automation requirements: Sci-Fi, rated over 8.0, released after 1979
  * NZBGet
      * Enable `nzbToMedia` integration
      * Disable authentication (rely on nginx basic authentication)
      * Enable loggable output
      * Server 1 config: 10 connections, encrypted, port 443
      * Server 2 config: level 1, 10 connections, encrypted, port 443
      * Pause download queue on par check, unpack and script execution.
  * Sick Rage
      * Enable BTN, DogNZB, GeekNZB, and NZBs.org providers
      * Enable failed download handling (via `nzbToMedia`)
      * Enable auto-update
      * Enable debug logging
      * Flatten folders by default
      * Rename and move downloaded files to `/mnt/storage/TV Shows`
      	  * File naming pattern: `%Sx%0E %EN %QN`
      * Require 1080P WEB-DL, DVDrip, or SDTV quality
  * Transmission
      * Remove movie torrents and data after a seed ratio of 2.0
      * Remove TV show torrents and data after 240 hours (10 days) seed time

Check the `etc/*.tmpl.*` files to see exactly what has been changed from their original defaults.

You will need to further configure them with your own personal preferences. For example:

  * Torrent tracker credentials
  * Usenet indexer/provider credentials
  * Wanted movies and TV shows

## Transmission

Completed torrents and data will be removed from Transmission when ratio or seeding time requirements have been satisfied. Configure the rules with the `REQUIREMENTS` environment variable:

    # {category:ratio:hours};...
    REQUIREMENTS="Movies:2.0:;TV Shows::240"

By default, movies will be removed after a seed ratio of 2.0 and TV shows will be removed after a seed time of 240 hours (10 days).

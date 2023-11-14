# AleForge Pterodactyl Containers

All Docker images used by the Aleforge infrastructure. A curated collection of core images that can be used with Pterodactyl's Egg system. Each image is rebuilt periodically to ensure dependencies are always up-to-date and security vulnerabilities are remidiated.

Images are hosted on `ghcr.io` and exist under the `games`, `installers`, and `java` spaces. The following logic
is used when determining which space an image will live under:

* `games` — anything within the `games` folder in the repository. These are images built for running a specific game
or type of game.
* `installers` — anything living within the `installers` directory. These images are used by install scripts for different
Eggs within Pterodactyl, not for actually running a game server. These images are only designed to reduce installation time
and network usage by pre-installing common installation dependencies such as `curl` and `wget`.
* `java` —  generic images Java images that allow different types of games or scripts to run. They're generally just
a specific version of software and allow different Eggs within Pterodactyl to switch out the underlying implementation. An
example of this would be something like Java for Minecraft servers, etc.

All of these images are available for `linux/amd64` and `linux/arm64` versions, unless otherwise specified, to use
these images on an arm system, no modification to them or the tag is needed, they should just work.

## Available images:

### [Java](/java)

#### [GraalVM](/java/GraalVM)

* [`java8`](/GraalVM/jdk8-ee)
  * `ghcr.io/aleforge/containers:graalvm-jdk8-ee`
* [`java11`](/GraalVM/jdk11-ee)
  * `ghcr.io/aleforge/containers:graalvm-jdk11-ee`
  * `ghcr.io/aleforge/containers:graalvm-jdk11`
* [`java17`](/GraalVM/jdk17-ee)
  * `ghcr.io/aleforge/containers:graalvm-jdk17-ee`
  * `ghcr.io/aleforge/containers:graalvm-jdk17`
* [`java20`](/GraalVM/jdk20)
  * `ghcr.io/aleforge/containers:graalvm-jdk20`
* [`java21`](/GraalVM/jdk21)
  * `ghcr.io/aleforge/containers:graalvm-jdk21`

## Sponsor :
[![AleForge](https://github.com/aleforge/Containers/blob/98083fcd752912b8cb2b243cca3b2612726c189f/images/aleforge-logo-dark.jpg)](https://aleforge.net)

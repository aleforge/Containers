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

### [Oses](/oses)

* [alpine](/oses/alpine)
  * `ghcr.io/aleforge/base:alpine`
* [debian](/oses/debian)
  * `ghcr.io/aleforge/base:debian`
* [ubuntu](/oses/ubuntu)
  * `ghcr.io/aleforge/base:ubuntu`

### [dotNet](/dotnet)

* [`dotnet6.0`](/dotnet/6)
  * `ghcr.io/aleforge/dotnet:6`

### [Games](/games)

* [`Holdfast`](/games/holdfastnaw)
  * `ghcr.io/aleforge/games:holdfastnaw`
* [`Rust`](/games/rust)
  * `ghcr.io/aleforge/games:rust`

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

### [SteamCMD](/steamcmd)
* [`SteamCMD Debian Latest`](/steamcmd/debian)
  * `ghcr.io/aleforge/steamcmd:debian`
* [`SteamCMD Debian Dotnet`](/steamcmd/dotnet)
  * `ghcr.io/aleforge/steamcmd:dotnet`
* [`SteamCMD Proton`](/steamcmd/proton)
  * `ghcr.io/aleforge/steamcmd:proton`
 [`SteamCMD Proton`](/steamcmd/proton8)
  * `ghcr.io/aleforge/steamcmd:proton8`
* [`SteamCMD Ubuntu latest LTS`](/steamcmd/ubuntu)
  * `ghcr.io/aleforge/steamcmd:ubuntu`

### [SteamRT3](/RT3)
* [`Steam Runtime 3 Latest`](/rt3/latest)
  * `ghcr.io/aleforge/steamrt3:latest`
* [`Steam Runtime 3 Latest`](/rt3/beta)
  * `ghcr.io/aleforge/steamrt3:beta`

### [Wine](/wine)

* [`Wine`](/wine)
  * `ghcr.io/aleforge/wine:latest`
  * `ghcr.io/aleforge/wine:devel`
  * `ghcr.io/aleforge/wine:staging`
  * `ghcr.io/aleforge/wine:8`

## Sponsor :
[![AleForge](https://github.com/aleforge/Containers/blob/7b152c2d6b0bbbdaa759778d3f398a5d9dffc237/images/aleforge-logo-dark.jpg)](https://aleforge.net)

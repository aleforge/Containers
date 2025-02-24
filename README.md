# AleForge Pterodactyl Containers

All Docker images used by the Aleforge infrastructure. A curated collection of core images that can be used with Pterodactyl's Egg system. Each image is rebuilt periodically to ensure dependencies are always up-to-date and security vulnerabilities are remidiated.

We recommend trying to use images in the [Pterodactyl's Yolks repo](https://github.com/parkervcp/yolks) before trying to use our images
because these images are tuned to work with our platform and may not function out of the box with the publicly available [eggs](https://github.com/parkervcp/eggs)

## Available images:

### [Oses](/oses)

- [alpine](/oses/alpine)
  - `ghcr.io/aleforge/base:alpine`
- [debian](/oses/debian)
  - `ghcr.io/aleforge/base:debian`
- [ubuntu](/oses/ubuntu)
  - `ghcr.io/aleforge/base:ubuntu`

### [dotNet](/dotnet)

- [`dotnet2.1`](/dotnet/2.1)
  - `ghcr.io/aleforge/dotnet:2.1`
- [`dotnet3.1`](/dotnet/3.1)
  - `ghcr.io/aleforge/dotnet:3.1`
- [`dotnet5.0`](/dotnet/5)
  - `ghcr.io/aleforge/dotnet:5`
- [`dotnet6.0`](/dotnet/6)
  - `ghcr.io/aleforge/dotnet:6`
- [`dotnet7.0`](/dotnet/7)
  - `ghcr.io/aleforge/dotnet:7`
- [`dotnet8.0`](/dotnet/8)
  - `ghcr.io/aleforge/dotnet:8`

### [Games](/games)

- [`Holdfast`](/games/holdfastnaw)
  - `ghcr.io/aleforge/games:holdfastnaw`
- [`Rust`](/games/rust)
  - `ghcr.io/aleforge/games:rust`
- [`Source`](/games/source)
  - `ghcr.io/aleforge/games:source`
- [`Aloft`](/games/aloft)
  - `ghcr.io/aleforge/games:aloft`
- [`Valheim`](/games/valheim)
  - `ghcr.io/aleforge/games:valheim`
- [`corekeeper`](/games/corekeeper)
  - `ghcr.io/aleforge/games:corekeeper`

### [Java](/java)

#### [Temurin](/java/Temurin)

* [`java8`](/java/8)
  * `ghcr.io/aleforge/containers:java-8`
* [`java11`](/java/11)
  * `ghcr.io/aleforge/containers:java-11`
* [`java16`](/java/16)
  * `ghcr.io/aleforge/containers:java-16`
* [`java17`](/java/17)
  * `ghcr.io/aleforge/containers:java-17`
* [`java19`](/java/19)
  * `ghcr.io/aleforge/containers:java-19`
* [`java21`](/java/21)
  * `ghcr.io/aleforge/containers:java-21`
* [`java22`](/java/22)
  * `ghcr.io/aleforge/containers:java-22`
* [`java23`](/java/23)
  * `ghcr.io/aleforge/containers:java-23`

#### [GraalVM](/java/GraalVM)

- [`java8`](/GraalVM/jdk8-ee)
  - `ghcr.io/aleforge/containers:graalvm-jdk8-ee`
- [`java11`](/GraalVM/jdk11-ee)
  - `ghcr.io/aleforge/containers:graalvm-jdk11-ee`
  - `ghcr.io/aleforge/containers:graalvm-jdk11`
- [`java17`](/GraalVM/jdk17-ee)
  - `ghcr.io/aleforge/containers:graalvm-jdk17-ee`
  - `ghcr.io/aleforge/containers:graalvm-jdk17`
- [`java20`](/GraalVM/jdk20)
  - `ghcr.io/aleforge/containers:graalvm-jdk20`
- [`java21`](/GraalVM/jdk21)
  - `ghcr.io/aleforge/containers:graalvm-jdk21`
- [`java22`](/GraalVM/jdk22)
  - `ghcr.io/aleforge/containers:graalvm-jdk22`

#### [OpenJDK](/java/OpenJDK)

* [`java8`](/java/OpenJDK/8j9)
  * `ghcr.io/aleforge/containers:java-8j9`
* [`java11`](/java/OpenJDK/11j9)
  * `ghcr.io/aleforge/containers:java-11j9`
* [`java16`](/java/OpenJDK/16j9)
  * `ghcr.io/aleforge/containers:java-16j9`
* [`java17`](/java/OpenJDK/17j9)
  * `ghcr.io/aleforge/containers:java-17j9`
* [`java19`](/java/OpenJDK/19j9)
  * `ghcr.io/aleforge/containers:java-19j9`
* [`java21`](/java/OpenJDK/21j9)
  * `ghcr.io/aleforge/containers:java-21j9`

### [MariaDB](/mariadb)

- [`MariaDB 10.3`](/mariadb/10.3)
  - `ghcr.io/aleforge/proton:10.3`
- [`MariaDB 10.4`](/mariadb/10.4)
  - `ghcr.io/aleforge/proton:10.4`
- [`MariaDB 10.5`](/mariadb/10.5)
  - `ghcr.io/aleforge/proton:10.5`
- [`MariaDB 10.6`](/mariadb/10.6)
  - `ghcr.io/aleforge/proton:10.6`
- [`MariaDB 10.7`](/mariadb/10.7)
  - `ghcr.io/aleforge/proton:10.7`
- [`MariaDB 11.2`](/mariadb/11.2)
  - `ghcr.io/aleforge/proton:11.2`
- [`MariaDB 11.3`](/mariadb/11.3)
  - `ghcr.io/aleforge/proton:11.3`
- [`MariaDB 11.4`](/mariadb/11.4)
  - `ghcr.io/aleforge/proton:11.4`

### [SteamCMD](/steamcmd)

- [`SteamCMD Debian Latest`](/steamcmd/debian)
  - `ghcr.io/aleforge/steamcmd:debian`
- [`SteamCMD Debian Dotnet`](/steamcmd/dotnet)
  - `ghcr.io/aleforge/steamcmd:dotnet`
- [`SteamCMD Proton`](/steamcmd/proton)
  - `ghcr.io/aleforge/steamcmd:proton`
    [`SteamCMD Proton8`](/steamcmd/proton8)
  - `ghcr.io/aleforge/steamcmd:proton8`
- [`SteamCMD Ubuntu latest LTS`](/steamcmd/ubuntu)
  - `ghcr.io/aleforge/steamcmd:ubuntu`

### [SteamRT3](/RT3)

- [`Steam Runtime 3 Latest`](/rt3/latest)
  - `ghcr.io/aleforge/steamrt3:latest`
- [`Steam Runtime 3 Latest`](/rt3/beta)
  - `ghcr.io/aleforge/steamrt3:beta`

### [Wine](/wine)

- [`Wine`](/wine)
  - `ghcr.io/aleforge/wine:latest`
  - `ghcr.io/aleforge/wine:devel`
  - `ghcr.io/aleforge/wine:staging`
  - `ghcr.io/aleforge/wine:7`
  - `ghcr.io/aleforge/wine:8`
  - `ghcr.io/aleforge/wine:9`
  - `ghcr.io/aleforge/wine:10`

## Sponsor :

[![AleForge](https://github.com/aleforge/Containers/blob/7b152c2d6b0bbbdaa759778d3f398a5d9dffc237/images/aleforge-logo-dark.jpg)](https://aleforge.net)

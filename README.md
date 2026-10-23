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
- [`dotnet10.0`](/dotnet/10)
  - `ghcr.io/aleforge/dotnet:10`

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
- [`Hytale`](/games/hytale)
  - `ghcr.io/aleforge/games:hytale`
- [`Palworld`](/games/palworld)
  - `ghcr.io/aleforge/games:palworld`

## [Installers](/installers)

- [`Debian`](/installers/debian)
  - `ghcr.io/aleforge/installer:debian`

### [Java](/Java)

`java-*` tags stay Eclipse Temurin. Other vendors have their own tags. Every Java image is Debian glibc, and each build removes the eMudhra roots tied to CVE-2026-91403 from that JDK's truststore.

Current images are Java 8, 11, 17, 21, and 25. Older tags stay published and are frozen on their last vendor build.

#### [Temurin](/Java/Temurin)

Rebuilt from the Adoptium floating tags:

* [`java-8`](/Java/temurin/8) — `ghcr.io/aleforge/containers:java-8` (`eclipse-temurin:8-jdk-jammy`)
* [`java-11`](/Java/temurin/11) — `ghcr.io/aleforge/containers:java-11` (`eclipse-temurin:11-jdk-jammy`)
* [`java-17`](/Java/temurin/17) — `ghcr.io/aleforge/containers:java-17`
* [`java-21`](/Java/temurin/21) — `ghcr.io/aleforge/containers:java-21`
* [`java-25`](/Java/temurin/25) — `ghcr.io/aleforge/containers:java-25`

Frozen. These releases are out of support:

* [`java-16`](/Java/temurin/16) — `ghcr.io/aleforge/containers:java-16`
* [`java-19`](/Java/temurin/19) — `ghcr.io/aleforge/containers:java-19`
* [`java-22`](/Java/temurin/22) — `ghcr.io/aleforge/containers:java-22`
* [`java-23`](/Java/temurin/23) — `ghcr.io/aleforge/containers:java-23`
* [`java-24`](/Java/temurin/24) — `ghcr.io/aleforge/containers:java-24`

#### [Semeru](/Java/OpenJDK)

`ibm-semeru-runtimes:open-<version>-jdk`:

* [`java-8j9`](/Java/OpenJDK/8j9) — `ghcr.io/aleforge/containers:java-8j9`
* [`java-11j9`](/Java/OpenJDK/11j9) — `ghcr.io/aleforge/containers:java-11j9`
* [`java-17j9`](/Java/OpenJDK/17j9) — `ghcr.io/aleforge/containers:java-17j9`
* [`java-21j9`](/Java/OpenJDK/21j9) — `ghcr.io/aleforge/containers:java-21j9`
* [`java-25j9`](/Java/OpenJDK/25j9) — `ghcr.io/aleforge/containers:java-25j9`

Frozen: [`java-16j9`](/Java/OpenJDK/16j9), [`java-18j9`](/Java/OpenJDK/18j9), [`java-19j9`](/Java/OpenJDK/19j9), [`java-22j9`](/Java/OpenJDK/22j9), [`java-23j9`](/Java/OpenJDK/23j9).

#### [GraalVM](/Java/GraalVM)

Community:

* [`graalvm-jdk11`](/Java/GraalVM/jdk11) — `ghcr.io/aleforge/containers:graalvm-jdk11` (22.3.3, last community CPU)
* [`graalvm-jdk17`](/Java/GraalVM/jdk17) — `ghcr.io/aleforge/containers:graalvm-jdk17` (17.0.9, last community CPU)
* [`graalvm-jdk21`](/Java/GraalVM/jdk21) — `ghcr.io/aleforge/containers:graalvm-jdk21` (21.0.2, last community CPU)
* [`graalvm-jdk25`](/Java/GraalVM/jdk25) — `ghcr.io/aleforge/containers:graalvm-jdk25` (Community 25 Innovation 4, JDK 25.0.4.1.1)

Frozen community tags, with no newer community CPU: [`graalvm-jdk20`](/Java/GraalVM/jdk20), [`graalvm-jdk22`](/Java/GraalVM/jdk22), [`graalvm-jdk23`](/Java/GraalVM/jdk23), [`graalvm-jdk24`](/Java/GraalVM/jdk24).

Oracle public `latest` URLs, so a weekly rebuild follows Oracle:

* [`graalvm-jdk21-ee`](/Java/GraalVM/jdk21-ee) — `ghcr.io/aleforge/containers:graalvm-jdk21-ee`
* [`graalvm-jdk24-ee`](/Java/GraalVM/jdk24-ee) — `ghcr.io/aleforge/containers:graalvm-jdk24-ee` (JDK 24 is out of support and will not gain the eMudhra fix)
* [`graalvm-jdk25-ee`](/Java/GraalVM/jdk25-ee) — `ghcr.io/aleforge/containers:graalvm-jdk25-ee`

Frozen until an Oracle download token is available. These stay on the existing Backblaze archives (Enterprise 21.3.8 for JDK 8, 22.3.4 for JDK 11 and 17):

* [`graalvm-jdk8-ee`](/Java/GraalVM/jdk8-ee) — `ghcr.io/aleforge/containers:graalvm-jdk8-ee`
* [`graalvm-jdk11-ee`](/Java/GraalVM/jdk11-ee) — `ghcr.io/aleforge/containers:graalvm-jdk11-ee`
* [`graalvm-jdk17-ee`](/Java/GraalVM/jdk17-ee) — `ghcr.io/aleforge/containers:graalvm-jdk17-ee`

#### [Amazon Corretto](/Java/corretto)

* [`corretto-8`](/Java/corretto) — `ghcr.io/aleforge/containers:corretto-8`
* [`corretto-11`](/Java/corretto) — `ghcr.io/aleforge/containers:corretto-11`
* [`corretto-17`](/Java/corretto) — `ghcr.io/aleforge/containers:corretto-17`
* [`corretto-21`](/Java/corretto) — `ghcr.io/aleforge/containers:corretto-21`
* [`corretto-25`](/Java/corretto) — `ghcr.io/aleforge/containers:corretto-25`

#### [Azul Zulu](/Java/zulu)

JDK and JRE tags for 8, 11, 17, 21, and 25:

* `ghcr.io/aleforge/containers:zulu-8` and `ghcr.io/aleforge/containers:zulu-8-jre`
* `ghcr.io/aleforge/containers:zulu-11` and `ghcr.io/aleforge/containers:zulu-11-jre`
* `ghcr.io/aleforge/containers:zulu-17` and `ghcr.io/aleforge/containers:zulu-17-jre`
* `ghcr.io/aleforge/containers:zulu-21` and `ghcr.io/aleforge/containers:zulu-21-jre`
* `ghcr.io/aleforge/containers:zulu-25` and `ghcr.io/aleforge/containers:zulu-25-jre`

#### [Liberica](/Java/liberica)

* [`liberica-8`](/Java/liberica) — `ghcr.io/aleforge/containers:liberica-8`
* [`liberica-11`](/Java/liberica) — `ghcr.io/aleforge/containers:liberica-11`
* [`liberica-17`](/Java/liberica) — `ghcr.io/aleforge/containers:liberica-17`
* [`liberica-21`](/Java/liberica) — `ghcr.io/aleforge/containers:liberica-21`
* [`liberica-25`](/Java/liberica) — `ghcr.io/aleforge/containers:liberica-25`

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

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

### [Java](/java)

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
  - `ghcr.io/aleforge/wine:8`

## Sponsor :

[![AleForge](https://github.com/aleforge/Containers/blob/7b152c2d6b0bbbdaa759778d3f398a5d9dffc237/images/aleforge-logo-dark.jpg)](https://aleforge.net)

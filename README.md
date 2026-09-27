# Mikael Launcher V3

Launcher Android para Minecraft: Java Edition, com foco em desempenho em dispositivos móveis.

## Arquitetura

O projeto usa a base open-source Amethyst-Android/PojavLauncher para fornecer:
- runtime Java móvel (OpenJDK 8/17/21)
- LWJGL e camada gráfica para Android
- OpenGL/OpenAL
- controles de toque
- suporte a Forge/Fabric
- suporte a versões modernas do Minecraft

O código-fonte upstream é baixado durante o build pelo GitHub Actions para manter o repositório leve.

## Build

Abra a aba **Actions** e execute **Build Mikael Launcher APK**. O APK será publicado como artifact.

Também é possível gerar localmente:

```bash
git clone https://github.com/mikael8367/Mikael-launcher-V3.git
cd Mikael-launcher-V3
```

## Desempenho

O objetivo do projeto é oferecer uma configuração de alto desempenho, mas o FPS real depende do SoC/GPU, versão do Minecraft, renderizador, distância de renderização, mods e temperatura do aparelho.

O launcher não inclui Minecraft nem contorna autenticação/licença. O usuário precisa possuir Minecraft: Java Edition.

## Licenças

Este projeto utiliza componentes open-source de terceiros. Consulte as licenças do upstream e das dependências antes de redistribuir builds modificadas.

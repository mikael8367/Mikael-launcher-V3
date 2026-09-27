# Mikael Launcher — Performance

O projeto prioriza desempenho sem prometer um FPS fixo.

## Princípios

1. Usar o runtime Java adequado à versão do Minecraft.
2. Preferir renderizadores móveis compatíveis com o hardware.
3. Evitar memória Java excessiva em aparelhos com pouca RAM.
4. Reduzir distância de renderização e simulação quando a GPU/CPU estiver no limite.
5. Evitar shaders pesados e modpacks grandes quando a meta for FPS alto.
6. Monitorar temperatura: throttling térmico pode reduzir o FPS depois de alguns minutos.

## Próximas otimizações

- perfil automático por SoC/GPU;
- presets Baixo/Equilibrado/Alto;
- seleção inteligente de renderer;
- ajustes de memória;
- overlay opcional de FPS/frametime;
- testes de regressão de desempenho por versão do Minecraft.

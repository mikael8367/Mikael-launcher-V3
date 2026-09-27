# Mikael Launcher — Contas

O launcher deve oferecer três modos de perfil:

## Microsoft
Login oficial Microsoft/Xbox/Minecraft, usando o fluxo OAuth suportado pelo launcher upstream. Não armazenar senha da Microsoft no aplicativo.

## Ely.by
Login Ely.by usando o fluxo/API oficial do provedor. Não armazenar senha diretamente no Mikael Launcher.

## Offline
Perfil local/offline para uso em ambientes onde o servidor permite autenticação offline. Este modo não autentica uma conta Minecraft oficial e não deve ser usado para falsificar uma identidade online.

A implementação de autenticação deve permanecer compatível com os termos e APIs dos provedores.

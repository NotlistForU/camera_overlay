<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# camera_overlay 📷🧩

Um pacote Flutter para captura de fotos utilizando a câmera do dispositivo com **overlay customizável** sobre o preview, ideal para aplicações que precisam de enquadramento guiado, marcações visuais ou validação visual antes da captura.

---

## ✨ Funcionalidades

- Preview de câmera usando o plugin oficial `camera`
- Suporte a **overlay customizado** (widgets sobre a câmera)
- Captura de imagem respeitando o overlay exibido
- Estrutura desacoplada para fácil reutilização em outros projetos
- Compatível com Android e iOS

---

## 📦 Instalação

Adicione no seu `pubspec.yaml`:

```yaml
dependencies:
  camera_overlay:
    git:
      url: https://github.com/NotlistForU/camera_overlay.git
      ref: main
````
## Exemplo
| Parâmetro            | Tipo       | Descrição                               |
| -------------------- | ---------- | --------------------------------------- |
| `temBotaoGaleria`    | `bool`     | Exibe botão para abrir a galeria        |
| `temBotaoGoogleMaps` | `bool`     | Exibe botão para abrir o Google Maps    |
| `temMiniMapa`        | `bool`     | Exibe mini mapa no overlay              |
| `onFotoFinal`        | `Function` | Callback chamado após a captura da foto |

````
builder: (_) => CameraOverlay(
                  temBotaoGaleria: false,
                  temBotaoGoogleMaps: false,
                  temMiniMapa: false,
                  onFotoFinal: (bytes, localizacao) async {
                    // bytes -> imagem capturada
                    // localizacao -> dados de localização (se disponível)

                    if (bytes == null) return;

                    // Exemplo: salvar imagem localmente,
                    // enviar para API ou processar os bytes
                  },
                ),
onFotoFinal: (Uint8List? bytes, dynamic localizacao) async {
  if (bytes == null) return;

  // bytes: imagem capturada pela câmera
  // localizacao: informações de localização associadas à captura (se habilitado)

  // Exemplo de uso:
  // - salvar arquivo
  // - enviar para backend
  // - processar imagem
}

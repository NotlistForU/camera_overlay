# camera_overlay 📷🧩

Um pacote Flutter para captura de fotos utilizando a câmera do dispositivo, com informações de localização, observações e recursos visuais sobre o preview.

Ideal para aplicações que precisam de registro fotográfico com informações geográficas e enquadramento guiado.

## ✨ Funcionalidades

- Preview de câmera utilizando o plugin oficial `camera`.
- Captura de imagens com informações de localização (GPS).
- Inclusão de observações na imagem capturada.
- Correção da rotação da imagem conforme a orientação do dispositivo.
- Mini mapa interativo com localização atual.
- Atalho para abrir a localização no Google Maps.
- Acesso à galeria do dispositivo.
- Personalização dos recursos disponíveis na interface.

## 📦 Instalação

Adicione a dependência ao seu `pubspec.yaml`:

```yaml
dependencies:
  camera_overlay: ^0.0.2
```

Execute:

```bash
flutter pub get
```

## 🚀 Utilização

Importe o pacote:

```dart
import 'package:camera_overlay/camera_overlay.dart';
```

Utilize o widget `CameraOverlay`:

```dart
CameraOverlay(
  temBotaoGaleria: false,
  temBotaoGoogleMaps: true,
  temMiniMapa: true,

  onFotoFinal: (bytes, localizacao, observacoes) async {
    // bytes: imagem capturada (Uint8List)
    // localizacao: informações de localização (Localizacao?)
    // observacoes: texto informado pelo usuário (String?)

    // Exemplo:
    // Salvar a imagem localmente,
    // enviar para uma API ou processar os dados.
  },
)
```

## ⚙️ Parâmetros

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `titulo` | `String` | Título exibido na câmera. |
| `temBotaoGaleria` | `bool` | Exibe o botão para abrir a galeria. |
| `temBotaoGoogleMaps` | `bool` | Exibe o botão para abrir o Google Maps. |
| `temMiniMapa` | `bool` | Habilita o mini mapa. |
| `onFotoFinal` | `Function` | Callback executado após a captura e processamento da foto. |
| `onAbrirGaleria` | `VoidCallback?` | Callback para abertura da galeria. |
| `onMiniMapaChanged` | `Function(bool)?` | Notifica alterações na exibição do mini mapa. |
| `anguloRotacaoDireita` | `int` | Ângulo de correção da foto quando o dispositivo gira para a direita. |
| `anguloRotacaoEsquerda` | `int` | Ângulo de correção da foto quando o dispositivo gira para a esquerda. |
| `configsExtras` | `List<Widget>?` | Widgets adicionais exibidos nas configurações. |

### Callback `onFotoFinal`

O callback recebe três parâmetros:

- `bytes`: imagem final processada, em formato `Uint8List`.
- `localizacao`: objeto `Localizacao?`, contendo latitude, longitude, altitude e data.
- `observacoes`: observações informadas durante a captura, quando disponíveis.

## 📷 Exemplo visual

Mini mapa interativo, que permite movimentação e zoom. Ao pressionar e segurar o mini mapa, sua posição é redefinida para a localização atual.

![Exemplo de uso do Camera Overlay](exemploFoto.png)

## 📄 Licença

Este projeto está licenciado sob a licença MIT.

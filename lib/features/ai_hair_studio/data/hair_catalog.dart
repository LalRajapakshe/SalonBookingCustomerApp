import '../models/hair_style_option.dart';

class HairCatalog {
  HairCatalog._();

  static const styles = <HairStyleOption>[
    HairStyleOption(
      id: 'long-layers',
      name: 'Long layers',
      summary: 'Soft layers that frame the face.',
      instruction: 'long layered hair with soft face-framing layers',
      assetPath: 'assets/images/hair_studio/long_layers.jpg',
    ),
    HairStyleOption(
      id: 'bob-cut',
      name: 'Bob cut',
      summary: 'A rounded bob that ends at the chin.',
      instruction: 'a chin-length bob with a rounded edge',
      assetPath: 'assets/images/hair_studio/bob_cut.jpg',
    ),
    HairStyleOption(
      id: 'short-pixie',
      name: 'Short pixie',
      summary: 'A cropped pixie with a textured top.',
      instruction: 'a short pixie cut, cropped at the nape with a textured top',
      assetPath: 'assets/images/hair_studio/short_pixie.jpg',
    ),
    HairStyleOption(
      id: 'curtain-bangs',
      name: 'Curtain bangs',
      summary: 'A centre part that opens around the face.',
      instruction: 'curtain bangs parted in the centre and blended into the length',
      assetPath: 'assets/images/hair_studio/curtain_bangs.jpg',
    ),
    HairStyleOption(
      id: 'shoulder-waves',
      name: 'Shoulder-length waves',
      summary: 'Loose waves that sit at the shoulders.',
      instruction: 'shoulder-length loose waves',
      assetPath: 'assets/images/hair_studio/shoulder_waves.jpg',
    ),
    HairStyleOption(
      id: 'straight-long',
      name: 'Straight long hair',
      summary: 'Sleek, straight hair worn long.',
      instruction: 'long straight sleek hair',
      assetPath: 'assets/images/hair_studio/straight_long.jpg',
    ),
    HairStyleOption(
      id: 'curly',
      name: 'Curly styles',
      summary: 'Defined curls with volume.',
      instruction: 'defined curly hair with volume',
      assetPath: 'assets/images/hair_studio/curly.jpg',
    ),
  ];

  static const colors = <HairColorOption>[
    HairColorOption(
      id: 'natural-black',
      name: 'Natural black',
      instruction: 'natural black',
      swatch: 0xFF1A1A1A,
    ),
    HairColorOption(
      id: 'chocolate-brown',
      name: 'Chocolate brown',
      instruction: 'chocolate brown',
      swatch: 0xFF5C3317,
    ),
    HairColorOption(
      id: 'caramel',
      name: 'Caramel',
      instruction: 'caramel',
      swatch: 0xFFC68642,
    ),
    HairColorOption(
      id: 'copper',
      name: 'Copper',
      instruction: 'copper',
      swatch: 0xFFB87333,
    ),
    HairColorOption(
      id: 'burgundy',
      name: 'Burgundy',
      instruction: 'burgundy',
      swatch: 0xFF800020,
    ),
    HairColorOption(
      id: 'blonde',
      name: 'Blonde',
      instruction: 'blonde',
      swatch: 0xFFE6C36A,
    ),
  ];
}

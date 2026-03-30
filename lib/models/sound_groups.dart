// Sound groups definition - based on Blanket's SOUNDS constant
import 'sound.dart';

class SoundGroups {
  static const List<Map<String, dynamic>> groups = [
    {
      'name': 'Nature',
      'sounds': [
        {'name': 'rain', 'title': 'Rain'},
        {'name': 'storm', 'title': 'Storm'},
        {'name': 'wind', 'title': 'Wind'},
        {'name': 'waves', 'title': 'Waves'},
        {'name': 'stream', 'title': 'Stream'},
        {'name': 'birds', 'title': 'Birds'},
        {'name': 'summer-night', 'title': 'Summer Night'},
      ],
    },
    {
      'name': 'Travel',
      'sounds': [
        {'name': 'train', 'title': 'Train'},
        {'name': 'boat', 'title': 'Boat'},
        {'name': 'city', 'title': 'City'},
      ],
    },
    {
      'name': 'Interiors',
      'sounds': [
        {'name': 'coffee-shop', 'title': 'Coffee Shop'},
        {'name': 'fireplace', 'title': 'Fireplace'},
      ],
    },
    {
      'name': 'Noise',
      'sounds': [
        {'name': 'pink-noise', 'title': 'Pink Noise'},
        {'name': 'white-noise', 'title': 'White Noise'},
      ],
    },
  ];

  static List<Sound> createDefaultSounds() {
    final sounds = <Sound>[];
    for (final group in groups) {
      final category = group['name'] as String;
      final soundList = group['sounds'] as List<Map<String, String>>;
      for (final soundDef in soundList) {
        sounds.add(Sound.builtin(
          name: soundDef['name']!,
          title: soundDef['title']!,
          category: category,
        ));
      }
    }
    return sounds;
  }

  static String getCategoryForSound(String soundName) {
    for (final group in groups) {
      final soundList = group['sounds'] as List<Map<String, String>>;
      for (final soundDef in soundList) {
        if (soundDef['name'] == soundName) {
          return group['name'] as String;
        }
      }
    }
    return 'Custom';
  }
}

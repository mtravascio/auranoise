// Preset model for saving sound combinations
class Preset {
  final String id;
  String name;
  final Map<String, double> volumes;
  final Map<String, bool> muted;
  bool hideInactive;

  Preset({
    required this.id,
    required this.name,
    Map<String, double>? volumes,
    Map<String, bool>? muted,
    this.hideInactive = false,
  }) : volumes = volumes ?? {},
       muted = muted ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'volumes': volumes,
      'muted': muted,
      'hideInactive': hideInactive,
    };
  }

  static Preset fromJson(Map<String, dynamic> json) {
    return Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      volumes: Map<String, double>.from(json['volumes'] as Map? ?? {}),
      muted: Map<String, bool>.from(json['muted'] as Map? ?? {}),
      hideInactive: json['hideInactive'] as bool? ?? false,
    );
  }

  Preset copy() {
    return Preset(
      id: id,
      name: name,
      volumes: Map.from(volumes),
      muted: Map.from(muted),
      hideInactive: hideInactive,
    );
  }
}

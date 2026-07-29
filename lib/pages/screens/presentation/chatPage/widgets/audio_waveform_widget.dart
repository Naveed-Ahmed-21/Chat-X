import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioWaveformWidget extends StatefulWidget {
  final AudioPlayer player;

  const AudioWaveformWidget({
    super.key,
    required this.player,
  });

  @override
  State<AudioWaveformWidget> createState() =>
      _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState
    extends State<AudioWaveformWidget> {

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    widget.player.positionStream.listen((p) {
      if (!mounted) return;

      setState(() {
        position = p;
      });
    });

    widget.player.durationStream.listen((d) {
      if (!mounted || d == null) return;

      setState(() {
        duration = d;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    double progress = 0;

    if (duration.inMilliseconds > 0) {
      progress =
          position.inMilliseconds /
              duration.inMilliseconds;
    }

    return AudioFileWaveforms(
      size: const Size(160, 40),

      playerController: PlayerController(),

      waveformType: WaveformType.fitWidth,

      playerWaveStyle: PlayerWaveStyle(
        fixedWaveColor: Colors.grey.shade500,
        liveWaveColor: Colors.blue,
        spacing: 4,
        waveThickness: 3,
      ),
    );
  }
}
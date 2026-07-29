import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final String? localPath;
  final int? initialDurationMs;

  const AudioMessageWidget({
    super.key,
    required this.audioUrl,
    this.localPath,
    this.initialDurationMs,
  });

  @override
  State<AudioMessageWidget> createState() =>
      _AudioMessageWidgetState();
}

class _AudioMessageWidgetState
    extends State<AudioMessageWidget> {

  final AudioPlayer player = AudioPlayer();

  bool initialized = false;
  bool playing = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  double speed = 1.0;
  
  // Simulated waveform data
  late List<double> waveData;

  @override
  void initState() {
    super.initState();
    
    // Generate random-looking but deterministic wave data based on URL hash if possible
    final seed = widget.audioUrl.isNotEmpty ? widget.audioUrl.hashCode : 42;
    final random = Random(seed);
    waveData = List.generate(30, (index) => 0.2 + random.nextDouble() * 0.8);

    if (widget.initialDurationMs != null) {
      duration = Duration(milliseconds: widget.initialDurationMs!);
    }

    player.durationStream.listen((d) {
      if (d != null) {
        if (!mounted) return;
        setState(() {
          duration = d;
        });
      }
    });

    player.positionStream.listen((p) {
      if (!mounted) return;
      setState(() {
        position = p;
      });
    });

    player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await player.pause();
        await player.seek(Duration.zero);
        if (!mounted) return;
        setState(() {
          playing = false;
          position = Duration.zero;
        });
      }
    });
  }

  Future<void> playPause() async {

    if (!initialized) {
      if (widget.localPath != null && widget.localPath!.isNotEmpty && File(widget.localPath!).existsSync()) {
        await player.setFilePath(widget.localPath!);
      } else if (widget.audioUrl.isNotEmpty) {
        await player.setUrl(widget.audioUrl);
      } else {
        return;
      }
      initialized = true;
    }

    if (playing) {
      await player.pause();
    } else {
      await player.play();
    }

    if (!mounted) return;
    setState(() {
      playing = !playing;
    });
  }

  String format(Duration d) {

    String two(int n) =>
        n.toString().padLeft(2, "0");

    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          InkWell(
            onTap: playPause,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                playing
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final localPos = box.globalToLocal(details.globalPosition);
                    // Adjust for leading elements (circle avatar + spacing = 18*2 + 12 = 48)
                    // Container padding = 10
                    final relativeX = (localPos.dx - 58).clamp(0, 140); 
                    final percent = relativeX / 140;
                    if (duration.inMilliseconds > 0) {
                      player.seek(Duration(milliseconds: (duration.inMilliseconds * percent).toInt()));
                    }
                  },
                  child: SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        waveData.length,
                        (index) {
                          final progress = duration.inMilliseconds == 0
                              ? 0.0
                              : position.inMilliseconds /
                              duration.inMilliseconds;

                          final activeBars = (progress * waveData.length).floor();
                          final isActive = index <= activeBars;

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              alignment: Alignment.center,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: 2.5,
                                height: 10 + (waveData[index] * 20),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      format(position),
                      style:
                      const TextStyle(fontSize: 10, color: Colors.grey),
                    ),

                    Text(
                      format(duration),
                      style:
                      const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),

          PopupMenuButton<double>(
            initialValue: speed,
            onSelected: (v) async {
              speed = v;
              await player.setSpeed(v);
              if (!mounted) return;
              setState(() {});
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 1,
                child: Text("1x"),
              ),
              PopupMenuItem(
                value: 1.5,
                child: Text("1.5x"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("2x"),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "${speed.toStringAsFixed(1)}x",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

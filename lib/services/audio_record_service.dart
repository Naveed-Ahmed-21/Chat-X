import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<String?> startRecording() async {
    if (!await hasPermission()) {
      throw Exception("Microphone permission denied");
    }

    final dir = await getTemporaryDirectory();

    final path = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a";

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    return path;
  }

  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

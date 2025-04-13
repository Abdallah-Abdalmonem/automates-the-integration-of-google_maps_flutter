import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tool_outomate/bloc/map_bloc.dart';
import 'package:tool_outomate/bloc/map_event.dart';
import 'package:tool_outomate/bloc/map_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Maps Integration Tool')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () =>
                  context.read<MapBloc>().add(SelectMapDirectory()),
              child: const Text('📁 اختر مجلد مشروع Flutter'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () =>
                  context.read<MapBloc>().add(IntegrateGoogleMaps()),
              child: const Text('➕ دمج google_maps_flutter تلقائيًا'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final controller = TextEditingController();
                final key = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('🔑 أدخل Google Maps API Key'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'API Key'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('تخطي'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(ctx, controller.text.trim()),
                        child: const Text('حفظ'),
                      ),
                    ],
                  ),
                );

                if (key != null && key.isNotEmpty) {
                  context.read<MapBloc>().add(ConfigureApiKey(key));
                }
              },
              child: const Text('⚙️ إعداد Google Maps API Key'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/map'),
              child: const Text('🗺️ عرض مثال لخريطة Google'),
            ),
            const SizedBox(height: 20),
            BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                if (state is MapInitial) {
                  return const Text('يرجى اختيار مجلد المشروع.');
                } else if (state is MapLoaded) {
                  return Text('📂 تم اختيار المشروع: ${state.path}');
                } else if (state is MapIntegrated) {
                  return Text('✅ تم دمج google_maps_flutter في: ${state.path}');
                } else if (state is MapConfigured) {
                  return Text(
                      '🔑 تم إعداد الـ API Key بنجاح في: ${state.path}');
                } else if (state is MapError) {
                  return Text('❌ ${state.message}',
                      style: const TextStyle(color: Colors.red));
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

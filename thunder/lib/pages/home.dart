import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool goToHome;
  late Future<ListResult> images;

  @override
  void initState() {
    super.initState();
    images = FirebaseStorage.instance.ref("/").listAll();
    goToHome = false;
  }

  Future<void> setWallpaperHome(Reference ref) async {
    final url = await ref.getDownloadURL();
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${ref.name}';
    await Dio().download(url, path);
    try {
      await AsyncWallpaper.setWallpaperFromFile(
        filePath: path,
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
        goToHome: goToHome,
      )
          ? 'Wallpaper set'
          : 'Failed to get wallpaper.';
    } on PlatformException {
      'Failed to get wallpaper.';
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Thunder"),
        centerTitle: true,
      ),
      body: FutureBuilder<ListResult>(
        future: images,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final imagesData = snapshot.data!.items;
            return ListView.builder(
              itemCount: imagesData.length,
              itemBuilder: (context, index) {
                final image = imagesData[index];
                return GestureDetector(
                  onTap: () {
                    setWallpaperHome(image);
                  },
                  child: ListTile(
                    title: Text(image.name),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

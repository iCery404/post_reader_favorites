# Post Reader & Favorites

A cozy Flutter app that fetches posts from a MockAPI endpoint, lets you
open a post, create a new one (POST), and save favorites locally with Hive.

The look is a full-screen "Cozy Cup" design: caramel title bar with three
dots (this is the real `AppBar`), cream dotted paper, a sage table header,
flat edge-to-edge rows and raised buttons. Fonts come from `google_fonts`
(Lora for headings, Nunito for text); they download on first run, so the
first launch needs internet (it falls back to the default font if offline).

## API

Posts come from a MockAPI project with a `posts` resource (fields `title`, `body` and `userId`).
The link is the `_postsUrl` constant in `lib/screens/posts_screen.dart`. To use the lab's
original API again, change it to `https://jsonplaceholder.typicode.com/posts`.
MockAPI sends ids as text, so `Post.fromJson` turns them into numbers.

## Animations and design touches

| Where | What it does |
| --- | --- |
| `CozyButton` | Lifts a little on hover, sinks down on press as the shadow shrinks, icon and label swap with a pop |
| `CozyFab` | Bounces in when the screen opens, same hover and press effect as the buttons |
| `CozyIconButton` | Grows on hover, shrinks on press. The heart in the Posts AppBar shows a badge with the number of saved favorites |
| Posts list | Rows fade and slide in one after another, a pulsing skeleton shows while posts load |
| Details screen | Post shown on a raised paper card, the buttons slide in one by one, the heart pops when you save |
| Favorites list | Rows slide in, the bin collapses the row smoothly, a new note expands with a size animation |
| Banners and dialogs | Messages slide down and the list below moves smoothly, dialogs pop in with a small bounce |
| Screen changes | Fade and slide up transition set in `ThemeData` |

## Run it in Visual Studio Code

1. Install the **Flutter** and **Dart** extensions in VS Code (and the Flutter SDK).
2. Open the folder that directly contains `pubspec.yaml` in VS Code
   (File > Open Folder). Do not open the parent folder.
3. In the VS Code terminal, generate the platform folders (android/ios/web...).
   This only adds missing files; it will not overwrite `lib/` or `pubspec.yaml`:

   ```bash
   flutter create .
   ```

4. Install the packages:

   ```bash
   flutter pub get
   ```

5. Android release builds need internet permission. Open
   `android/app/src/main/AndroidManifest.xml` and add this line inside
   `<manifest>` (above `<application>`) if it is not there yet:

   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

6. Open `lib/main.dart`, pick a device (Ctrl+Shift+P > "Flutter: Select Device"),
   then press **F5**, or run:

   ```bash
   flutter run -d chrome --web-port 5000
   ```

   (A fixed web port keeps your saved favorites between runs in Chrome.)

## Project structure

```
lib/
  main.dart                      Hive init + MaterialApp named routes
  theme/app_theme.dart           ThemeData + Cozy Cup colour palette + fonts + page transition
  models/post.dart               Post model
  services/favorites_service.dart  Hive CRUD (create / read / update / delete)
  screens/
    posts_screen.dart            '/'          GET + POST with http
    post_details_screen.dart     '/details'   route arguments + save
    favorites_screen.dart        '/favorites' read / update note / delete
  widgets/
    cozy_widgets.dart            window, animated buttons, banner, skeleton, placeholder
    new_post_dialog.dart         title + body dialog with validation
```

## Requirement checklist

| Requirement | Where |
| --- | --- |
| Named routes `/`, `/details`, `/favorites` with `initialRoute` | `main.dart` |
| `Navigator.pushNamed()` / `Navigator.pop()` | `posts_screen.dart`, `post_details_screen.dart`, `cozy_widgets.dart` (back arrow) |
| AppBar button on Posts screen opens Favorites | `posts_screen.dart` (heart icon in the AppBar) |
| id, title, body passed as arguments, read with `ModalRoute.of(context)!.settings.arguments` | `posts_screen.dart` -> `post_details_screen.dart` |
| `http` package, `http.get(Uri.parse(...))` in an async method called from `initState()` | `posts_screen.dart` (`_loadPosts`) |
| `statusCode == 200` -> `jsonDecode` -> `ListView.builder` + `ListTile` | `posts_screen.dart` |
| Failed request shows an error message on screen | `posts_screen.dart` (`CozyPlaceholder`) |
| FAB opens dialog with title/body (neither empty), `http.post()` + `jsonEncode()`, 201 = success message, otherwise failure message | `posts_screen.dart`, `new_post_dialog.dart` |
| `WidgetsFlutterBinding.ensureInitialized()`, `Hive.initFlutter()`, open `'favoritesBox'` before `runApp()` | `main.dart` |
| Save to Favorites: Map stored with `put()`, post id as key (no duplicates) | `favorites_service.dart`, `post_details_screen.dart` |
| Read with `box.values` | `favorites_service.dart` (`readAll`) |
| Update personal note and save back to the box | `favorites_screen.dart`, `favorites_service.dart` |
| Delete with `delete()` (bin icon or swipe) | `favorites_screen.dart`, `favorites_service.dart` |
| Favorites persist after closing the app | Hive box on disk |
| Consistent `ThemeData`, clear AppBar titles, spacing | `theme/app_theme.dart` |
| Separate widget/class per screen | `screens/` |
| All results, messages and errors shown on screen | `StatusBanner`, `CozyPlaceholder` |

## Live page

https://icery404.github.io/post_reader_favorites/

Deployed automatically to GitHub Pages by `.github/workflows/deploy.yml` on every push to `main`.

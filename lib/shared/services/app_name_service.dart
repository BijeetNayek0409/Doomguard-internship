/// Maps known Android package names to friendly display names.
class AppNameService {
  static const Map<String, String> _knownApps = {
    // Google
    'com.google.android.googlequicksearchbox': 'Google',
    'com.google.android.quicksearchbox': 'Google Search',
    'com.google.android.gm': 'Gmail',
    'com.google.android.apps.maps': 'Google Maps',
    'com.google.android.youtube': 'YouTube',
    'com.google.android.apps.youtube.music': 'YouTube Music',
    'com.google.android.calendar': 'Google Calendar',
    'com.google.android.keep': 'Google Keep',
    'com.google.android.apps.photos': 'Google Photos',
    'com.google.android.apps.docs': 'Google Docs',
    'com.google.android.apps.sheets': 'Google Sheets',
    'com.google.android.apps.slides': 'Google Slides',
    'com.google.android.apps.drive': 'Google Drive',
    'com.google.android.apps.translate': 'Google Translate',
    'com.google.android.talk': 'Google Chat',
    'com.google.android.apps.messaging': 'Messages',
    'com.google.android.dialer': 'Phone',
    'com.google.android.contacts': 'Contacts',
    'com.google.android.calculator': 'Calculator',
    'com.google.android.apps.wallpaper': 'Wallpaper',
    'com.google.android.videos': 'Google TV',
    'com.google.android.play.games': 'Google Play Games',
    'com.google.android.music': 'Google Play Music',
    'com.google.android.apps.books': 'Google Play Books',
    'com.google.android.apps.magazines': 'Google Play Newsstand',
    'com.google.android.apps.fitness': 'Google Fit',
    'com.google.android.apps.tachyon': 'Google Meet',
    'com.google.android.apps.chromecast.app': 'Google Home',
    'com.google.android.apps.nexuslauncher': 'Pixel Launcher',
    'com.google.android.launcher': 'Google Launcher',
    'com.google.android.setupwizard': 'Setup Wizard',
    // Social
    'com.instagram.android': 'Instagram',
    'com.facebook.katana': 'Facebook',
    'com.facebook.lite': 'Facebook Lite',
    'com.facebook.orca': 'Messenger',
    'com.twitter.android': 'Twitter / X',
    'com.twitter.android.lite': 'Twitter Lite',
    'com.x.android': 'X',
    'com.snapchat.android': 'Snapchat',
    'com.whatsapp': 'WhatsApp',
    'com.whatsapp.w4b': 'WhatsApp Business',
    'org.telegram.messenger': 'Telegram',
    'com.reddit.frontpage': 'Reddit',
    'com.pinterest': 'Pinterest',
    'com.linkedin.android': 'LinkedIn',
    'com.tumblr': 'Tumblr',
    'com.discord': 'Discord',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.ss.android.ugc.trill': 'TikTok',
    'com.clubhouse.app': 'Clubhouse',
    'com.bereal.app': 'BeReal',
    'com.kik.android': 'Kik',
    'com.viber.voip': 'Viber',
    'com.skype.raider': 'Skype',
    // Browsers
    'com.android.chrome': 'Chrome',
    'org.mozilla.firefox': 'Firefox',
    'com.opera.browser': 'Opera',
    'com.microsoft.emmx': 'Microsoft Edge',
    'com.brave.browser': 'Brave Browser',
    'com.sec.android.app.sbrowser': 'Samsung Internet',
    'com.UCMobile.intl': 'UC Browser',
    // Entertainment
    'com.netflix.mediaclient': 'Netflix',
    'com.spotify.music': 'Spotify',
    'com.amazon.avod.thirdpartyclient': 'Prime Video',
    'com.disney.disneyplus': 'Disney+',
    'com.hotstar.android': 'Hotstar',
    'com.jio.media.jiocinema': 'JioCinema',
    'com.sonyliv': 'SonyLIV',
    'in.startv.hotstar': 'Hotstar',
    'tv.twitch.android.app': 'Twitch',
    'com.voot.ui': 'Voot',
    'com.mxtech.videoplayer.ad': 'MX Player',
    // Games
    'com.garena.game.freefire': 'Free Fire',
    'com.pubg.imobile': 'PUBG Mobile',
    'com.miHoYo.GenshinImpact': 'Genshin Impact',
    'com.mojang.minecraftpe': 'Minecraft',
    'com.supercell.clashofclans': 'Clash of Clans',
    'com.supercell.clashroyale': 'Clash Royale',
    'com.king.candycrushsaga': 'Candy Crush',
    'com.roblox.client': 'Roblox',
    // Shopping
    'com.amazon.mShoppingApp': 'Amazon',
    'com.flipkart.android': 'Flipkart',
    'com.myntra.android': 'Myntra',
    // Food & Delivery
    'com.ubercab.eats': 'Uber Eats',
    'app.swiggy.android': 'Swiggy',
    'com.application.zomato': 'Zomato',
    // Finance
    'net.one97.paytm': 'Paytm',
    'com.phonepe.app': 'PhonePe',
    'in.org.npci.upiapp': 'BHIM',
    'com.google.android.apps.nbu.paisa.user': 'Google Pay',
    // Productivity
    'com.microsoft.teams': 'Microsoft Teams',
    'com.microsoft.office.word': 'Microsoft Word',
    'com.microsoft.office.excel': 'Microsoft Excel',
    'com.microsoft.office.powerpoint': 'PowerPoint',
    'com.microsoft.office.outlook': 'Outlook',
    'com.microsoft.launcher': 'Microsoft Launcher',
    'com.slack': 'Slack',
    'com.notion.id': 'Notion',
    'com.todoist.android.Todoist': 'Todoist',
    'com.evernote': 'Evernote',
    // Music
    'com.amazon.mp3': 'Amazon Music',
    'com.gaana': 'Gaana',
    'com.wynk.music': 'Wynk Music',
    'com.jiosaavn.jiosaavn': 'JioSaavn',
    // Navigation
    'com.mapbox.navigation': 'Mapbox',
    'com.Ola.customer': 'Ola',
    'com.ubercab': 'Uber',
    'com.rapido.passenger': 'Rapido',
    // System
    'com.android.settings': 'Settings',
    'com.android.vending': 'Google Play Store',
    'com.android.systemui': 'System UI',
    'com.sec.android.app.launcher': 'Samsung Launcher',
    'com.samsung.android.app.contacts': 'Samsung Contacts',
    'com.samsung.android.calendar': 'Samsung Calendar',
    'com.samsung.android.galaxystore': 'Galaxy Store',
    'com.sec.android.gallery3d': 'Samsung Gallery',
    'com.samsung.android.messaging': 'Samsung Messages',
    'com.samsung.android.dialer': 'Samsung Phone',
    'com.android.phone': 'Phone',
    'com.android.mms': 'Messages',
    'com.android.bluetooth': 'Bluetooth',
    'com.android.camera2': 'Camera',
    'com.android.gallery3d': 'Gallery',
    'com.android.externalstorage': 'Files',
    'com.coloros.filemanager': 'File Manager',
  };

  /// Returns a friendly display name for a given package name.
  static String getFriendlyName(String packageName) {
    if (_knownApps.containsKey(packageName)) {
      return _knownApps[packageName]!;
    }
    // Try to derive a reasonable name from the package name itself
    final parts = packageName.split('.');
    if (parts.length >= 2) {
      // Use the last meaningful segment, capitalize it
      String lastPart = parts.last;
      // Remove common suffixes
      for (final suffix in ['android', 'app', 'mobile', 'client', 'ui']) {
        if (lastPart.toLowerCase() == suffix && parts.length > 2) {
          lastPart = parts[parts.length - 2];
          break;
        }
      }
      return _capitalize(lastPart);
    }
    return packageName;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    // Convert camelCase / snake_case to Title Case
    final words = s.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m[0]}',
    ).split(RegExp(r'[_\s\.]+'));
    return words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  /// Returns the icon data best matching the package name.
  static ({String emoji, int colorHex}) getAppMeta(String packageName) {
    final name = packageName.toLowerCase();
    if (name.contains('instagram')) return (emoji: '📷', colorHex: 0xFFE1306C);
    if (name.contains('youtube')) return (emoji: '▶️', colorHex: 0xFFFF0000);
    if (name.contains('twitter') || name.contains('.x.')) return (emoji: '🐦', colorHex: 0xFF1DA1F2);
    if (name.contains('facebook')) return (emoji: '📘', colorHex: 0xFF1877F2);
    if (name.contains('snapchat')) return (emoji: '👻', colorHex: 0xFFFFFC00);
    if (name.contains('whatsapp')) return (emoji: '💬', colorHex: 0xFF25D366);
    if (name.contains('telegram')) return (emoji: '✈️', colorHex: 0xFF0088CC);
    if (name.contains('reddit')) return (emoji: '🤖', colorHex: 0xFFFF4500);
    if (name.contains('tiktok') || name.contains('musically')) return (emoji: '🎵', colorHex: 0xFF010101);
    if (name.contains('spotify')) return (emoji: '🎵', colorHex: 0xFF1DB954);
    if (name.contains('netflix')) return (emoji: '🎬', colorHex: 0xFFE50914);
    if (name.contains('discord')) return (emoji: '🎮', colorHex: 0xFF5865F2);
    if (name.contains('chrome')) return (emoji: '🌐', colorHex: 0xFF4285F4);
    if (name.contains('gmail') || name.contains('mail')) return (emoji: '📧', colorHex: 0xFFEA4335);
    if (name.contains('maps')) return (emoji: '🗺️', colorHex: 0xFF4285F4);
    if (name.contains('amazon')) return (emoji: '🛒', colorHex: 0xFFFF9900);
    if (name.contains('swiggy') || name.contains('zomato') || name.contains('ubereats')) return (emoji: '🍕', colorHex: 0xFFFC8019);
    if (name.contains('game') || name.contains('pubg') || name.contains('freefire') || name.contains('roblox')) return (emoji: '🎮', colorHex: 0xFF9C4EFF);
    if (name.contains('teams') || name.contains('slack') || name.contains('zoom')) return (emoji: '💼', colorHex: 0xFF6264A7);
    if (name.contains('notion') || name.contains('docs') || name.contains('sheets')) return (emoji: '📝', colorHex: 0xFF7C6EF5);
    if (name.contains('hotstar') || name.contains('jiocinema') || name.contains('sonyliv')) return (emoji: '📺', colorHex: 0xFF0068FF);
    if (name.contains('google')) return (emoji: '🔍', colorHex: 0xFF4285F4);
    if (name.contains('settings') || name.contains('systemui')) return (emoji: '⚙️', colorHex: 0xFF8A8A8A);
    if (name.contains('camera') || name.contains('gallery')) return (emoji: '📸', colorHex: 0xFF00D9B5);
    if (name.contains('phone') || name.contains('dialer')) return (emoji: '📞', colorHex: 0xFF3DDC84);
    if (name.contains('contact')) return (emoji: '👤', colorHex: 0xFF3DDC84);
    if (name.contains('message') || name.contains('sms') || name.contains('mms')) return (emoji: '💬', colorHex: 0xFF7C6EF5);
    if (name.contains('music') || name.contains('saavn') || name.contains('gaana')) return (emoji: '🎶', colorHex: 0xFFFF5C7A);
    if (name.contains('pay') || name.contains('paytm') || name.contains('phonepe')) return (emoji: '💳', colorHex: 0xFF5F259F);
    // Default
    return (emoji: '📱', colorHex: 0xFF7C6EF5);
  }
}

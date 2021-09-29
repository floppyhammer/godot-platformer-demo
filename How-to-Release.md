# Exporting for Google Play Store.
# Uploading an APK to Google's Play Store requires you to sign using a non-debug keystore # file; such file can be generated like this:
keytool -v -genkey -v -keystore mygame.keystore -alias mygame -keyalg RSA -validity 10000

"""Select inventory by native package; production requires explicit release config."""
from pathlib import Path
import json,re,sys

root=Path(__file__).resolve().parent.parent
app=root/'android/app'
gradle=app/'build.gradle.kts'
text=gradle.read_text(encoding='utf-8')
package=re.search(r'applicationId\s*=\s*"([^"]+)"',text).group(1)
prod='com.mehedi.puzzlemix'; dev=prod+'.dev'
if package not in (prod,dev): raise SystemExit('Unknown Android package')
consent_test='--consent-test' in sys.argv
config_path=root/'config/admob.production.json'
config=json.loads(config_path.read_text(encoding='utf-8')) if config_path.exists() else {}
approved=(config.get('enabled') is True and config.get('package')==prod and
          config.get('audience')=='not-child-directed' and config.get('consentMessagePublished') is True)
if package==prod and not approved: raise SystemExit('Production ads require confirmed audience and consent configuration')
if consent_test and (package!=dev or not approved): raise SystemExit('Consent testing requires approved DEV configuration')
if approved:
    for key in ['bannerId','interstitialId','rewardedId']:
        if not re.fullmatch(r'ca-app-pub-\d{16}/\d{10}',config[key]): raise SystemExit('Invalid '+key)
    if not re.fullmatch(r'ca-app-pub-\d{16}~\d{10}',config['appId']): raise SystemExit('Invalid App ID')
    publishers={config[k].split('/')[0] for k in ['bannerId','interstitialId','rewardedId']}
    if len(publishers)!=1 or next(iter(publishers))!=config['appId'].split('~')[0]: raise SystemExit('Mismatched publisher IDs')
    if '3940256099942544' in config['appId']: raise SystemExit('Production App ID is a sample')
app_id=config['appId'] if package==prod or consent_test else 'ca-app-pub-3940256099942544~3347511713'
manifest=app/'src/main/AndroidManifest.xml';m=manifest.read_text(encoding='utf-8')
m=re.sub(r'\s*<meta-data\s+android:name="com.google.android.gms.ads.APPLICATION_ID"\s+android:value="[^"]+"\s*/>','',m)
if 'android.permission.INTERNET' not in m:m=m.replace('<application','<uses-permission android:name="android.permission.INTERNET" />\n    <application',1)
m=re.sub(r'\s*</application>',f'\n        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="{app_id}" />\n    </application>',m,count=1)
manifest.write_text(m,encoding='utf-8')
namespace=re.search(r'namespace\s*=\s*"([^"]+)"',text).group(1)
activity=app/'src/main/kotlin'/namespace.replace('.','/')/'MainActivity.kt'
activity.parent.mkdir(parents=True,exist_ok=True)
production='true' if package==prod and approved else 'false'
requires='true' if package==prod or consent_test else 'false'
# IDs are public identifiers; credentials remain only in the upload-signing secrets.
ids={key:config.get(key,'') for key in ['bannerId','interstitialId','rewardedId']}
activity.write_text(f'''package {namespace}

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {{
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {{
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.mehedi.puzzlemix/ads")
            .setMethodCallHandler {{ call, result ->
                val packageName = applicationContext.packageName
                when (call.method) {{
                    "isDevPackage" -> result.success(packageName == "{dev}")
                    "getAdConfiguration" -> {{
                        val live = {production} && packageName == "{prod}"
                        val test = packageName == "{dev}"
                        result.success(mapOf(
                            "packageName" to packageName,
                            "mode" to if (live) "production" else if (test) "test" else "disabled",
                            "requiresConsent" to {requires},
                            "bannerId" to "{ids['bannerId']}",
                            "interstitialId" to "{ids['interstitialId']}",
                            "rewardedId" to "{ids['rewardedId']}"
                        ))
                    }}
                    else -> result.notImplemented()
                }}
            }}
    }}
}}
''',encoding='utf-8')
if 'proguard-rules.pro' not in text:
    raise SystemExit('Release JNI/R8 rules must be applied before ads configuration')
print('Ads configured: '+('production with UMP consent' if package==prod else 'DEV sample inventory'+(' with UMP consent' if consent_test else '')))

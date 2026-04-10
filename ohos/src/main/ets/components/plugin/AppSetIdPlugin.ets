import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';


import { abilityAccessCtrl, common, featureAbility, PermissionRequestResult } from '@kit.AbilityKit';
import hilog from '@ohos.hilog';
import { advertising, identifier } from '@kit.AdsKit';

const TAG: string = 'Ads Demo-Index';

/** AppSetIdPlugin **/
export default class AppSetIdPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "AppSetIdPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "app_set_id");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method == "getIdentifier") {
      const oaid = await this.requestOAID(getContext());
      result.success(oaid)
    } else {
      result.notImplemented()
    }
  }

  async requestOAID(context: Context): Promise<string | undefined> {
    let isPermissionGranted: boolean = false;
    try {
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const result: PermissionRequestResult =
        await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']);
      isPermissionGranted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to request permission. Code is ${err.code}, message is ${err.message}`);
    }
    if (isPermissionGranted) {
      hilog.info(0x0000, TAG, 'Succeeded in requesting permission');
      try {
        const oaid = await identifier.getOAID();
        hilog.info(0x0000, TAG, 'Succeeded in getting OAID');
        return oaid;
      } catch (err) {
        hilog.error(0x0000, TAG, `Failed to get OAID. Code is ${err.code}, message is ${err.message}`);
      }
    } else {
      hilog.error(0x0000, TAG, 'Failed to request permission. User rejected');
    }
    return undefined;
  }
}
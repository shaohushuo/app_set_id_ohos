# app_set_id_ohos

[app_set_id](https://pub.dev/packages/app_set_id) 的鸿蒙（HarmonyOS）平台实现插件。

> **OAID（开放匿名设备标识符）**：是一种非永久性设备标识符，基于开放匿名设备标识符，可在保护用户个人数据隐私安全的前提下，向用户提供个性化广告，同时三方监测平台也可以向广告主提供转化归因分析。

## 功能特性

- ✅ 支持获取鸿蒙设备的 OAID
- ✅ 自动申请 `ohos.permission.APP_TRACKING_CONSENT` 权限
- ✅ 与 `app_set_id` 包无缝集成
- ✅ 完整的错误处理

## 平台支持

本插件 **仅支持** HarmonyOS (OHOS) 平台。

| Platform | Support |
|----------|---------|
| OHOS     | ✅      |

## 安装

### 1. 添加依赖

在 `pubspec.yaml` 中添加 `app_set_id` 和 `app_set_id_ohos`：

```yaml
dependencies:
  app_set_id: ^1.4.0      # 主包，提供统一的 API 接口
  app_set_id_ohos: ^1.3.0 # 鸿蒙平台实现
```

### 2. 权限配置

在鸿蒙项目的 `ohos/entry/src/main/module.json5` 中添加以下权限：

```json
{
  "module": {
    "requestPermissions": [
      {"name" :  "ohos.permission.APP_TRACKING_CONSENT"}
    ]
  }
}
```



插件已自动配置所需权限。如需自定义权限说明，可在鸿蒙项目的 `ohos/src/main/resources/base/element/string.json` 中添加：

```json
{
  "string": [
    {
      "name": "app_tracking_permission_reason",
      "value": "获取 OAID 设备标识符"
    }
  ]
}
```

### 3. 运行 flutter pub get

```bash
flutter pub get
```

## 使用方法

### 导入包

```dart
import 'package:app_set_id/app_set_id.dart';
```

### 获取 OAID

```dart
try {
  final oaid = await AppSetId.getIdentifier();
  if (oaid != null) {
    print('OAID: $oaid');
  } else {
    print('获取 OAID 失败');
  }
} catch (e) {
  print('获取 OAID 异常：$e');
}
```

### 完整示例

```dart
import 'package:app_set_id/app_set_id.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _oaid;

  @override
  void initState() {
    super.initState();
    _loadOAID();
  }

  Future<void> _loadOAID() async {
    try {
      final oaid = await AppSetId.getIdentifier();
      setState(() {
        _oaid = oaid;
      });
    } catch (e) {
      setState(() {
        _oaid = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('OAID: ${_oaid ?? "Loading..."}'),
        ),
      ),
    );
  }
}
```

## API 参考

### `AppSetId.getIdentifier()`

获取设备的 OAID 标识符。

**返回值**: `Future<String?>`

**说明**:
- 成功时返回 OAID 字符串
- 如果用户拒绝权限或获取失败，返回 `null`

## 依赖要求

- Flutter SDK >= 2.5.0
- HarmonyOS SDK with Ads Kit 支持
- 需要 `@kit.AdsKit` 依赖

## 权限说明

插件需要申请 `ohos.permission.APP_TRACKING_CONSENT` 权限才能获取 OAID。首次调用时会自动弹出权限申请对话框。

## 技术架构

本插件采用标准的 Flutter 插件架构：

```
app_set_id_ohos/
├── lib/                        # Dart 代码
│   └── app_set_id_ohos.dart    # 对外暴露的 API
├── ohos/                       # 鸿蒙平台实现
│   ├── src/
│   │   └── main/
│   │       ├── module.json5    # 模块配置（含权限声明）
│   │       └── resources/      # 资源文件
│   └── build-profile.json5
├── example/                    # 示例项目
└── pubspec.yaml                # 插件配置
```

### MethodChannel 通信

插件通过 MethodChannel 实现 Dart 与 ArkTS 之间的通信：

- **Dart 端**: 调用 `invokeMethod('getIdentifier')`
- **ArkTS 端**: 实现 `onMethodCall` 处理方法

## 开发指南

### 创建鸿蒙 Flutter 插件

```bash
flutter create . --template=plugin --platforms=ohos --org nl.u2312.app_set_id
```

### 配置 pubspec.yaml

```yaml
ohos:
  package: nl.u2312.app_set_id_ohos
  pluginClass: AppSetIdPlugin
```

### ArkTS 核心代码示例

```typescript
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import hilog from '@ohos.hilog';
import { advertising, identifier } from '@kit.AdsKit';

// 申请权限并获取 OAID
async requestOAID(context: Context): Promise<string | undefined> {
  let isPermissionGranted: boolean = false;
  try {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const result: PermissionRequestResult =
      await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']);
    isPermissionGranted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  } catch (err) {
    hilog.error(0x0000, TAG, `Failed to request permission`);
  }

  if (isPermissionGranted) {
    const oaid = await identifier.getOAID();
    return oaid;
  }
  return undefined;
}
```

## 示例项目

运行示例项目：

```bash
cd example
flutter pub get
flutter run
```

## 截图

![运行截图](ohos-screenshot.jpg)

## 参考资源

- [app_set_id 主包](https://pub.dev/packages/app_set_id)
- [Flutter 插件开发文档](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
- [鸿蒙 OAID 开发指南](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/oaid-0000001050783198)

## 贡献

欢迎提交 Issue 和 Pull Request！

// Copyright 2021 Kwai, Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'debugger.dart';
import 'http/network_debugger.dart';
import 'http/httphook/http_hook_controller.dart';
import 'http/httparchive/http_archive_list_page.dart';
import 'appinfo/app_info.dart';
import 'deviceinfo/device_info.dart';
import 'fileexplorer/file_explorer.dart';
import 'serverconfig/server_config.dart';
import 'widgets/common_widgets.dart';

class DebuggerRegister {
  static final DebuggerRegister instance =
      DebuggerRegister._privateConstructor();

  DebuggerRegister._privateConstructor();

  final Map<String, ToolPageRoute> _toolRoutes = Map<String, ToolPageRoute>();
  final List<ToolsGroup> _groups = [
    ToolsGroup(title: '基本信息', toolWidgetBuilder: []),
    ToolsGroup(title: '常用工具', toolWidgetBuilder: []),
    ToolsGroup(title: '联调调试', toolWidgetBuilder: []),
    ToolsGroup(title: '其他工具', toolWidgetBuilder: []),
  ];

  List<ToolsGroup> get groups => List.from(_groups);

  ToolPageRoute getPageRoute(String route) {
    ToolPageRoute ret;
    _toolRoutes.forEach((key, value) {
      if (key == route) {
        ret = value;
      }
    });
    return ret;
  }

  ///添加组件到 信息
  void registerItemToInfoGroup(ItemBuilder item) {
    _registerItemToGroup(_groups[0], item);
  }

  ///添加组件到 工具
  void registerItemToKitGroup(ItemBuilder item) {
    _registerItemToGroup(_groups[1], item);
  }

  ///添加组件到 调试
  void registerItemToDebuggingGroup(ItemBuilder item) {
    _registerItemToGroup(_groups[2], item);
  }

  ///添加组件到 其他
  void registerItemToOtherGroup(ItemBuilder item) {
    _registerItemToGroup(_groups[3], item);
  }

  void _registerItemToGroup(ToolsGroup group, ItemBuilder item) {
    group.toolWidgetBuilder.add(item);
  }

  void registerDefault() {
    _registerItem();
    _registerRoute();
  }

  void _registerRoute() {
    _toolRoutes['http_hook'] = ToolPageRoute(
        name: '网络抓包',
        pageBuilder: (BuildContext ctx) {
          return HttpArchiveListPage();
        });
  }

  void _registerItem() {
    registerItemToInfoGroup((ctx) => SimpleToolItemWidget(
        name: 'App信息',
        icon: Icons.widgets,
        pageBuilder: (BuildContext ctx) {
          return AppInfoPage();
        }));

    registerItemToInfoGroup((ctx) => SimpleToolItemWidget(
        name: '设备信息',
        icon: Icons.phone_iphone,
        pageBuilder: (BuildContext ctx) {
          return DeviceInfoPage();
        }));

    registerItemToKitGroup((ctx) {
      ValueNotifier<bool> showDebugger =
          ValueNotifier(Debugger.instance.isFloatingDebuggerShowing());
      return ToggleToolItemWidget(
        name: '悬浮按钮',
        icon: Icons.bug_report,
        value: showDebugger,
        onChanged: (v) {
          showDebugger.value = v;
          if (v) {
            Debugger.instance.showDebugger(ctx);
          } else {
            Debugger.instance.hideDebugger();
          }
        },
      );
    });

    registerItemToKitGroup((ctx) => SimpleToolItemWidget(
        name: '文件浏览',
        icon: Icons.folder_open,
        pageBuilder: (BuildContext ctx) {
          return FileExplorerPage();
        }));

    registerItemToKitGroup((ctx) {
      ValueNotifier<bool> showPerformanceOverlay =
          ValueNotifier(WidgetsApp.showPerformanceOverlayOverride);
      return ToggleToolItemWidget(
        name: '性能监控',
        icon: Icons.flash_on,
        value: showPerformanceOverlay,
        onChanged: (v) {
          showPerformanceOverlay.value = v;
          WidgetsApp.showPerformanceOverlayOverride = v;
          StatefulElement rootAppElement;
          ctx.visitAncestorElements((element) {
            if (element is StatefulElement && element.widget is WidgetsApp) {
              rootAppElement = element;
            }
            return true;
          });
          rootAppElement?.markNeedsBuild();
        },
      );
    });

    if (ServerEnv.instance.hasConfig()) {
      registerItemToDebuggingGroup((ctx) => SimpleToolItemWidget(
          name: '服务器配置',
          icon: Icons.phonelink,
          summary: ServerEnv.instance.envName,
          pageBuilder: (BuildContext ctx) {
            return ServerEnvConfigPage();
          }));
    }

    registerItemToDebuggingGroup((ctx) => ToggleToolItemWidget(
          name: '网络抓包',
          icon: Icons.network_check,
          value: HttpHookController.instance.enableHook,
          onChanged: (v) {
            HttpHookController.instance.setEnable(v);
          },
          pageBuilder: (BuildContext ctx) {
            return HttpArchiveListPage();
          },
        ));

    registerItemToDebuggingGroup((ctx) => ToggleToolItemWidget(
          name: '网络代理',
          icon: Icons.settings_ethernet,
          value: NetworkDebugger.instance.enableProxy,
          onChanged: (v) {
            NetworkDebugger.instance.setEnableProxy(v);
          },
          pageBuilder: (BuildContext ctx) {
            return NetworkProxyConfigPage();
          },
        ));
  }
}

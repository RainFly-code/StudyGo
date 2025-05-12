# StudyGo项目技术栈
## 开发平台与框架
1. HarmonyOS开发平台 ：项目基于华为的HarmonyOS操作系统开发，从 build-profile.json5 文件中可以看到 runtimeOS: "HarmonyOS" 的配置。
2. ArkTS编程语言 ：项目使用ArkTS作为主要编程语言，这是HarmonyOS推荐的应用开发语言，扩展了TypeScript，增加了声明式UI和状态管理等特性。从项目中大量的 .ets 文件可以看出。
3. ArkUI框架 ：项目使用ArkUI作为UI开发框架，采用了声明式UI范式，通过 @Component 、 @Entry 等装饰器定义组件，使用 @State 等状态管理装饰器。
## 项目架构
1. Stage模型 ：从 entry/build-profile.json5 中的 "apiType": 'stageMode' 配置可以看出，项目采用了HarmonyOS的Stage应用模型。
2. MVC架构 ：项目采用了类似MVC的架构模式：
   
   - Model层： model 目录下定义了数据模型，如 UserModel.ets 、 StudyRoomModel.ets 等
   - View层： pages 目录下实现了各个页面的UI组件
   - Controller/Service层： service 目录下封装了业务逻辑和API调用
3. 模块化设计 ：项目按功能模块进行了清晰的目录划分，包括用户管理、自习室管理、预约管理、反馈管理等模块。
## 核心API与组件
1. HarmonyOS系统API ：
   
   - @ohos.app.ability.UIAbility ：应用能力管理
   - @ohos.router ：页面路由导航
   - @ohos.net.http ：网络请求
   - @ohos.hilog ：日志记录
   - @ohos.window ：窗口管理
   - @ohos.app.ability.abilityDelegatorRegistry ：测试相关
2. UI组件 ：
   
   - 基础组件：Text、Image、TextInput、Button等
   - 容器组件：Column、Row、Scroll、Refresh等
   - 自定义组件：LoadingDialog、ToastUtil、ConfirmDialog等
3. 状态管理 ：
   
   - @State ：组件内部状态管理
   - PreferenceUtil ：本地数据持久化
## 网络与数据处理
1. HTTP网络请求 ：
   
   - 使用 @ohos.net.http 模块实现网络请求
   - 封装了 HttpUtil 工具类，支持GET、POST、PUT、DELETE等请求方法
   - 实现了请求拦截、会话管理、错误处理等功能
2. 数据存储 ：
   
   - 使用 PreferenceUtil 工具类封装了本地数据存储功能
   - 主要用于存储用户信息、Token、会话ID等
## 测试框架
1. Hypium测试框架 ：
   - 使用 @ohos/hypium 作为测试框架
   - 支持单元测试和UI测试
   - 在 ohosTest 目录下包含测试用例和测试运行器
## 构建工具
1. hvigor构建工具 ：
   - 使用版本：2.4.2
   - 依赖 @ohos/hvigor-ohos-plugin 插件
   - 负责项目的编译、打包和部署
## 项目依赖
1. 开发依赖 ：
   
   - @ohos/hypium ：版本1.0.6，测试框架
   - @ohos/hvigor-ohos-plugin ：版本2.4.2，构建插件
2. 运行时依赖 ：
   
   - 主要使用HarmonyOS系统内置的API和组件库
   - 未引入额外的第三方运行时依赖

# Java 生态说明

## 基本信息

- 用途：JDK、Maven、Gradle。
- macOS 推荐安装方式：brew 或 SDKMAN。
- Linux 推荐安装方式：优先使用 apt 安装 OpenJDK；需要多版本时再手动安装到 `/xyz/opt/linux/sdk/java`。
- 当前版本：OpenJDK 25.0.3（2026-04-21）

## 目录布局

```text
/xyz/opt/linux/sdk/java/
├── jdk-<version>/
└── tools/
    ├── maven/apache-maven/
    └── gradle/gradle/
```

## 缓存与数据目录

| 工具 | 推荐位置 | 环境变量 |
|---|---|---|
| Maven | `/xyz/var/maven` | `MAVEN_USER_HOME` |
| Gradle | `/xyz/var/gradle` | `GRADLE_USER_HOME` |

## 环境配置

脚本位置：[../../../../etc/profile.d/bash/java.sh](../../../../etc/profile.d/bash/java.sh)

```bash
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/default-java}"
export MAVEN_HOME="${XYZ_ROOT}/opt/linux/sdk/java/tools/maven/apache-maven"
export MAVEN_USER_HOME="${XYZ_ROOT}/var/maven"
export GRADLE_HOME="${XYZ_ROOT}/opt/linux/sdk/java/tools/gradle/gradle"
export GRADLE_USER_HOME="${XYZ_ROOT}/var/gradle"
```

## 验证

```bash
java -version
javac -version
mvn --version
gradle --version
```

## 注意事项

- 不在公开仓库写真实 Maven/Gradle 私服、代理账号或凭据。
- Maven `settings.xml` 和 Gradle `init.gradle` 只提交模板。


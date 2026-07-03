# Java, Maven and Gradle.

export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/default-java}"
export MAVEN_HOME="${XYZ_ROOT:-/xyz}/opt/linux/sdk/java/tools/maven/apache-maven"
export MAVEN_USER_HOME="${XYZ_ROOT:-/xyz}/var/maven"
export GRADLE_HOME="${XYZ_ROOT:-/xyz}/opt/linux/sdk/java/tools/gradle/gradle"
export GRADLE_USER_HOME="${XYZ_ROOT:-/xyz}/var/gradle"

path_prepend_or_replace "$JAVA_HOME/bin"
path_prepend_or_replace "$MAVEN_HOME/bin"
path_prepend_or_replace "$GRADLE_HOME/bin"

use-java-home() {
    local next_java_home="$1"
    if [ -z "$next_java_home" ] || [ ! -x "$next_java_home/bin/java" ]; then
        echo "usage: use-java-home /path/to/jdk" >&2
        return 1
    fi

    path_prepend_or_replace "$JAVA_HOME/bin" ""
    export JAVA_HOME="$next_java_home"
    path_prepend_or_replace "$JAVA_HOME/bin"
}


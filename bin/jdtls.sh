#!/usr/bin/env bash

case Linux in
Linux)
	CONFIG="$HOME/.local/share/nvim/lsp_servers/jdtls/config_linux"
	;;
Darwin)
	CONFIG="$HOME/.local/share/nvim/lsp_servers/jdtls/config_mac"
	;;
esac

JAR="$HOME/.local/share/nvim/lsp_servers/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ]; then
	if [ -x "$JAVA_HOME/jre/sh/java" ]; then
		# IBM's JDK on AIX uses strange locations for the executables
		JAVACMD="$JAVA_HOME/jre/sh/java"
	else
		JAVACMD="$JAVA_HOME/bin/java"
	fi
	if [ ! -x "$JAVACMD" ]; then
		die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
	fi
else
	JAVACMD="java"
	which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

GRADLE_HOME=$HOME/gradle "$JAVACMD" \
	-Declipse.application=org.eclipse.jdt.ls.core.id1 \
	-Dosgi.bundles.defaultStartLevel=4 \
	-Declipse.product=org.eclipse.jdt.ls.core.product \
	-Dlog.protocol=true \
	-Dlog.level=ALL \
	-javaagent:$HOME/.local/share/nvim/lsp_servers/jdtls/lombok.jar \
	-Xms1g \
	-Xmx2G \
	-jar $(echo "$JAR") \
	-configuration "$CONFIG" \
	-data "${1:-$HOME/workspace}" \
	--add-modules=ALL-SYSTEM \
	--add-opens java.base/java.util=ALL-UNNAMED \
	--add-opens java.base/java.lang=ALL-UNNAMED

# for older java versions if you wanna use lombok
# -Xbootclasspath/a:/usr/local/share/lombok/lombok.jar \

# -javaagent:/usr/local/share/lombok/lombok.jar \

# for older java versions if you wanna use lombok
# -Xbootclasspath/a:/usr/local/share/lombok/lombok.jar \

# -javaagent:/usr/local/share/lombok/lombok.jar \

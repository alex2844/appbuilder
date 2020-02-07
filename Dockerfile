FROM adoptopenjdk:8-jdk-hotspot

MAINTAINER Alex Smith

ENV GRADLE_HOME="/opt/gradle" \
	ANDROID_HOME="/opt/sdk" \
	ANDROID_VERSION="29" \
	ANDROID_BUILD_TOOLS_VERSION="28.0.3" \
	ANDROID_SDK_TOOLS_VERSION="4333796" \
	GRADLE_VERSION="4.6"

RUN set -o errexit -o nounset \
    && echo "Adding gradle user and group" \
    && groupadd --system --gid 1000 gradle \
    && useradd --system --gid gradle --uid 1000 --shell /bin/bash --create-home gradle \
    && mkdir /home/gradle/.gradle \
    && chown --recursive gradle:gradle /home/gradle \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln -s /home/gradle/.gradle /root/.gradle \
	&& apt-get update \
    && apt-get install --yes --no-install-recommends \
        fontconfig \
        unzip \
        wget \
        \
        bzr \
        git \
        git-lfs \
        mercurial \
        openssh-client \
        subversion \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    && echo "Testing Gradle installation" \
    && gradle --version \
	&& mkdir "$ANDROID_HOME" ".android" \
    && cd "$ANDROID_HOME" \
    && curl -o sdk.zip "https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_TOOLS_VERSION.zip" \
    && unzip sdk.zip \
    && rm sdk.zip
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
RUN $ANDROID_HOME/tools/bin/sdkmanager --update
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_VERSION}" "platform-tools"

WORKDIR /home/gradle
VOLUME ["/home/gradle/.gradle"]
CMD ["gradle", "build", "-Dorg.gradle.project.buildDir=/home/gradle/.gradle/build/"]

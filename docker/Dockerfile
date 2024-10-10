FROM jenkins/jenkins:jdk17
USER jenkins

# Specify version to skip setup wizard
RUN echo 2.7.1 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo 2.7.1 > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

# Enable Config SonarQube before hand
COPY jenkins-config.yaml /var/jenkins_home/casc_configs/
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs/jenkins-config.yaml
RUN jenkins-plugin-cli --plugins "configuration-as-code"

# Install plugins
RUN jenkins-plugin-cli --plugins "cloudbees-folder"
RUN jenkins-plugin-cli --plugins "ant"
RUN jenkins-plugin-cli --plugins "gradle"
RUN jenkins-plugin-cli --plugins "github-branch-source"
RUN jenkins-plugin-cli --plugins "pipeline-github-lib"
RUN jenkins-plugin-cli --plugins "pipeline-stage-view"
RUN jenkins-plugin-cli --plugins "workflow-aggregator"
RUN jenkins-plugin-cli --plugins "timestamper"
RUN jenkins-plugin-cli --plugins "sonar"
RUN jenkins-plugin-cli --plugins "git"


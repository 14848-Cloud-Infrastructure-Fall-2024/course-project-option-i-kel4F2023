#!/bin/bash

set -e

# Wait for Jenkins to be ready
until kubectl get pods | grep jenkins | grep Running; do sleep 10; done
echo "Jenkins is running"

# Get Jenkins admin password
JENKINS_POD=$(kubectl get pods -l app=jenkins --field-selector=status.phase=Running -o jsonpath="{.items[0].metadata.name}")
JENKINS_PASSWORD=$(kubectl exec $JENKINS_POD -- cat /var/jenkins_home/secrets/initialAdminPassword)
echo "Jenkins initial admin password: $JENKINS_PASSWORD"

# Install necessary Jenkins plugins
kubectl exec $JENKINS_POD -- jenkins-plugin-cli --plugins sonar

# Wait for SonarQube to be ready
until kubectl get pods | grep sonarqube | grep Running; do sleep 10; done
echo "SonarQube is running"

# Get SonarQube service ClusterIP
SONARQUBE_IP=$(kubectl get service sonarqube -o jsonpath='{.spec.clusterIP}')

# Configure Jenkins to use SonarQube
cat << EOF > jenkins-configure-sonarqube.groovy
import jenkins.model.*
import hudson.plugins.sonar.*
import hudson.plugins.sonar.model.*

def instance = Jenkins.getInstance()
def descriptor = instance.getDescriptor("hudson.plugins.sonar.SonarGlobalConfiguration")

def sonarInstallation = new SonarInstallation(
    "SonarQube", 
    "http://${SONARQUBE_IP}:9000", 
    "5.3", 
    "", 
    "", 
    "", 
    "", 
    ""
)

descriptor.setInstallations(sonarInstallation)
descriptor.save()

instance.save()
EOF

# Copy the Groovy script to the Jenkins pod
kubectl cp jenkins-configure-sonarqube.groovy ${JENKINS_POD}:/var/jenkins_home/

# Execute the Groovy script in the Jenkins pod
kubectl exec $JENKINS_POD -- /bin/bash -c "java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth admin:$JENKINS_PASSWORD groovy = < /var/jenkins_home/jenkins-configure-sonarqube.groovy"

echo "Jenkins and SonarQube have been configured for intercommunication"
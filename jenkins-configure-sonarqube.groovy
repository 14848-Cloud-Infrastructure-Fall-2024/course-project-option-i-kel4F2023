import jenkins.model.*
import hudson.plugins.sonar.*
import hudson.plugins.sonar.model.*

def instance = Jenkins.getInstance()
def descriptor = instance.getDescriptor("hudson.plugins.sonar.SonarGlobalConfiguration")

def sonarInstallation = new SonarInstallation(
    "SonarQube", 
    "http://34.118.231.172:9000", 
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

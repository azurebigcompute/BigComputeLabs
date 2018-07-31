#!/usr/bin/python
# Prepare an Azure provider account for CycleCloud usage.
import argparse
import tarfile
import json
import re
import random
from string import ascii_letters, ascii_uppercase, ascii_lowercase, digits
from subprocess import CalledProcessError, check_output 
from os import path, listdir, makedirs, chdir, fdopen, remove
from urllib2 import urlopen, Request
from urllib import urlretrieve
from shutil import rmtree, copy2, move, copytree
from tempfile import mkstemp, mkdtemp
from time import sleep


tmpdir = mkdtemp()
print "Creating temp directory " + tmpdir + " for installing CycleCloud"
cycle_root = "/opt/cycle_server"
cs_cmd = cycle_root + "/cycle_server"

def clean_up():
    rmtree(tmpdir)    


def _catch_sys_error(cmd_list):
    try:
        output = check_output(cmd_list)
        print cmd_list
        print output
    except CalledProcessError as e:
        print "Error with cmd: %s" % e.cmd
        print "Output: %s" % e.output
        raise


def account_and_cli_setup(tenant_id, application_id, application_secret, admin_user, azure_region, accept_terms):
    print "Setting up azure account in CycleCloud and initializing cyclecloud CLI"
    metadata_url = "http://169.254.169.254/metadata/instance?api-version=2017-08-01"
    metadata_req = Request(metadata_url, headers={"Metadata" : True})
    metadata_response = urlopen(metadata_req)
    vm_metadata = json.load(metadata_response)

    subscription_id = vm_metadata["compute"]["subscriptionId"]
    location = vm_metadata["compute"]["location"]
    resource_group = vm_metadata["compute"]["resourceGroupName"]

    random_suffix = ''.join(random.SystemRandom().choice(ascii_lowercase) for _ in range(14))

    random_pw_chars = ( [random.choice(ascii_lowercase) for _ in range(20)] + 
                        [random.choice(ascii_uppercase) for _ in range(20)] + 
                        [random.choice(digits) for _ in range(10)] )
    random.shuffle(random_pw_chars)
    cyclecloud_admin_pw = ''.join(random_pw_chars) 

    storage_account_name = 'cyclecloud'  + random_suffix 
    azure_data = {
        "AzureEnvironment": azure_region,
        "AzureRMApplicationId": application_id,
        "AzureRMApplicationSecret": application_secret,
        "AzureRMSubscriptionId": subscription_id,
        "AzureRMTenantId": tenant_id,
        "AzureResourceGroup": resource_group,
        "DefaultAccount": True,
        "Location": location,
        "Name": "azure",
        "Provider": "azure",
        "ProviderId": subscription_id,
        "RMStorageAccount": storage_account_name,
        "RMStorageContainer": "cyclecloud"
    }

    app_setting_installation = {
        "AdType": "Application.Setting",
        "Name": "cycleserver.installation.complete",
        "Value": True
    }
    authenticated_user = {
        "AdType": "AuthenticatedUser",
        "Name": 'root',
        "RawPassword": cyclecloud_admin_pw,
        "Superuser": True
    }
    account_data = [
        authenticated_user,
        app_setting_installation
    ]

    account_data_file = tmpdir + "/account_data.json"
    azure_data_file = tmpdir + "/azure_data.json"

    with open(account_data_file, 'w') as fp:
        json.dump(account_data, fp)

    with open(azure_data_file, 'w') as fp:
        json.dump(azure_data, fp)

    copy2(account_data_file, cycle_root + "/config/data/")

    # wait for the data to be imported
    password_flag = ("--password=%s" % cyclecloud_admin_pw) 
    sleep(5)

    print "Initializing cylcecloud CLI"
    _catch_sys_error(["/usr/bin/cyclecloud", "initialize", "--loglevel=debug", "--batch", "--url=https://localhost:8443", "--verify-ssl=false", "--username=root", password_flag])    

    homedir = path.expanduser("~")
    cycle_config = homedir + "/.cycle/config.ini"
    with open(cycle_config, "a") as config_file:
        config_file.write("\n")
        config_file.write("[pogo azure-storage]\n")
        config_file.write("type = az\n")
        config_file.write("subscription_id = " + subscription_id+ "\n")
        config_file.write("tenant_id = " + tenant_id + "\n")
        config_file.write("application_id = " + application_id + "\n")
        config_file.write("application_secret = " + application_secret + "\n")
        config_file.write("matches = az://"+ storage_account_name + "/cyclecloud" + "\n") 


    print "Registering Azure subscription"
    # create the cloud provide account
    _catch_sys_error(["/usr/bin/cyclecloud", "account", "create", "-f", azure_data_file])

    # create a pogo.ini for the admin_user so that cyclecloud project upload works
    admin_user_cycledir = "/home/" + admin_user + "/.cycle"
    if not path.isdir(admin_user_cycledir):
        makedirs(admin_user_cycledir, mode=755) 

    pogo_config = admin_user_cycledir + "/pogo.ini"

    with open(pogo_config, "w") as pogo_config:
        pogo_config.write("[pogo azure-storage]\n")
        pogo_config.write("type = az\n")
        pogo_config.write("subscription_id = " + subscription_id+ "\n")
        pogo_config.write("tenant_id = " + tenant_id + "\n")
        pogo_config.write("application_id = " + application_id + "\n")
        pogo_config.write("application_secret = " + application_secret + "\n")
        pogo_config.write("matches = az://"+ storage_account_name + "/cyclecloud" + "\n")         

    _catch_sys_error(["chown", "-R", admin_user , admin_user_cycledir])

    if not accept_terms:
        # reset the installation status so the splash screen re-appears
        print "Resetting installation"
        sql_statement = 'update Application.Setting set Value = false where name ==\"cycleserver.installation.complete\"'
        _catch_sys_error(["/opt/cycle_server/cycle_server", "execute", sql_statement])


def start_cc(action):
    print "CycleCloud server %s" % action
    _catch_sys_error([cs_cmd, action])
    _catch_sys_error([cs_cmd, "await_startup"])
    _catch_sys_error([cs_cmd, "status"])


def redirectPorts():
    # use iptables to foward 80 and 443 to 8080 and 8443 respectively
    print "Using iptables to route 80 and 443"
    _catch_sys_error(["iptables", "-A", "PREROUTING", "-t", "nat", "-i", "eth0", "-p", "tcp", "--dport", "80", "-j", "REDIRECT", "--to-port", "8080"])
    _catch_sys_error(["iptables", "-A", "PREROUTING", "-t", "nat", "-i", "eth0", "-p", "tcp", "--dport", "443", "-j", "REDIRECT", "--to-port", "8443"])


def modify_cs_config():
    print "Editing CycleCloud server system properties file"
    # modify the CS config files
    cs_config_file = cycle_root + "/config/cycle_server.properties"

    fh, tmp_cs_config_file = mkstemp()
    with fdopen(fh,'w') as new_config:
        with open(cs_config_file) as cs_config:
            for line in cs_config:
                if 'webServerMaxHeapSize=' in line:
                    new_config.write('webServerMaxHeapSize=4096M')
                elif 'webServerEnableHttps=' in line:
                    new_config.write('webServerEnableHttps=true')
                elif 'webServerRedirectHttp=' in line:
                    new_config.write('webServerRedirectHttp=true')
                else:
                    new_config.write(line)

    remove(cs_config_file)
    move(tmp_cs_config_file, cs_config_file)

    #Ensure that the files are created by the cycleserver service user
    _catch_sys_error(["chown", "-R", "cycle_server.", cycle_root])


def generate_ssh_key(admin_user):
    print "Creating an SSH private key for VM access"
    homedir = path.expanduser("~")
    sshdir = homedir + "/.ssh"
    if not path.isdir(sshdir):
        makedirs(sshdir, mode=700) 
    
    sshkeyfile = sshdir + "/cyclecloud.pem"
    if not path.isfile(sshkeyfile):
        _catch_sys_error(["ssh-keygen", "-f", sshkeyfile, "-t", "rsa", "-b", "2048","-P", ''])

    # make the cyclecloud.pem available to the cycle_server process
    cs_sshdir = cycle_root + "/.ssh"
    cs_sshkeyfile = cs_sshdir + "/cyclecloud.pem"

    if not path.isdir(cs_sshdir):
        makedirs(cs_sshdir)
    
    if not path.isdir(cs_sshkeyfile):
        copy2(sshkeyfile, cs_sshkeyfile)
        _catch_sys_error(["chown", "-R", "cycle_server.", cs_sshdir])
        _catch_sys_error(["chmod", "700", cs_sshdir])

    # make the cyclecloud.pem available to the login user as well
    adminuser_sshdir = "/home/" + admin_user + "/.ssh"
    adminuser_sshkeyfile = adminuser_sshdir + "/cyclecloud.pem"

    if not path.isdir(adminuser_sshdir):
        makedirs(adminuser_sshdir)
    
    if not path.isdir(adminuser_sshkeyfile):
        copy2(sshkeyfile, adminuser_sshkeyfile)
        _catch_sys_error(["chown", "-R", admin_user, adminuser_sshdir])
        _catch_sys_error(["chmod", "700", adminuser_sshdir])


def download_install_cc(download_url, version):    
    chdir(tmpdir)
    cyclecloud_rpm = "cyclecloud-" + version + ".x86_64.rpm"
    cyclecloud_tar = "cyclecloud-" + version + ".linux64.tar.gz" 
    cc_url = download_url + "/" + version + "/" + cyclecloud_tar

    print "Downloading CycleCloud from " + cc_url
    urlretrieve (cc_url, cyclecloud_tar)

    cc_tar = tarfile.open(cyclecloud_tar, "r:gz")
    cc_tar.extractall(path=tmpdir)
    cc_tar.close()


    # CLI comes with an install script but that installation is user specific
    # rather than system wide. 
    # Downloading and installing pip, then using that to install the CLIs 
    # from source.
    print "Unzip and install CLI"
    _catch_sys_error(["unzip", "cycle_server/tools/cyclecloud-cli.zip"]) 
    for cli_install_dir in listdir("."):
        if path.isdir(cli_install_dir) and re.match("cyclecloud-cli-installer", cli_install_dir):
            print "Found CLI install DIR %s" % cli_install_dir
            chdir(cli_install_dir + "/packages")
            urlretrieve("https://bootstrap.pypa.io/get-pip.py", "get-pip.py")
            _catch_sys_error(["python", "get-pip.py"]) 
            _catch_sys_error(["pip", "install", "cyclecloud-cli-sdist.tar.gz"]) 
            _catch_sys_error(["pip", "install", "pogo-sdist.tar.gz"]) 

    chdir(tmpdir)

    print "Installing Azure CycleCloud server"
    _catch_sys_error(["cycle_server/install.sh"])
    print "Waiting for server start"
    _catch_sys_error([cs_cmd, "await_startup"])
    _catch_sys_error([cs_cmd, "status"])



def install_pre_req():
    print "Installing pre-requisites for CycleCloud server"
    _catch_sys_error(["yum", "install", "-y", "java-1.8.0-openjdk-headless"])

    # not strictly needed, but it's useful to have the AZ CLI 
    # Taken from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest
    _catch_sys_error(["rpm", "--import", "https://packages.microsoft.com/keys/microsoft.asc"])
    _catch_sys_error(["sh", "-c", 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'])
    _catch_sys_error(["yum", "install", "-y", "azure-cli"])


def main():
    
    parser = argparse.ArgumentParser(description="usage: %prog [options]")


    parser.add_argument("--cycleCloudVersion",
                      dest="cycleCloudVersion",
                    #   required=True,
                      help="CycleCloud version to install")

    parser.add_argument("--downloadURL",
                      dest="downloadURL",
                    #   required=True,
                      help="Download URL for the Cycle install")

    parser.add_argument("--azureRegion",
                      dest="azureRegion",
                      help="Azure Region [china|germany|public|usgov]")

    parser.add_argument("--tenantId",
                      dest="tenantId",
                      help="Tenant ID of the Azure subscription")

    parser.add_argument("--applicationId",
                      dest="applicationId",
                      help="Application ID of the Service Principal")

    parser.add_argument("--applicationSecret",
                      dest="applicationSecret",
                      help="Application Secret of the Service Principal")

    parser.add_argument("--adminUser",
                      dest="adminUser",
                      help="The local admin user for the CycleCloud VM")

    parser.add_argument("--acceptTerms",
                      dest="acceptTerms",
                      action="store_true",
                      help="The local admin user for the CycleCloud VM")

    args = parser.parse_args()

    print("Debugging arguments: %s" % args)

    install_pre_req()
    download_install_cc(args.downloadURL, args.cycleCloudVersion) 
    generate_ssh_key(args.adminUser)
    modify_cs_config()
    start_cc("restart")
    redirectPorts()
    account_and_cli_setup(args.tenantId, args.applicationId, args.applicationSecret, args.adminUser, args.azureRegion, args.acceptTerms)

    clean_up()


if __name__ == "__main__":
    main()





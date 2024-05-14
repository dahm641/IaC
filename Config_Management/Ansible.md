# Ansible

## What is it

Ansible is an open-source, command-line IT automation software written in Python. It simplifies system configuration, software deployment, and workflow orchestration.

There are two parts to it. One is the control node which is where you run all of your commands and coniifugrations.
The ones it manages are called managed nodes. 
The control node contains all the information about how to connect to the managed nodes including ip addresses and SSH keys. This need to be configured manually.
The computer you use to run Ansible commands is the Ansible management node.

## What does it do and how

![img_4.png](img_4.png)

Ansible simplifies automation by providing a clear, declarative way to manage infrastructure. It's widely used in DevOps, system administration, and cloud environments.

It runs on a control node and that has access to a playbook and hosts file. The hosts file tells it about everything its managing and the playbook is what it needs to do. We can also use adhoc commands to run some tasks on all managed servers quickly nad the playbook is more like a saved list of actions that it needs to run.

**Infrastructure configuration** 
   - Ansible is used for infrastructure automation
   - It helps manage and configure servers, network devices, and cloud resources.
   - Instead of manually configuring each system, Ansible allows you to define the desired state of your infrastructure in a playbook.

**Playbooks and Tasks**:
   - A playbook is a YAML file that describes a set of tasks to be executed on managed nodes.
   - Each task in a playbook represents an action (e.g., installing a package, creating a user, restarting a service).
   - Ansible executes these tasks sequentially.

**Modules**:
   - Ansible uses modules to perform specific actions on managed nodes.
   - Modules are small programs written in Python or other languages.

**Hosts**:
   - The hosts file lists the managed nodes (servers, devices) that Ansible will work with.
   - You define groups of hosts and their connection details (like SSH credentials) in this file.

**Ad-Hoc Commands**:
   - Ansible allows you to run ad-hoc commands directly from the command line.
   - For example, you can use an ad-hoc command to check if a service is running on all servers.

**Agentless Approach**:
   - Ansible is agentless, meaning it doesn't require any software to be installed on managed nodes.
   - It communicates over SSH or other protocols to execute tasks.

**Idempotence**:
   - Ansible ensures that tasks are **idempotent**, meaning they only make necessary changes.
   - If a task has already achieved the desired state, it won't repeat the action.


## Different functions
### Playbook
- a playbook is a file like a script that describes a set of tasks that you want Ansible to perform.
- Playbooks can declare configurations, orchestrate steps of any manual ordered process, on multiple sets of machines, in a defined order, and launch tasks together or separately.

### Adhoc commands
- Adhoc commands are commands which you run from the command line, outside of a playbook.
- These commands run on one or more managed nodes and perform a simple/quick task that you don’t need to repeat. 
- Adhoc commands are one-liner ansible commands that perform one task on the target host. They are not stored for future use, but are a fast way to interact with the desired servers.
- Ad hoc commands are quick and easy, but they are not reusable.
- ad hoc commands are great for tasks you repeat rarely. For example, if you want to power off all the machines in your lab for Christmas vacation, you could execute a quick one-liner in Ansible


## Benefits

- Open source - Free
- Agentless
- Simple and powerful 
- Uses YAML - user friendly mark up language
- Flexible - lets you orchestrate the entire application environment, regardless of where it’s deployed


## How we use it
### Set up

![img.png](img.png)

1. Need a controller node to control any instance
2. it can connect to the instances and perform any actions without first going on to the instances and installing an agent (agentless)
3. it installs the dependencies for you in the background without you having to worry, its abstracted away from you
4. install it on an ec2 instance by SSHing in and run update and upgrade command then
5. `sudo apt-add-repository ppa:ansible/ansible`
6. `sudo apt-get install ansible`
7. then copy your ssh key into the server into `~/.ssh`
8. can do this by using scp or even copy and pasting `scp -i ~/.ssh/mytest.key user@dest_ip:/<filepath on host> <path on client>` 
9. `scp -i ~/.ssh/tech258.pem ~/.ssh/tech258.pem ubuntu@ip:~/.ssh/`
10. run sudo chmod 400 key_name to make it read only by owner (necessary step otherwise key could become invalidated)
11. need to tell ansible to use this so go to cd /etc/ansible and sudo nano hosts
12. insert the name of the host and its ip and the user and the key in this format:
13. ```
    [APP]
    ec2-instance-app ansible_host=3.249.1.76 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/tech258.pem
    ```
14. ![img_1.png](img_1.png)

### Simple Adhoc Commands

1. run commands by using sudo ansible then name then -a then command eg 
2. `sudo ansible APP -a "uname -a"`
3. -a means arguments so we want to pass something into ansible. In this case we are using it to pass the commands in the quotation marks to whicver servers we have selected (in this case all of them)
4. if we want to run it on all we can replace app with all so  `sudo ansible all -a "uname -a"`
5. ![img_2.png](img_2.png)
6. another example is copying a file over
7. can create a file a a test then use the following command to send it where it needs to go, or everywhere
8. `ansible all -m copy -a "src=/path/to/source/file dest=/path/to/destination/file"`
9. The -m flag in the ansible command stands for "module." It allows you to specify which Ansible module you want to execute on the target hosts. Modules are essentially standalone scripts that Ansible uses to perform tasks on remote systems
10. we can check it ran by using the all function again with the -a 
11. ![img_3.png](img_3.png)
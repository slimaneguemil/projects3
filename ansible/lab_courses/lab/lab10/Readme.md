playbooks:

play2 : 
 gather facts on a html file: one file for each target
 inventory_hostname = target hostname defined in inventory file
 
 
play1:
    display ansible environment variables
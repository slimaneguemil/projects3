 2014  mkdir -p provisioning/roles
 2015  cd provisioning/roles/
 2016  ansible-galaxy init mheap.php

ansible-playbook -i inventory playwordpress.yml
ansible centos -i inventory -m command -a "cat /var/www/book.example.com/wp-config.php"
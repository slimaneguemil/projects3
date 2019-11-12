 2000  mkdir ansible-module
 2001  cd ansible-module/
 2002  git clone git://github.com/ansible/ansible.git --recursive
 2003  source ansible/hacking/test-module
 2004  source ansible/hacking/env-setup
 2005  chmod +x ansible/hacking/test-module
 2006  pip install pyyaml jinja2
 2007  touch file_upper
 2008  chmod +x file_upper
 2009  nano file_upper 
 
 ansible/hacking/test-module -m file_upper -a foo=bar
~/ansible-module/ansible/hacking/test-module -m file_upper -a foo=bar
~/ansible-module/ansible/hacking/test-module -m file_upper2 -a file=demo.txt

~/ansible-module/ansible/hacking/test-module -m wp_user -a name=toto

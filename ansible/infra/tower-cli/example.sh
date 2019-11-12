
echo " "
echo "        == Tower-CLI WORKFLOW DEMO == "
echo " "

echo "current location: ${BASH_SOURCE%/*}"

#tower-cli organization create --name="AWS"
#tower-cli credential create --name "centos2"  --credential-type "Machine" --inputs="{\"username\":\"centos\",\"ssh_key_data\":\"$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' /home/ghost/.ssh/guemils_frank.pem)\n\"}" --organization AWS
tower-cli project create --name="Ansible_Examples" --scm-type=git --scm-url="https://github.com/ansible/ansible-examples" --organization AWS --wait


tower-cli job_template create -n 'teste_vcenter_1'  --verbosity verbose --project 'Ansible_Examples' --playbook 'language_features/loop_nested.yml' --inventory="aws" --credential="centos2" --job-type "run"
#tower-cli job_template associate_credential --job-template="teste_vcenter_1"  --credential="centos2"
# puppetwebapp

Step 1: Setup Puppet Master, with below mentioned script on amazon ec2 (ubuntu)

      #!/bin/sh
      INSTANCEID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
      FDQN=`hostname -f`
      HOSTNAME='puppet-'$INSTANCEID
      echo $FDQN > /etc/hostname
      IP=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
      cat <<EOF >> /etc/hosts
      $IP $FDQN $HOSTNAME puppet
      EOF
      cd ~ && wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
      sudo dpkg -i puppetlabs-release-pc1-trusty.deb
      sudo apt-get update
      apt-get -y install puppetserver
      service puppetserver restart
      /opt/puppetlabs/bin/puppet resource service puppetserver ensure=running enable=true
      wget https://s3.amazonaws.com/learnkarts-ram/puppetweb-latest.tar.gz -O /tmp/
      tar -xvf /tmp/puppetweb-latest.tar.gz -C /etc/puppetlabs/code/environments/production/

Step 2: Setup Puppet Client, with below mentioned script on amazon ec2 (ubuntu)

      #!/bin/sh
      SERVER_IP=$1
      INSTANCEID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
      FDQN=`hostname -f`
      HOSTNAME='puppetweb-'$INSTANCEID
      echo $FDQN > /etc/hostname
      IP=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
      cat <<EOF >> /etc/hosts
      $IP $FDQN $HOSTNAME puppetweb
      $SERVERIP puppet
      EOF
      cd ~ && wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
      dpkg -i puppetlabs-release-pc1-trusty.deb
      apt-get update
      apt-get install puppet-agent -y
      /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
      
Step 3: Run the following command in puppet master

     sudo /opt/puppetlabs/bin/puppet cert sign --all
     
Step 4: Run the following command in puppet agent, which will install the java, tomcat & deploy the war file
     
     /opt/puppetlabs/bin/puppet agent --test
      


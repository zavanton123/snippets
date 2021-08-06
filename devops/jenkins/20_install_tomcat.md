# How to install Tomcat?

### Source
```
https://linuxize.com/post/how-to-install-tomcat-9-on-ubuntu-18-04/
```

### Install Java (OpenJDK)
```
sudo su
apt-get update -y && apt-get upgrade -y
apt-get install -y default-jdk
```

### create tomcat user
```
useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
```

### download tomcat tar to /tmp
```
wget https://mirror.linux-ia64.org/apache/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz -P /tmp
```

### extract the tar to /opt/tomcat
```
tar -xf /tmp/apache-tomcat-9.0.50.tar.gz -C /opt/tomcat/
```

### create a symbolic link
```
ln -s /opt/tomcat/apache-tomcat-9.0.50 /opt/tomcat/latest
```

### make the user 'tomcat' the owner of /opt/tomcat
```
chown -RH tomcat: /opt/tomcat/latest
```

### make the .sh files executable
```
chmod +x /opt/tomcat/latest/bin/*.sh
```

### create a systemd file for tomcat
### /etc/systemd/system/tomcat.service
```
[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java/java8"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"

Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
```

### Reload and run the system service
```
systemctl daemon-reload
systemctl status tomcat
systemctl restart tomcat
systemctl enable tomcat
systemctl stop tomcat
```

### change the default port to 9080
### update /opt/tomcat/latest/conf/server.xml
### update connector port to 9080
### restart tomcat



### Create a user for web management interface
### update /opt/tomcat/latest/conf/tomcat-users.xml
```
  <user username="zavanton" password="some-pass-here" roles="manager-gui"/>
  <user username="robot" password="some-pass-here" roles="manager-script"/>
  <user username="jenkins" password="some-pass-here" roles="manager-script"/>
```
### restart tomcat

### verify the user 'jenkins' is ok
### (i.e. input login and password and see if you have access)
```
http://localhost:9080/manager/text/list
```


### Allow/deny access to web interface from some IPs
### Edit /opt/tomcat/latest/webapps/manager/META-INF/context.xml
### And /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
### Update this to allow/deny some IPs
```
<Context antiResourceLocking="false" privileged="true" >
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|45.45.45.45" />
</Context>
```
### restart tomcat







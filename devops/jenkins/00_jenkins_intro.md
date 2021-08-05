
### Install Jenkins on Ubuntu
```
sudo su
apt-get update -y && apt-get upgrade -y
apt-get install -y nano wget curl zip unzip git
```

### configure git
```
git config --global user.name "zavanton"
git config --global user.email "zavanton@yandex.ru"
git config --global core.editor vim
git config --global -e
```

### Install java 
```
apt-get install -y openjdk-8-jdk openjdk-8-jdk-headless 
java -version
```

### Install maven
### download maven binary tar and install maven
```
sudo su -l
cd /usr/local
wget https://downloads.apache.org/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz
tar -xf apache-maven-3.8.1-bin.tar.gz 
chown -R root.root apache-maven-3.8.1
chmod 755 apache-maven-3.8.1
ln -s apache-maven-3.8.1 maven 
rm apache-maven-3.8.1-bin.tar.gz 
exit
```


### update ~/.bashrc
```
# App maven to path
export MAVEN_HOME=/usr/local/maven
export PATH="${PATH}:${MAVEN_HOME}/bin"
```

### check maven installation is ok
```
source ~/.bashrc
mvn -v
```



### Install Jenkins
### https://pkg.jenkins.io/debian-stable/
```
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
vim /etc/apt/sources.list.d/jenkins.list
```

### create /etc/apt/sources.list.d/jenkins.list 
```
deb https://pkg.jenkins.io/debian-stable binary/
```

### install jenkins from repo
```
sudo su
apt-get update -y && apt-get upgrade -y
apt-get install -y jenkins
```

### check jenkins installation status
```
sudo su
systemctl status jenkins
```

### if necessary add java exec path to jenkins config
### java path: /usr/lib/jvm/java/java8/bin
```
whereis java
```
### update /etc/init.d/jenkins
```
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/lib/jvm/java/java8/bin
```
### restart jenkins
```
systemctl restart jenkins
systemctl status jenkins
```

### open jenkins in browser
```
http://localhost:8080
```









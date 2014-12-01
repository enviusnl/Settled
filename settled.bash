fancy_echo(){
	printf "\033[1;$1m$2\033[0m\n"
}

ask_input(){
	echo -n "$1"
	read answer
}

printf "
\033[1;32mSettled\033[0m will turn your computer into an \033[1;32mawesome front-end tool\033[0m. 

It will install the following software. What it installs can be customized by editing this file.

cURL, Vim, Oh-My-ZSH,
Git, Phonegap, Heroku Toolbelt,
Ruby, SASS, Compass, Node.js,
Apache2, MySQL, PHP,
Grunt-cli, Gulp, Bower, Yeoman,
Sublime Text 3

"

echo "Continue?"
select yn in Yes No; do
	case $yn in
		Yes) echo "Continuing..."; break;;
		No) exit;;
	esac
done


# Update dependencies
sudo apt-get update

# Curl
sudo apt-get install curl

# Vim
sudo apt-get install vim

# ZSH
sudo apt-get install zsh

# Oh-My-ZSH
curl -L http://install.ohmyz.sh | sh


# Ruby
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

cd /tmp/
wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz
tar -xzvf ruby-2.1.3.tar.gz
cd ruby-2.1.3/
./configure
make
sudo make install

echo "gem: --no-ri --no-rdoc" > ~/.gemrc


# Install Sass & Compass
sudo gem install sass
sudo gem install compass


# Install Node & NPM
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install -y nodejs


# Install Git
sudo apt-get install git

# Git config
ask_input "Enter a user.name for Git's global config: "
git config --global user.name "$answer"
ask_input "Enter a user.email for Git's global config: "
git config --global user.email "$answer"
echo "Continuing..."


# Install Apache2
sudo apt-get install apache2

# Install MySQL
sudo apt-get install mysql-server php5-mysql
sudo mysql_install_db
sudo mysql_secure_installation

# Install PHP
sudo apt-get install php5 libapache2-mod-php5 php5-mcrypt

# Edit /var/www directory config. Index.php has to be on start.
printf "

Alright listen up soldier! We're going into the Apache config now. When you're in there I 
want you to search for the code below and move index.php to the front of the list.

<IfModule mod_dir.c>
    DirectoryIndex index.html index.cgi index.pl \033[1;31mindex.php\033[0m index.xhtml index.htm
</IfModule>

<IfModule mod_dir.c>
    DirectoryIndex \033[1;32mindex.php\033[0m index.html index.cgi index.pl index.xhtml index.htm
</IfModule>

"
echo "Are you ready to move out!?"
select yn in "Sir, yes sir!" "Cancel all of this and send me home!" "Nah dude, I'm gonna do this later..."; do
	case $yn in
		"Sir, yes sir!") sudo vi /etc/apache2/mods-enabled/dir.conf; break;;
		"Cancel all of this and send me home!") exit;;
		"Nah dude, I'm gonna do this later...") echo "Continuing..."; break;;
	esac
done

# Restart localhost
sudo service apache2 restart


# Grunt
sudo npm install -g grunt-cli

# Gulp
sudo npm install gulp -g

# Bower
sudo npm install -g bower

# Yeoman
sudo npm install -g yo


# Phonegap
sudo npm install -g phonegap

# Heroku toolbelt
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh


# Sublime
sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install sublime-text-installer


fancy_echo 32 "✔ Looks like we're done here. Did everything go well? How about some tea?"

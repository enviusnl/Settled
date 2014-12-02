fancy_echo(){
	printf "\033[1;$1m$2\033[0m\n"
}

ask_input(){
	echo -n "$1"
	read answer
}

check_installed(){
	if type $1 > /dev/null; then
		return 0
	else
		return 1
	fi
}

check_installed_gem(){
  if gem list $1 -i > /dev/null; then
    return 0
  else
    return 1
  fi
}


printf "
\033[1;32mSettled\033[0m will turn your Ubuntu 14.04 machine into an \033[1;32mawesome front-end tool\033[0m. 

It will install the following software. What it installs can be customized by editing this file.

cURL, Vim, Oh-My-ZSH,
Git, Phonegap, Heroku Toolbelt,
Ruby, SASS, Compass, Node.js,
Apache2, MySQL, PHP,
Grunt-cli, Gulp, Bower, Yeoman,
Sublime Text 3

Continue?
"
select yn in Yes No; do
	case $yn in
		Yes) echo "Continuing..."; break;;
		No) exit;;
	esac
done


# Store OS name in variable
# Throw error when the OS os not compatable
if [ "$(uname)" == "Darwin" ]; then
	OS="Mac OS X"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	OS="Linux"
else
	fancy_echo 31 "✘ We're sorry but it looks like you're running an unknown OS.
Settled supports Mac OS X and Linux. Post an issue with your OS type in the repository
and we'll look into it."
	exit 1
fi


if [ "$OS" == "Linux" ]; then
	# if Linux, check if Ruby, cURL and Git are installed

	# Update dependencies
	sudo apt-get update

	# cURL
	if ! check_installed curl; then
		sudo apt-get install curl
	fi

	# Ruby
	if ! check_installed ruby; then
		sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

		cd /tmp/
		wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz
		tar -xzvf ruby-2.1.3.tar.gz
		cd ruby-2.1.3/
		./configure
		make
		sudo make install

		echo "gem: --no-ri --no-rdoc" > ~/.gemrc
	fi

	# Git
	if ! check_installed git; then
		sudo apt-get install git
	fi

else
	# Mac OS X: install the xcode dev tools
	xcode-select --install
fi


# install Homebrew if not already installed
if ! check_installed brew; then

	if [ "$OS" == "Linux" ]; then
		# install 'Linux' homebrew
		ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/linuxbrew/go/install)"
	else
		# Mac OS X: install 'normal' homebrew
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

fi


fancy_echo 32 "✔ Homebrew installed, installing oh-my-zsh..."


# install oh-my-zsh
if [ "$OS" == "Linux" ]; then
	# ZSH
	if ! check_installed zsh; then
		sudo apt-get install zsh
	fi

	# Oh-My-ZSH
	wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
	chsh -s `which zsh`
else
	# Mac OS X: install 'the easy way'
	curl -L http://install.ohmyz.sh | sh
fi


fancy_echo 32 "✔ Oh-My-ZSH installed, installing Sass and Compass..."


# install Sass & Compass
if ! check_installed_gem sass; then
	sudo gem install sass
fi

if ! check_installed_gem compass; then
	sudo gem install compass
fi


fancy_echo 32 "✔ Sass and Compass installed, Homebrew awesomeness coming up..."


# loop Homebrew packages
# install whats not installed already
BREW_PKGS=("vim" "node" "heroku-toolbelt")
for name in "${BREW_PKGS[@]}"
do
	if ! check_installed $name; then
		brew install $name
	fi
done


fancy_echo 32 "✔ All Homebrew packages installed, Moving on to NPM..."


# loop NPM packages
# install whats not installed already
NPM_PKGS=("grunt-cli" "gulp" "bower" "yo" "phonegap")
for name in "${NPM_PKGS[@]}"
do
	if ! check_installed $name; then
		sudo npm install -g $name
	fi
done


fancy_echo 32 "✔ All NPM packages installed, Moving on..."


# apt-get packages are not always easy to remove
# so prompt user to ask if we should install them
ask_input "apache2, mysql-server, php5-mysql, php5, libapache2-mod-php5, php5-mcrypt,
sublime-text-installer

Would you like to also install and setup the above apt-get packages? (y/n) "

if [ "$answer" == "y" ]; then

	# install Apache2
	sudo apt-get install apache2

	# install MySQL
	sudo apt-get install mysql-server php5-mysql
	sudo mysql_install_db
	sudo mysql_secure_installation

	# install PHP
	sudo apt-get install php5 libapache2-mod-php5 php5-mcrypt

	# edit /var/www directory config. index.php has to be on start.
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


	# Sublime
	sudo add-apt-repository ppa:webupd8team/sublime-text-3
	sudo apt-get update
	sudo apt-get install sublime-text-installer


	fancy_echo 32 "✔ apt-get packages installed, Let's configure some stuff..."

else

	fancy_echo 32 "✔ Okidoki, Let's configure some stuff then..."

fi


# Git config
ask_input "Enter a user.name for Git's global config: "
git config --global user.name "$answer"
ask_input "Enter a user.email for Git's global config: "
git config --global user.email "$answer"
echo "Continuing..."


# Adds aliases to ~/.zshrc
echo "
# Handy Aliases
alias clr=\"clear\"
alias gac=\"g add -A && g commit\"
alias gacp=\"g add -A && g commit && g push\"" >> ~/.zshrc

echo "We've set up some handy aliases for you in ~/.zshrc:
* clr = clear
* gac = g add -A && g commit
* gacp = g add -A && g commit && g push"


fancy_echo 32 "✔ Looks like we're done here. Did everything go well? How about some tea?"
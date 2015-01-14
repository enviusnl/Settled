fancy_echo(){
	printf "\033[1;%sm%s\033[0m\n" "$1" "$2"
}

ask_input(){
	echo -n "$1"
	read answer
}

check_installed(){
	if type "$1" > /dev/null; then
		return 0
	else
		return 1
	fi
}

check_installed_gem(){
  if gem list "$1" -i > /dev/null; then
    return 0
  else
    return 1
  fi
}

check_zsh_alias(){
  if cat ~/.zshrc | grep "alias $1" > /dev/null; then
    return 0
  else
    return 1
  fi
}


# store OS name in variable
# throw error when the OS is not compatable
if [ "$(uname)" == "Darwin" ]; then
  OS="Mac OS X"
elif [ "$(uname)" == "Linux" ]; then
  OS="Linux"
else
  fancy_echo 31 "✘ We're sorry but it looks like you're running an unknown OS.
Settled supports Mac OS X and Linux. Post an issue with your OS type in the repository
and we'll look into it."
  exit 1
fi


printf "\033[1;32mSettled\033[0m will turn your Ubuntu 14.4 machine into an 
\033[1;32mawesome development tool\033[0m.

What it installs can be customized by editing this file.
By default it will install the following packages and their dependencies:

cURL, Git, Ruby,
Oh-My-ZSH, Homebrew,
Vim, Node.js, Heroku Toolbelt,
Phonegap, Grunt-cli, Gulp, Bower, Yeoman,
SASS, Compass.

On Linux it will prompt you to ask if you also would like to install:
Apache2, MySQL, PHP, Sublime Text 3.

And will set up the following aliases in your ~/.zshrc:
* clr = clear
* gac = g add -A && g commit
* gacp = g add -A && g commit && g push 
"
ask_input "Continue? [y/n] "
if [ "$answer" == "y" ]; then
  echo "Continuing..."
else
  exit
fi


if [ "$OS" == "Linux" ]; then
	# if Linux, check if dependencies are installed

	# update apt-get
	sudo apt-get update

	# install dependencies, including cURL and Ruby
	sudo apt-get install build-essential curl git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev

else
	# Mac OS X: install the xcode dev tools
	xcode-select --install
fi


fancy_echo 32 "✔ Homebrew dependencies installed, Checking Oh-My-ZSH..."


# install oh-my-zsh if not installed already
if ! check_installed zsh; then
	if [ "$OS" == "Linux" ]; then
		# ZSH
		sudo apt-get install zsh

		# Oh-My-ZSH
		wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
		
		# set zsh as default shell
		chsh -s "$(which zsh)"
	else
		# Mac OS X: install 'the easy way'
		curl -L http://install.ohmyz.sh | sh
	fi
	
	fancy_echo 32 "✔ Oh-My-ZSH installed, installing or updating Homebrew..."
else
	fancy_echo 32 "✔ Oh-My-ZSH already installed, installing or updating Homebrew..."	
fi


# install Homebrew if not already installed
if ! check_installed brew; then

	if [ "$OS" == "Linux" ]; then
		# install 'Linux' homebrew
		ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/linuxbrew/go/install)"
		
		# add homebrew to path
		# in both bashrc and zshrc
		echo "
export PATH=\"$HOME/.linuxbrew/bin:$PATH\"
export MANPATH=\"$HOME/.linuxbrew/share/man:$MANPATH\"
export INFOPATH=\"$HOME/.linuxbrew/share/info:$INFOPATH\"" >> ~/.bashrc

		echo "
export PATH=\"$HOME/.linuxbrew/bin:$PATH\"
export MANPATH=\"$HOME/.linuxbrew/share/man:$MANPATH\"
export INFOPATH=\"$HOME/.linuxbrew/share/info:$INFOPATH\"" >> ~/.zshrc

		source ~/.bashrc
	else
		# Mac OS X: install 'normal' homebrew
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
else
	brew update
fi


#check Homebrew installation
if ! check_installed brew; then
	fancy_echo 31 "✘ Homebrew was not installed. Make sure brew is in your PATH. 
If you're on Linux: try running 'source ~/.bashrc' and rerunning Settled."
	exit 1
fi


fancy_echo 32 "✔ Homebrew ready, brew awesomeness coming up..."


# loop Homebrew packages
# install whats not installed already
brew doctor
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
		npm install -g $name
	fi
done


fancy_echo 32 "✔ All NPM packages installed, installing Sass and Compass..."


# install Sass & Compass
if ! check_installed_gem sass; then
	sudo gem install sass
fi

if ! check_installed_gem compass; then
	if [ "$OS" == "Linux" ]; then
		# install ruby-dev to prevent
		# failed to build gem native extension error
		sudo apt-get install ruby-dev
	fi
	sudo gem install compass
fi

if ! check_installed_gem susy; then
	sudo gem install susy
fi


fancy_echo 32 "✔ Sass, Compass and Susy installed, Moving on..."


# if on Linux:
# prompt user to ask if we should install apt-get packages
if [ "$OS" == "Linux" ]; then
  ask_input "apache2, mysql-server, php5-mysql, php5, libapache2-mod-php5,
php5-mcrypt, sublime-text-installer

Would you like to also install and setup the above apt-get
packages? [y/n] "

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
  	printf "Alright listen up soldier! We're going into the Apache config now. When you're in there I
want you to search for the code below and move index.php to the front of the list.

<IfModule mod_dir.c>
    DirectoryIndex index.html index.cgi index.pl \033[1;31mindex.php\033[0m index.xhtml index.htm
</IfModule>

<IfModule mod_dir.c>
    DirectoryIndex \033[1;32mindex.php\033[0m index.html index.cgi index.pl index.xhtml index.htm
</IfModule>

Are you ready to move out!?
"

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
fi


# Git config
ask_input "Enter a user.name for Git's global config: "
git config --global user.name "$answer"
ask_input "Enter a user.email for Git's global config: "
git config --global user.email "$answer"
echo "Continuing..."


# adds aliases to ~/.zshrc
# if they're not already there
ZSH_ALIASES=(
  "clr:clear"
  "gac:g add -A && g commit"
  "gacp:g add -A && g commit && g push"
)
ZSH_ALIASES_START=false
for keyval in "${ZSH_ALIASES[@]}"
do
  name="${keyval%%:*}"
  cmd="${keyval##*:}"

  if ! check_zsh_alias $name; then
    if ! $ZSH_ALIASES_START; then
      echo "
# Handy aliases, set by Settled (http://github.com/enviusnl/Settled)" >> ~/.zshrc
      ZSH_ALIASES_START=true
    fi
    echo "alias $name=\"$cmd\"" >> ~/.zshrc
  fi
done

if $ZSH_ALIASES_START; then
  fancy_echo 35 "We've set up some handy aliases for you in ~/.zshrc"
fi


fancy_echo 32 "✔ Looks like we're done here."


ask_input "Are you ready to start using your new superpowers? [y/n] "
if [ "$answer" == "y" ]; then
	fancy_echo 35 "Switching to ZSH"
	zsh
else
	fancy_echo 35 "You will automatically switch to ZSH when you restart your machine."
fi

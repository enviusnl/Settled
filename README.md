Settled
=======
A Bash script that turns your Ubuntu machine into an awesome front-end development tool.

By default Settled installs the following packages and their dependencies:

cURL, Git, Ruby,
Oh-My-ZSH, Homebrew,
Vim, Node.js, Heroku Toolbelt,
Phonegap, Grunt-cli, Gulp, Bower, Yeoman,
SASS, Compass.

It will also prompt you to ask if you also would like to install:
Apache2, MySQL, PHP, Sublime Text 3.

And will set up the following aliases in your ~/.zshrc:
* clr = clear
* gac = g add -A && g commit
* gacp = g add -A && g commit && g push 

## Compatibility
Currently Settled is tested and stable for Ubuntu 14.04. The script includes code to also support Mac OS X but this hasn't been tested yet.

## Usage
```
wget https://raw.githubusercontent.com/enviusnl/Settled/master/settled.bash && bash settled.bash
```

## Customizing
If you would like to change what Settled installs you can do so by cloning this repo and editing the [`settled.bash`](https://github.com/enviusnl/Settled/blob/master/settled.bash) file.

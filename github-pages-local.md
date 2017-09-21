# Getting Github pages working locally

Run all steps inside a WSL bash session.  
> Note. We use a new config file with the site URL set to localhost: `_config_local.yaml`, we specify both configs, putting the local one last so it acts as an override.

- Follow steps on [this page](https://jekyllrb.com/docs/windows/#installation-via-bash-on-windows-10) up to the `jekyll -v` command. The commands to run are... 
  - `sudo apt-get update -y && sudo apt-get upgrade -y`
  - `sudo apt-add-repository ppa:brightbox/ruby-ng`
  - `sudo apt-get update`
  - `sudo apt-get install ruby2.3 ruby2.3-dev build-essential`
  - `sudo gem update`
  - `sudo gem install jekyll bundler`
- Still in WSL bash, go to the root of the site repo (your cloned copy), and run `bundle install` 
- When prompted enter the your password for sudo
- To start the site locally run `bundler exec jekyll serve --config _config.yml,_config_local.yml` Note. This includes the config override
- Go to **http://localhost:4000/** and rejoice!
- Note; it will watch for file changes so just edit your local files and save

## Troubleshooting...
If it stops working run through the steps again in the page linked above

Then run:  
`sudo apt install -y zlib1g-dev`

Then run:  
`bundler install`  
(This might take FOREVER)
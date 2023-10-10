
# MiniApp

## Description

This is *demo MinApp* that implements just yet another ToDoList

Purpose of this project is NOT to give any useful features for end users, but to show developers, how *easy and rapid* MiniApp development could be

### Obstacle

What is main obstacle while developing MiniApp, to my mind?

You have to debug it in Telegram

Telegram Team advice to use Telegram Beta Desktop where you can open Developer Tools and check all details in place

So, your development cycle look like:
1. Change your code
2. Build and deploy it to server
3. Open bot in Telegram Beta Desktop (if it is already opened, just refresh MiniApp page)
4. Check behavior of changed MiniApp

It is likely to shorten this cycle to improve speed of development

Becuase, MiniApp it is almost *web application*, you can try to do most things on "change your code" stage. Thus Svelte allows you see changes in browser immediately you save it to file.

But, MiniApp is **almost** *web application*. What makes it MiniApp instead of just *web application* ? Integration with Telegram, of course. There are many aspects of this integration. But my pain was integration with use of Back and Main buttons. 

Propere behavior of Back button is important for use experience. Main button is also could not be avoided while designing MiniApp.

At least these two entities exist only inside Telegram, not in *web application*. Unless we emulate them in development mode. So proper emulation of at least two entities is required to avoid excessive usage of steps 2,3 described above

Rules of this MiniApp contests asks not to use just *web application* as MiniApp. But I suggest opposite approach: we want to be able work with MiniApp as just *web application* while development. Of course, not all Telegram features could be emulated properly. But we'll try to do best of possible.

And I did try to implement such kind of emulation. Now I can stay in development mode with no need to offen "deploy to server and open Telegram Beta Desktop" longer time, than before. Development is going on at local machine (i.e. at localhost), but as a side effect emulation is still available on server side for all three [deploy targets](#deploy_targets):

- Dev: [https://dev.miniapp.u2h.ru](https://dev.miniapp.u2h.ru)
- Demo: [https://demo.miniapp.u2h.ru](https://demo.miniapp.u2h.ru)
- Prod: [https://miniapp.u2h.ru](https://miniapp.u2h.ru)

### <a name="deploy_targets"></a>Deploy targets

Important detail for developers: we will use three *deploy targets* for our MiniApp: 
- dev: [@dev_MiniAppBot](https://t.me/dev_MiniAppBot)
- demo: [@demo_MiniAppBot](https://t.me/demo_MiniAppBot)
- prod: [@prod_MiniAppBot](https://t.me/prod_MiniAppBot) - usaully no *deploy target prefix* should be used in the name of production bot, but unfortunatly name @MiniAppBot was already taken, so in this particular case name does look like *production* 

Hope, it's obvious, that *dev* is devoted to development stage. It is highly unstable. 
Developer checks his every moment changes here

*Demo* is the target, where developer freezes state of *dev*, to be ready present development progress to his team lead and/or product manager/owner

*Prod* is **production** - the goal of our development efforts

Of course, another targets could be added while required: i.e. *testing*, *release candiate* and so on, but I omit them for simplicity

### Framework

Our MiniApp is based on  [Svelte](https://svelte.dev/), which allows rapid development of web applications. MiniApp can be treated as *web application*, but with its own specifics

## OS

I love freedom, and no limits for opportunities. So my choice is Linux (I use Ubuntu 22 now)

Following instructions maybe inappropriate for non-Linux users.

Of course, all of it could be adopted to MacOS and Windows. But now I'm on MVP stage. It is just *proof of concept*, so sorry guys, if you don't use Linux in your every day development

## Prerequisites

1. First [clone](https://git-scm.com/docs/git-clone) **this repo**

2. Then prepare  [NVM](https://github.com/nvm-sh/nvm)

3. [Install](https://www.linode.com/docs/guides/how-to-install-use-node-version-manager-nvm/#use-nvm-to-install-node) and [select](https://www.linode.com/docs/guides/how-to-install-use-node-version-manager-nvm/#the-nvm-use-command) appropriate node version (v18.17.0 was used for this MiniApp) using NVM

4. Then run `npm install` to make ready all project dependecies

## <a name="deploy"></a>Deploy

### Prerequisites

Following programs are used by "deploy script":

- [ssh](https://www.cyberciti.biz/faq/how-to-install-ssh-on-ubuntu-linux-using-apt-get/)

- [make](https://linuxhint.com/install-make-ubuntu/)

- [curl](https://www.cyberciti.biz/faq/how-to-install-curl-command-on-a-ubuntu-linux/)

- [rsync](https://bytexd.com/install-and-use-rsync-on-ubuntu/)

- [fd-find](https://github.com/sharkdp/fd)

- [handlebars-cli](https://docs.rs/crate/handlebars-cli/1.0.0)

You have to install them, before you proceed. The last two tools may require to install [Rust](https://www.rust-lang.org/) to allow you to run `cargo install fd-find` and `cargo install handlebars-cli`. Don't afraid of installing Rust. It could by done by [one command](https://www.rust-lang.org/learn/get-started):

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

How to check, if it OK? Just run `which ssh make curl rsync fd handlebars-cli` and check if they are available (path to each executable file must be shown in output of the command)

### <a name="prepare_ssh_config"></a>Prepare `~/.ssh/config`

```
Host z9v
HostName z9v.ru
User z9v
IdentityFile ~/.ssh/id_rsa
```

- Here `z9v` is internal name of host, which will be used in di/prod/miniapp/hosts
- `z9v.ru` is actual domain name for ssh-access to server; ip address may be used instead
- `z9v` again is the name of user has ssh access to server
- `~/.ssh/id_rsa` is path to private key, while public one is on server we deploy to

### Prepare `di/dev/hosts`, `di/demo/hosts`, `di/prod/hosts`

These are devoted to three deploy targets respectivly

In my case all three contains the same value `z9v`, the name of `Host` in my `~/.ssh/config`

### Prepare nginx on your server

I suppose that you, like me, use nginx as reverse proxy on your server side

So your nginx also must be properly prepared for our deploy:

#### File `/etc/nginx/httpd.conf`:

```

# ... some other stuff

server {
    server_name         dev.miniapp.u2h.ru;
    location ~ ^/(?!dev\.miniapp\.u2h\.ru) {
        rewrite ^.*$ /$host$request_uri last;
    }
    include /etc/nginx/main.conf;
    # ... some stuff related to https support, usually it managed by Certbot
}

server {
    server_name         demo.miniapp.u2h.ru;
    location ~ ^/(?!demo\.miniapp\.u2h\.ru) {
        rewrite ^.*$ /$host$request_uri last;
    }
    include /etc/nginx/main.conf;
    # ... some stuff related to https support, usually it managed by Certbot
}

server {
    server_name         miniapp.u2h.ru;
    location ~ ^/(?!miniapp\.u2h\.ru) {
        rewrite ^.*$ /$host$request_uri last;
    }
    include /etc/nginx/main.conf;
    # ... some stuff related to https support, usually it managed by Certbot
}

```

#### Commands after file `/etc/nginx/httpd.conf` is prepared:

- `sudo touch /etc/nginx/main.conf` to assure required file exists

- `sudo certbot --nginx` - run [Certbot](https://certbot.eff.org/) to add https support

### Systemd

I suppose that you, like me, use `systemd` on your server (especially, if it runs Debian or Ubuntu). Because while deploy we also prepare appropriate systemd.service file to run our service part as daemon

### Set `.env`

Set `DOMAIN` and `DOMAIN_RE`, as well as `PORT_DEV`, `PORT_DEMO` and `PORT`, the last stands for production enviroment

### Register bots by [@BotFather](https://t.me/BotFather)

I did it for
- [@dev_MiniAppBot](t.me/dev_MiniAppBot)
- [@demo_MiniAppBot](t.me/demo_MiniAppBot)
- [@prod_MiniAppBot](t.me/prod_MiniAppBot) - production (@MiniAppBot was already taken, unfortunatly)

save bot tokens to file `.secret` (in root of this repo; it is in `.gitignore`, so won't be pushed to github) as follows:

```
TOKEN_DEV=<sensitive data: token value>
TOKEN_DEMO=<sensitive data: token value>
TOKEN=<sensitive data: token value> # stands for prod
```

Appropriate token from file `.secret` will be used while running deploy to:
- call `setWebhook` (see line 144 of `di/apps/miniapp/do.sh`)
- supply server side (see line 136 of `di/apps/miniapp/do.sh`)

### Run deploy

Deploy is done by single command from root of repo:

- `di/dev/miniapp/deploy.sh -f` deploys to `dev` enviroment
- `di/demo/miniapp/deploy.sh -f` deploys to `demo` enviroment
- `di/prod/miniapp/deploy.sh -f` deploys to `prod` enviroment

#### What deploy script actually does?

It
- [assures](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L14-L20) that NVM is installed (i.e. installs it if needed; so, actually, you might skip manually installing and preparing NVM)
- [assures](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L22-L28) that [required version of node](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L8) is **installed**
- [assures](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L30-L36) that [required version of node](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L8) is **used**
- [installs](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L38-L41) required svelte adapter
- [builds](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L43-L44) the svelte app
- [reads](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L52-L61) the file `.secret` to get appropriate TOKEN
- [prepares](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L75-L93) systemd.service file (it has its own name for each deploy environment)
- [prepares](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L95-L117) file `include.conf` for NGINX to be auto included into `/etc/nginx/main.conf` on server
- [prepares](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L119-L127) `.env` file for server side: lines 124-131
- [make](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L129-L130) destination folder on server at HOME dir of User behalf of ssh connection to deploy is establishing (see [prepare_ssh_config](#prepare_ssh_config)), respectively to target deploy enviroment one of:
    - `~/miniapp/dev/miniapp/` 
    - `~/miniapp/demo/miniapp/`
    - `~/miniapp/prod/miniapp/`
- [rsync's](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L132-L133) to destination folder all built and prepared files
- [runs](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L135-L136) script [`deploy_server_helper.sh`](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh) on server side, which in its own turn:
    - [assures](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#L19-L25) that NVM is installed on server (i.e. installs it if needed)
    - [assures](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#L27-L33) that [required version of node](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#3) is **installed** on server; BEWARE: different node version may be set to be used on server
    - [assures](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#L35-L41) that [required version of node](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#3) is **used** on server; BEWARE: different node version may be set to be used on server
    - [installs dependencies](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#L45-L46)
    - [re/starts service](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#L48-L56), which [runs](https://github.com/yurybikuzin/miniapp/blob/main/deploy_server_helper.sh#L58) our app
- [assures](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L138-L142) proper `include ...;` statement exists in `/etc/nginx/main.conf` and [reloads nginx](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L141) to apply changes in `include.conf`
- [sets bot webhook](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L144-L145)
- [checks](https://github.com/yurybikuzin/miniapp/blob/main/di/apps/miniapp/do.sh#L146-L147) if MiniApp is ready 


## Development

Start a development server:

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Beyond this MiniApp deploy and development

To create a production version of your app:

```bash
npm run build
```

You can preview the production build with `npm run preview`.

But actually, you don't need to do it, because [deploy does it all](#deploy)

## Alternatives

I believe, same emulation (or even better) could be implemented not only for Svelte, but for React/Vue and others as well

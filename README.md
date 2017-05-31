Ejabberd 16.* and 17.* module to send offline user's message via POST request to target URL.
The main motivation for this module is to use it with push notifications. The request body is in JSON format. See the example below.

Tested with eJabberd 17.04.


Installation
------------

1.    Clone the repository into your Ejabberd's modules sources' folder. On Mac OS X, this folder is `~/.ejabberd-modules/sources/`.
2.    Run command: `ejabberdctl module_install mod_offline_http_post`

That's it. The module is now installed.

Configuration
-------------

Add the following to ejabberd configuration under `modules:`

```
mod_offline_http_post:
    auth_token: "secret"
    auth_token_key: "access_token"
    post_url: "http://example.com/notify"
```

-    auth_token - user defined, hard coded token that will be sent as part of the request's body. Use this token on the target server to validate that the request arrived from a trusted source.
-    post_url - the server's endpoint url

Example of the outgoing request:
--------------------------------

```
{'to':'user2','from':'user1','body':'hi there!','message_id':'purple9ca5e35b','access_token':'secret'}
```

Build and extend this module
----------------------------

The assumption is that you're developing on Mac OS X and installed Ejabberd via homebrew.
To build this module for development use the script `build.sh`. Please note that this script is configured to Ejabberd installation on Mac OS X. For other OS, you'll have to modify the dependencies path to point to your Ejabberd installation.

build.sh
```
/usr/local/Cellar/ejabberd/16.08/lib/lager-3.2.1/ebin/ 
/usr/local/Cellar/ejabberd/16.08/lib/fast_xml-1.1.14/ebin/
```

 You will also need to modify the path of Ejabberd `include` folder in `Emakefile`.

```
{'src/mod_offline_http_post', [{outdir, "ebin"},{i,"/usr/local/Cellar/ejabberd/16.08/lib/ejabberd-16.08/include"}]}.
```

Note that the scripts are pointing to Ejabberd version 16.08. If you're building against newer versions, you'll need to modify the paths in both `build.sh` and `Emakefile` regardless of whether you're on Mac OS X or not.

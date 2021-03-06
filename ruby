# ruby

https://www.owasp.org/index.php/Ruby_on_Rails_Cheatsheet
https://groups.google.com/forum/#!forum/rubyonrails-security
http://www.learnstreet.com/lessons/study/ruby
http://rails-sqli.org/
http://guides.rubyonrails.org/security.html # the usual security issues and countermeasures

# info disclosure
cause an error in rails
production != development mode => look for sensitive info (secret key used for cookies hmac)
http://website/home?a=1&a[]=1 # discovered by a brisbane guy bjeanes
http://website/home?x[y]=1&x[y]z=2 # one of the test cases on github

will also tell if it's rails or another ruby framework such as Sinatra

# see talk by joernchen of Phenoelit at hitb 2012 

# mass assignment
si c'est pas du rails 4, faut tenter dans chaque champ

# SQLi in RoR CVE-2012-5664
https://groups.google.com/forum/#!topic/rubyonrails-security/DCNTNp_qjFM

# reset pw
session[params[:token]] # there will always be session_id and _csrf_token in the session dictionary
https://gist.github.com/joernchen/9dfa57017b4732c04bcc http://www.akitaonrails.com/2014/08/28/small-bite-session-injection-challenge

# Action Pack vuln: insecure deserialisation when sending YAML within a XML or JSON request
https://community.rapid7.com/community/metasploit/blog/2013/01/09/serialization-mischief-in-ruby-land-cve-2013-0156 # XML+YAML
http://www.insinuator.net/2013/01/rails-yaml/
http://ronin-ruby.github.io/blog/2013/01/09/rails-pocs.html
https://community.rapid7.com/community/metasploit/blog/2013/01/29/exploit-for-ruby-on-rails-cve-2013-0333 # JSON+YAML
http://ronin-ruby.github.io/blog/2013/01/28/new-rails-poc.html
https://charlie.bz/blog/rails-3.2.10-remote-code-execution
https://community.rapid7.com/community/metasploit/blog/2013/01/10/exploiting-ruby-on-rails-with-metasploit-cve-2013-0156 # walkthrough using the msf scanner and exploit modules

* CVE-2013-0156 (YAML)
https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ/discussion
Versions Affected:  ALL
Fixed Versions:     3.2.11, 3.1.10, 3.0.19, 2.3.15 

* CVE-2013-0333 (JSON)
https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/1h2DR63ViGo
Versions Affected:  2.3.x, 3.0.x
Not Affected:       3.1.x, 3.2.x, applications using the yaml gem.
Fixed Versions:     3.0.20, 2.3.16 

To test using a page with no body:
pick a GET request and change it to a POST request
add X-HTTP-Method-Override: GET
  - xml/yaml
change Content-Type: application/xml
payload                         | vuln | not vuln
-------------------------------------------------
<a type="string">blah</a>       | 200  | 200
<a type="yaml">valid yaml</a>   | 200  | 500
<a type="yaml">invalid yaml</a> | 500  | 500

  - json/yaml
change Content-Type: application/json
payload          | vuln | not vuln
----------------------------------
{"asdf": "asdf"} | 200  | 200
--- {}           | 200  | 500
invalid yaml     | 500  | 500

To test using on a page with an existing body: 
if body is: user[firstname]=david&user[lastname]=...
change to xml with: curl -v 'http://192.168.122.224:3000/products?authenticity_token=F8...' -d '<user><firstname type="string">david</firstname></user>' -H 'Content-Type: application/xml'
if there's authenticity_token in the body, I can move it into the query string
if there's _method=PUT in the request, I can move it into headers => X-HTTP-Method-Override: PUT # rack/test/spec_methodoverride.rb

look at msf exploits

plop = "salut"
require 'yaml'
YAML.dump(plop)
=> "--- salut\n...\n"

# audit source code / checklist of things to check
brakeman

# regular expressions are multi-lines by default
/^\d+$/ will match "arbitrary data\n123\narbitrary data"

# rack
Rack is used by almost all Ruby web frameworks, such as RoR and Sinatra
* rack cookies
rack.session=BAh
_brainfit_session=BAh  // brainfit is the name of the app: rails new brainfit

decode cookie using pentesterlab's script rack_cookie.rb

si c'est du rails4 alors le cookie est chiffre

# fingerprint
Rails often runs on top of the Apache, NginX, Thin, and WEBrick servers
Rails may be only be accessible at a certain path, such as /forum or /redmine
Rails may be listening on a non-standard port, such as 3000, 4567, or 8888

X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.8
X-Rack-Cache: miss
Set-Cookie: _appname_session=(base64)%3D%3D--(hexadecimal)

# csrf bypass CVE-2011-0447
http://weblog.rubyonrails.org/2011/2/8/csrf-protection-bypass-in-ruby-on-rails/

# rails tuto
http://guides.rubyonrails.org/getting_started.html

# login bypass in rails restful_authentication plugin (28/10/2007)
/activate/?activation_code= => SELECT * FROM users WHERE (users.`activation_code` IS NULL) LIMIT 1 // and login w/o password as the first account 
http://www.rorsecurity.info/2007/10/28/restful_authentication-login-security/

# install rails
https://wiki.archlinux.org/index.php/Ruby_on_Rails

# install vuln rails
gem install rails -v 3.2.10
rails new blog
rails g controller products
echo 'resources :products' >> config/routes.rb
echo -e 'skip_before_filter :verify_authenticity_token\ndef create\np params\nend' >> app/controllers/products_controller.rb // add config.relative_url_root = "" for rails-3.0.x
echo '<h1>hello</h1><%= params %>' >> app/views/products/create.erb
rails server -b 0.0.0.0

# rvm
* switch to another version
source $(rvm 2.1.5 do rvm env --path)

# rubygems
https://wiki.archlinux.org/index.php/Ruby
gem list
gem spec rubydns
gem list --remote rubydns
gem install rubydns --no-rdoc --no-ri
gem install rails -v 3.2.10
gem update

gem install bundler
export GEM_HOME=~/.gem/ruby/2.0.0
export PATH=$PATH:$GEM_HOME/bin
bundle install # reads deps' versions from Gemfile

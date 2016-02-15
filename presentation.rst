====
r10k
====

:Author: Mark McKinstry
:Work: Nexcess
:Github: mmckinst

This work is licensed under the Creative Commons Attribution-ShareAlike 4.0
International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-sa/4.0/.


Introduction
============

This talk will cover:

* puppet control repo
* Puppetfile
* dynamic environments
* using r10k with all of the above



Puppet Control Repo
===================

The ideal control repo is sparse with very little in it, its purpose is to
control what puppet modules are pulled in and not do much else.

The control repo should have things like:

* Puppetfile
* roles and profiles (debatable)
* hieradata (debatable)

The control repo should **not** be a gigantic monolithic repo where all modules
are stored and developed.


Example Control Repo
====================

This would be deployed to an environment in /etc/puppetlabs/code/environments/ .

::

  .
  ├── environment.conf
  ├── hieradata
  │   └── common.yaml
  ├── modules
  ├── Puppetfile
  └── site
      └── profiles
          └── manifests
              ├── base.pp
              └── mysql.pp


Puppetfile Example
==================

.. code-block:: ruby

  mod 'puppetlabs/stdlib', '3.2.2'
  mod 'puppetlabs/concat', '1.2.5'
  mod 'puppetlabs/inifile', '1.4.3'
  mod 'saz/ssh', '2.8.1'
  mod 'saz/timezone', '3.3.0'

  mod 'zack/r10k',
    :git => 'https://github.com/acidprime/r10k',
    :tag => 'v3.1.1'
  
  mod 'nexcess/ksplice',
    :git => 'https://github.com/nexcess/puppet-ksplice.git',
    :tag => 'v2.0.0'   



Puppetfile Advanced Examples 1/3
================================

.. code-block:: ruby

  # latest version from Puppet Forge (not recommended)
  mod 'puppetlabs/stdlib'
  
  # latest commit from git (not recommended)
  mod 'puppetlabs/stdlib',
    :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git'

  # specific version from Puppet Forge
  mod 'puppetlabs/stdlib', '3.2.2'
   

Puppetfile Advanced Examples 2/3
================================

.. code-block:: ruby

  # specific tag in git
  mod 'puppetlabs/stdlib',
    :git => 'https://github.com/puppetlabs/puppetlabs-stdlib.git',
    :tag => '3.2.2'

  # specific commit in git
  mod 'puppetlabs/stdlib',
    :git    => 'https://github.com/puppetlabs/puppetlabs-stdlib.git',
    :commit => '990e1d757549a9c792cf5f7113e4d6bcd592ae3d'

  # specific branch in git (not always recommended)
  mod 'puppetlabs/stdlib',
    :git    => 'https://github.com/mmckinst/puppetlabs-stdlib.git',
    :branch => 'new_feature_that_upstream_hasnt_accepted_yet'


Puppetfile Advanced Examples 3/3
================================

.. code-block:: ruby

   # specific revision in svn
   mod 'thepast/old_stuff'
     :svn      => 'https://sourceforge.net/thepast/old_stuff/trunk'
     :revision => '154'



Dynamic Environments
====================

.. code-block:: yaml
   
   # /etc/puppetlabs/r10k/r10k.yaml
   
   cachedir: '/var/cache/r10k'
   sources:
     thecompany:
       remote: 'https://github.com/thecompany/control_repo.git'
       basedir: '/etc/puppetlabs/code/environments/'

* For each branch on your remote control repo, r10k will create an environment
  in /etc/puppetlabs/code/environments/ with the code from that branch. It will
  also deploy the modules specified in the Puppetfile.

::

   r10k deploy environment


Big Monolithic Repo
===================

* r10k wants to control the entire 'modules' directory, if it finds something in
  there it thinks shouldn't be there, it will delete it.


Big Monolithic Workaround 1/2
=============================

* use the ':local' option to prevent r10k from deleting the modules in your
  monolithic repo as you're in the process of putting them in their own git
  repos

.. code-block:: ruby

  mod 'dell_openmanage', :local => true
  mod 'yum_repos', :local => true


Big Monolithic Workaround 2/2
=============================

* have r10k deploy modules to a specific directory only it controls, then change
  your module search path in environment.conf

.. code-block:: ruby

  moduledir "external-modules"
  
  mod 'puppetlabs/stdlib', '3.2.2'
  mod 'puppetlabs/concat', '1.2.5'

* move your monolithic modules to a different directory, change your module
  search path, and let r10k control the 'modules' directory.


Things not covered
==================

* webhooks
* multiple repos in r10k.yaml.
  * e.g. another repo for hieradata that is deployed to a directory shared across all environments
* using r10k with just a puppetfile (no control repo or dynamic environments)

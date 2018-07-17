# START

* get project
* cd project_dir
* cp t/res/am_remote_config.ini.orig t/res/am_remote_config.ini
* cp t/res/tc_remote_config.ini.orig t/res/tc_remote_config.ini
* set proper values in t/res/am_remote_config.ini and t/res/tc_remote_config.ini 

# TESTS

* cd project_dir
* prove -Ilib t/

# USE

* cd project_dir
* ./utils/manage_app.pl --action deploy|undeploy|start|stop|status --config t/res/tc_remote_config.ini [--override_params_from_config_file]

# PARAMS

* app-file - application war
* app-server-user - application server manager login
* app-server-password - application server manager password
* app-url - link to application
* deploy-url - server local path or scp connection link
*	deploy-user - server login for upload war file
* deploy-password' - server password for upload war file

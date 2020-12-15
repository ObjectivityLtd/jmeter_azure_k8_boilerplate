    #!/bin/bash
    #Script created to invoke jmeter test script with the slave POD IP addresses
    #Script should be run like: ./load_test "path to the test script in jmx format"
    #/jmeter/apache-jmeter-*/bin/jmeter -n -t $1 -DjmeterPlugin.sts.loadAndRunOnStartup=true -DjmeterPlugin.sts.port=9191 -DjmeterPlugin.sts.datasetDirectory=/test -q /test/user.properties -Dserver.rmi.ssl.disable=true -R `getent ahostsv4 jmeter-slaves-svc | cut -d' ' -f1 | sort -u | awk -v ORS=, '{print $1}' | sed 's/,$//'`
    #!/bin/bash
    _set_vars() {
      ip=$(hostname -i)
      sts_name=simple-table-server.sh
      test_dir=/test
      shared_dir=/shared
    }
    _wait_for_sts() {
      sleepSec=2
      until [ "$http_code" == "200" ]; do
        printf "\n\t Waiting for STS ... $sleepSec s"
        sleep $sleepSec
        http_code=$(curl -s -o /dev/null -w "%{http_code}" http://$ip:9191/sts/INITFILE?FILENAME=google.csv)
        printf "\t\nHTTP Status: $http_code"
      done
    }
    _kill_script(){
      script=$1
      kill -9 $(pidof -x "$script") > /dev/null 2>&1
    }
    _kill_sts(){
      _kill_script $sts_name
    }
    _start_sts(){
      #for some reason nohup is no go perhaps SIGHUP is overwritten
      local _sts_name=$1
      local _shared_dir=$2
      screen -A -m -d -S sts /jmeter/apache-jmeter-*/bin/$_sts_name -DjmeterPlugin.sts.addTimestamp=true -DjmeterPlugin.sts.datasetDirectory=/$_shared_dir &
    }
    _jmeter(){
      local jmx=$1
      shift 1
      local fixed_args="-Gsts=$ip -Gchromedriver=/usr/bin/chromedriver -q /$test_dir/user.properties -Dserver.rmi.ssl.disable=true"
      sh /jmeter/apache-jmeter-*/bin/jmeter.sh -n -t /$test_dir/$jmx $@ $fixed_args -R $(getent ahostsv4 jmeter-slaves-svc | cut -d' ' -f1 | sort -u | awk -v ORS=, '{print $1}' | sed 's/,$//')

    }
    load_test(){
      _set_vars
      _kill_sts
      _start_sts $sts_name $shared_dir
      _wait_for_sts
      _jmeter "$@"
    }
    load_test "$@"